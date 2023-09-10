FROM opensuse/tumbleweed:latest
LABEL maintainer="Max Mitschke"

ENV container=docker

ENV pip_packages "ansible"

# Install requirements.
RUN zypper ref && zypper dup -y \
  && zypper install -y \
      systemd \      
      python3 \
      python3-pip \
      sudo \
  && zypper clean -a

# Install systemd -- See https://hub.docker.com/_/centos/
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Setup virtual environment and configure ansible to use it
ADD ./files/ / 
RUN python3 -m venv /opt/ansible \
  && /opt/ansible/bin/pip install --upgrade pip setuptools \
  && /opt/ansible/bin/pip install $pip_packages

ENV PATH="/opt/ansible/bin:$PATH"

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]