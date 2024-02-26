FROM sangheon/sandbox:24.04

ARG VERSION=stable
ARG TARGETOS
ARG TARGETARCH

RUN su -c - ubuntu sh -c "\
TARGET=''; \
if [ \"${TARGETOS}\" = 'linux' ] && [ \"${TARGETARCH}\" = 'amd64' ]; then \
    TARGET='x86_64-unknown-linux-gnu'; \
elif [ \"${TARGETOS}\" = 'linux' ] && [ \"${TARGETARCH}\" = 'arm64' ]; then \
    TARGET='aarch64-unknown-linux-gnu'; \
elif [ \"${TARGETOS}\" = 'darwin' ] && [ \"${TARGETARCH}\" = 'amd64' ]; then \
    TARGET='x86_64-apple-darwin'; \
elif [ \"${TARGETOS}\" = 'darwin' ] && [ \"${TARGETARCH}\" = 'arm64' ]; then \
    TARGET='aarch64-apple-darwin'; \
else \
    echo \"Unsupported architecture: ${TARGETOS}/${TARGETARCH}\"; exit 1; \
fi; \
echo \"Installing Rust for ${TARGET}\" && \
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
sh -s -- -y --default-toolchain ${VERSION} --target \${TARGET}"