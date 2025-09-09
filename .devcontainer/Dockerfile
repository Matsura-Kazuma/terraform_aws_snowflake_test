# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# CA導入 + aptキャッシュ
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates openssl curl git && \
    update-ca-certificates

# 企業ルートCA をシステム信頼ストアへ
# ※ .devcontainer/certs/fortinet-root.crt を必ず置く
COPY .devcontainer/certs/fortinet-root.crt /usr/local/share/ca-certificates/fortinet-root.crt
RUN update-ca-certificates

# pip/requests に“システムCA束”を使わせる（certifiの独自束を回避）
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV PIP_CERT=/etc/ssl/certs/ca-certificates.crt

# Git も OpenSSL + 統合CA束を使う（お好み）
RUN git config --system http.sslbackend openssl && \
    git config --system http.sslcainfo /etc/ssl/certs/ca-certificates.crt