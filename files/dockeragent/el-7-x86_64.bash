#!/bin/bash -e

fail() { echo >&2 "$@"; exit 1; }
cmd()  { hash "$1" >&/dev/null; } # portable 'which'
mktempfile() {
  if cmd mktemp; then
    if [ "osx" = "${PLATFORM_NAME}" ]; then
      mktemp -t installer
    else
      mktemp
    fi
  else
    echo "/tmp/puppet-enterprise-installer.XXX-${RANDOM}"
  fi
}

custom_puppet_configuration() {
  # Parse optional pre-installation configuration of Puppet settings via
  # command-line arguments. Arguments should be of the form
  # <section>:<setting>=<value>
  regex='(.*):(.*)=(.*)'
  for entry in "$@"; do
    if ! [[ "$entry" =~ $regex ]]; then
      echo "WARNING: unable to interpret argument: ${entry}. Expected <section>:<setting>=<value>"
    else
      section=${BASH_REMATCH[1]}
      setting=${BASH_REMATCH[2]}
      value=${BASH_REMATCH[3]}
      /opt/puppet/bin/puppet config set "$setting" "$value" --section "$section"
    fi
  done
}

ensure_link() {
  /opt/puppet/bin/puppet resource file "${1?}" ensure=link target="${2?}"
}

ensure_agent_links() {
  target_path="/usr/local/bin"
  pe_path="/opt/puppet/bin"

  if mkdir -p "${target_path}" && [ -w "${target_path}" ]; then
    for bin in facter puppet pe-man hiera; do
      ensure_link "${target_path}/${bin}" "${pe_path}/${bin}"
    done
  else
    echo "!!! WARNING: ${target_path} is inaccessible; unable to create convenience symlinks for puppet, hiera, facter and pe-man.  These executables may be found in ${pe_path?}." 1>&2
  fi
}

# Detected existing installation? Return y if true, else n
is_upgrade() {
  if [ -x '/opt/puppet/bin/puppet' ]; then
    echo "y"
  else
    echo "n"
  fi
}

# Sets server, certname and any custom puppet.conf flags passed in to the script
puppet_config_set() {
  /opt/puppet/bin/puppet config set server puppetfactory.puppetlabs.vm --section main
  /opt/puppet/bin/puppet config set certname $(/opt/puppet/bin/facter fqdn | /opt/puppet/bin/ruby -e 'puts STDIN.read.downcase') --section agent
  custom_puppet_configuration "$@"
}

start_puppet_agent() {
  /opt/puppet/bin/puppet resource service pe-puppet ensure=running enable=true
}

# In version 7.10.0 curl introduced the -k flag and performs peer
# certificate validation by default. If peer validation is performed by
# default the -k flag is necessary for this script to work. However, if curl
# is older than 7.10.0 the -k flag does not exist. This function will return
# the correct invocation of curl depending on the version installed.
curl_no_peer_verify() {
  curl_ver_regex='curl ([0-9]+)\.([0-9]+)\.([0-9]+)'
  [[ "$(curl -V 2>/dev/null)" =~ $curl_ver_regex ]]
  curl_majv="${BASH_REMATCH[1]-7}"  # Default to 7  if no match
  curl_minv="${BASH_REMATCH[2]-10}" # Default to 10 if no match
  if [[ "$curl_majv" -eq 7 && "$curl_minv" -le 9 ]] || [[ "$curl_majv" -lt 7 ]]; then
    curl_invocation="curl"
  else
    curl_invocation="curl -k"
  fi

  $curl_invocation "$@"
}

run_agent_install_from_url() {
    url="${1?}"

    install_file=$(mktempfile)
    if cmd curl; then
        # curl on AIX doesn't support -k, but it's the default behavior
        if [ "$PLATFORM_NAME" = "aix" ]; then
          CURL="curl_no_peer_verify"
        else
          CURL="curl -k"
        fi
        t_http_code="$($CURL --tlsv1 -sLo "${install_file?}" "${url}" --write-out %{http_code} || fail "curl failed to get ${url}")"
    elif cmd wget; then
        # wget on AIX doesn't support SSL
        [ "$PLATFORM_NAME" = "aix" ] && fail "Unable to download installation materials without curl"

        # Run wget and use awk to figure out the HTTP status.
        t_http_code="$(wget --secure-protocol=TLSv1 -O "${install_file?}" --no-check-certificate -S "${url}" 2>&1 | awk '/HTTP\/1.1/ { printf $2 }')"
        if [ -z "${t_http_code?}" ]; then
            fail "wget failed to get ${url}"
        fi
    else
        fail "Unable to download installation materials without curl or wget"
    fi

    if [ "${t_http_code?}" != '200' ]; then
        t_supported_platforms="(el-(4|5|6|7)-(i386|x86_64))|(debian-(6|7)-(i386|amd64))|(ubuntu-(10\.04|12\.04|14\.04)-(i386|amd64))|(sles-(10|11|12)-(i386|x86_64))|(solaris-(10|11)-(i386|sparc))|(aix-(5\.3|6\.1|7\.1)-power)|(osx-10\.9-x86_64)"
        if [[ "${PLATFORM_TAG?}" =~ ${t_supported_platforms?} ]]; then
            fail "The agent packages needed to support ${PLATFORM_TAG} are not present on your master. \
    To add them, apply the pe_repo::platform::$(echo "${PLATFORM_TAG?}" | tr - _ | tr -dc '[:alnum:]_') class to your master node and then run Puppet. \
    The required agent packages should be retrieved when puppet runs on the master, after which you can run the install.bash script again."
        else
            fail "This method of agent installation is not supported for ${PLATFORM_TAG?} in Puppet Enterprise v3.8.1
    Please install using the puppet-enterprise-installer from the Puppet Enterprise v3.8.1 tarball"
        fi
    fi

    bash "${install_file?}" "${@: 2}" || fail "Error running install script ${install_file?}"
}


install_agent() {
  doing_upgrade=$(is_upgrade)

  cat <<REPO > /etc/yum.repos.d/pe_repo.repo
[puppetlabs-pepackages]
name=Puppet Labs PE Packages \$releasever - \$basearch
baseurl=https://172.17.42.1:8140/packages/3.8.1/el-7-x86_64
enabled=1
gpgcheck=1
sslverify=False
proxy=_none_
gpgkey=https://172.17.42.1:8140/packages/GPG-KEY-puppetlabs

REPO

  yum clean all --disablerepo="*" --enablerepo=pe_repo
  yum install -y pe-agent

  if [ ! y = "${doing_upgrade}" ]; then
    puppet_config_set "$@"
    start_puppet_agent
  fi

  ensure_agent_links
}

install_agent "$@"
