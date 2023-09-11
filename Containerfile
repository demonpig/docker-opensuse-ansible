FROM opensuse/tumbleweed:latest
LABEL maintainer="Max Mitschke"

ENV container=docker

ENV pip_packages "ansible"

# Install requirements.
RUN zypper ref && zypper dup -y \
  && zypper install -y systemd sudo update-alternatives\
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

# Install package dependences for Ansible
# openjdk libs are for ansible-rulebook
RUN zypper ref \
  && zypper install -y python311 java-17-openjdk-headless \
  && zypper clean -a

# Setup virtual environment
ADD ./files/ /
RUN update-alternatives --install /usr/bin/python3 python /usr/bin/python3.11 1 \
  && sh /usr/local/sbin/setup-env.sh

ENV PATH="/opt/ansible/bin:$PATH"

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]