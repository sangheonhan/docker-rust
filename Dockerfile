FROM sangheon/sandbox:24.04

ARG VERSION=stable

RUN su -c - ubuntu sh -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
sh -s -- -y --default-toolchain $VERSION"