#!/bin/sh

VENV_DIR="${1:-/opt/ansible}"

if [[ -d $VENV_DIR ]]; then
    rm -rf $VENV_DIR
fi

# This task is going to be dependent on how the system's python environment
# is configured. I am going to make the assumption that python3 is installed
# by default.
/usr/bin/python3 -m venv $VENV_DIR
$VENV_DIR/bin/pip install --upgrade pip setuptools
$VENV_DIR/bin/pip install -r /etc/ansible/requirements.txt

# Install galaxy collections
$VENV_DIR/bin/ansible-galaxy collection install -r /etc/ansible/requirements.yml \
    -p $VENV_DIR/lib/$(basename $(readlink -f /usr/bin/python3))/site-packages