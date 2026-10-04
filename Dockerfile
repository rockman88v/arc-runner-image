FROM ghcr.io/actions/actions-runner:2.329.0

USER root

ARG TARGETARCH=amd64

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------
# Base tools
# ---------------------------------------------------------

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
        gnupg \
        && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# GitHub CLI
# ---------------------------------------------------------

ARG GH_VERSION=2.81.0

RUN curl -fsSL \
      "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${TARGETARCH}.tar.gz" \
      -o /tmp/gh.tar.gz && \
    tar -xzf /tmp/gh.tar.gz -C /tmp && \
    install -m 0755 \
      "/tmp/gh_${GH_VERSION}_linux_${TARGETARCH}/bin/gh" \
      /usr/local/bin/gh && \
    rm -rf \
      /tmp/gh.tar.gz \
      "/tmp/gh_${GH_VERSION}_linux_${TARGETARCH}"

# ---------------------------------------------------------
# kubectl
# ---------------------------------------------------------

ARG KUBECTL_VERSION=v1.36.1

RUN curl -fsSL \
      "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
      -o /usr/local/bin/kubectl && \
    chmod 0755 /usr/local/bin/kubectl

# ---------------------------------------------------------
# Helm
# ---------------------------------------------------------

ARG HELM_VERSION=v3.19.0

RUN curl -fsSL \
      "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
      -o /tmp/helm.tar.gz && \
    tar -xzf /tmp/helm.tar.gz -C /tmp && \
    install -m 0755 \
      "/tmp/linux-${TARGETARCH}/helm" \
      /usr/local/bin/helm && \
    rm -rf \
      /tmp/helm.tar.gz \
      "/tmp/linux-${TARGETARCH}"

# ---------------------------------------------------------
# Argo CD CLI
# ---------------------------------------------------------

ARG ARGOCD_VERSION=v3.5.3

RUN curl -fsSL \
      "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${TARGETARCH}" \
      -o /usr/local/bin/argocd && \
    chmod 0755 /usr/local/bin/argocd

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

RUN set -eux; \
    git --version; \
    gh --version; \
    jq --version; \
    python3 --version; \
    python3 -c "import yaml; print('PyYAML:', yaml.__version__)"; \
    kubectl version --client; \
    helm version --short; \
    argocd version --client; \
    aws --version

USER runner

ENTRYPOINT ["/home/runner/run.sh"]