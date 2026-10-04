FROM ghcr.io/actions/actions-runner:latest

USER root

ARG TARGETARCH=amd64

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        jq \
        unzip \
        ca-certificates \
        git \
        python3 \
        python3-pip \
        python3-yaml \
        apt-transport-https \
        gnupg \
        lsb-release \
        && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# GitHub CLI
# ---------------------------------------------------------

RUN type -p curl >/dev/null && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | tee /usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
      signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
      https://cli.github.com/packages stable main" \
      | tee /etc/apt/sources.list.d/github-cli.list >/dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# kubectl
# ---------------------------------------------------------

ARG KUBECTL_VERSION=v1.36.1

RUN curl -fsSL \
      "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
      -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# ---------------------------------------------------------
# Helm
# ---------------------------------------------------------

ARG HELM_VERSION=v3.19.0

RUN curl -fsSL \
      "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
      -o /tmp/helm.tar.gz && \
    tar -xzf /tmp/helm.tar.gz -C /tmp && \
    mv "/tmp/linux-${TARGETARCH}/helm" /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf /tmp/helm.tar.gz "/tmp/linux-${TARGETARCH}"

# ---------------------------------------------------------
# Argo CD CLI
# ---------------------------------------------------------

ARG ARGOCD_VERSION=v3.5.3

RUN curl -fsSL \
      "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${TARGETARCH}" \
      -o /usr/local/bin/argocd && \
    chmod +x /usr/local/bin/argocd

# ---------------------------------------------------------
# AWS CLI
# ---------------------------------------------------------

RUN curl -fsSL \
      "https://awscli.amazonaws.com/awscli-exe-linux-${TARGETARCH}.zip" \
      -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# ---------------------------------------------------------
# Verify
# ---------------------------------------------------------

RUN git --version && \
    gh --version && \
    jq --version && \
    python3 --version && \
    kubectl version --client && \
    helm version --short && \
    argocd version --client && \
    aws --version

USER runner

ENTRYPOINT ["/home/runner/run.sh"]