# Builds a basic Centos7 container with pe-agent installed
# This image is for training purposes and is not intended for production environments.
FROM centos:7
MAINTAINER Josh Samuelson <js@puppetlabs.com>
ENV HOME /root/
ENV TERM xterm
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppet/bin
RUN yum -y install sudo tar dmidecode which logrotate cyrus-sasl libxslt cronie pciutils git rubygems vim tree csh zsh net-tools
RUN gem install multipart-post -v 1.2.0
RUN gem install r10k
ADD el-7-x86_64.bash /root/el-7-x86_64.bash
RUN cat /root/el-7-x86_64.bash |bash  ; rm /root/el-7-x86_64.bash
ADD puppet.conf /etc/puppetlabs/puppet/puppet.conf
RUN rm /etc/yum.repos.d/CentOS*
ADD base_local.repo /etc/yum.repos.d/base_local.repo
ADD epel_local.repo /etc/yum.repos.d/epel_local.repo
ADD updates_local.repo /etc/yum.repos.d/updates_local.repo
RUN yum clean all
