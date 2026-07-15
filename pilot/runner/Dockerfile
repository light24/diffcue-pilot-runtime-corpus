FROM ubuntu:24.04@sha256:4fbb8e6a8395de5a7550b33509421a2bafbc0aab6c06ba2cef9ebffbc7092d90

ARG RUNNER_VERSION=2.335.1
ARG TARGETARCH
ARG RUNNER_SHA256_ARM64=6d1e85bfd1a506a8b17c1f1b9b57dba458ffed90898799aaa9f599520b0d9207
ARG RUNNER_SHA256_AMD64=4ef2f25285f0ae4477f1fe1e346db76d2f3ebf03824e2ddd1973a2819bf6c8cf

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       ca-certificates curl git jq libicu74 libssl3 procps zlib1g \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 1001 --shell /bin/bash runner \
    && mkdir -p /home/runner/actions-runner /var/lib/diffcue /run/bootstrap \
    && case "$TARGETARCH" in \
         arm64) archive_arch=arm64; archive_sha="$RUNNER_SHA256_ARM64" ;; \
         amd64) archive_arch=x64; archive_sha="$RUNNER_SHA256_AMD64" ;; \
         *) echo "unsupported Docker architecture: $TARGETARCH" >&2; exit 1 ;; \
       esac \
    && curl --fail --location --silent --show-error \
       "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${archive_arch}-${RUNNER_VERSION}.tar.gz" \
       --output /tmp/actions-runner.tar.gz \
    && echo "${archive_sha}  /tmp/actions-runner.tar.gz" | sha256sum --check --strict \
    && tar --extract --gzip --file /tmp/actions-runner.tar.gz --directory /home/runner/actions-runner \
    && rm /tmp/actions-runner.tar.gz \
    && chown -R runner:runner /home/runner /var/lib/diffcue /run/bootstrap

COPY --chown=runner:runner runner-entrypoint.sh /usr/local/bin/runner-entrypoint
RUN chmod 0555 /usr/local/bin/runner-entrypoint

USER runner
WORKDIR /home/runner/actions-runner
ENTRYPOINT ["/usr/local/bin/runner-entrypoint"]
