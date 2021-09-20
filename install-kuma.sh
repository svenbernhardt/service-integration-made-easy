#! /bin/sh

curl -L https://kuma.io/installer.sh | sh -

KUMA_HOME=$(ls | grep kuma-)

mv $KUMA_HOME $HOME/bin/kuma

ln -Fs $HOME/bin/kuma/bin/kumactl /usr/local/bin/kumactl

