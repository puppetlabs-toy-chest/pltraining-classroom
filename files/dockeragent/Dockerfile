# Builds a basic Centos6 container with pe-agent installed
# This image is for training purposes and is not intended for production environments.
FROM centos:6
MAINTAINER Josh Samuelson <js@puppetlabs.com>
ENV HOME /root/
ENV TERM xterm
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppet/bin
RUN yum -y install gcc g++ make automake autoconf curl-devel openssl-devel zlib-devel httpd-devel apr-devel apr-util-devel sqlite-devel
RUN yum -y install ruby-rdoc ruby-devel
RUN yum -y install  tar dmidecode which logrotate cyrus-sasl libxslt cronie pciutils git rubygems vim tree csh zsh net-tools wget
RUN wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz
RUN tar xvfvz ruby-2.1.2.tar.gz
RUN cd ruby-2.1.2 && ./configure && make && make install
RUN gem install multipart-post -v 1.2.0
RUN gem install r10k
ADD el-6-x86_64.bash /root/el-6-x86_64.bash
RUN cat /root/el-7-x86_64.bash |bash  ; rm /root/el-6-x86_64.bash
ADD puppet.conf /etc/puppetlabs/puppet/puppet.conf
RUN rm /etc/yum.repos.d/CentOS*
ADD base_local.repo /etc/yum.repos.d/base_local.repo
ADD epel_local.repo /etc/yum.repos.d/epel_local.repo
ADD updates_local.repo /etc/yum.repos.d/updates_local.repo
RUN yum clean all
