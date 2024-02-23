FROM sangheon/sandbox:24.04

ARG VERSION=stable

RUN sed -i "/chmod 0755 \/app\//a sudo -u \\\$USERNAME sh -c 'curl --proto \
'=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
--default-toolchain $VERSION'" /usr/local/bin/entrypoint.sh