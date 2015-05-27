# Builds a basic Centos7 container with pe-agent installed at first boot.
# This image is for training purposes and is not intended for production environments.
FROM centos:7
MAINTAINER Josh Samuelson <js@puppetlabs.com>
ENV HOME /root/
ENV TERM xterm
RUN yum -y install sudo tar dmidecode which logrotate cyrus-sasl libxslt cronie pciutils git rubygems vim tree csh zsh
RUN gem install multipart-post -v 1.2.0
RUN gem install r10k
RUN rm /etc/yum.repos.d/CentOS*
ADD base_local.repo /etc/yum.repos.d/base_local.repo
ADD epel_local.repo /etc/yum.repos.d/epel_local.repo
ADD updates_local.repo /etc/yum.repos.d/updates_local.repo
RUN echo 'if ! hash puppet; then curl -k https://master.puppetlabs.vm:8140/packages/current/install.bash | sudo bash; fi' >> /etc/rc.local
