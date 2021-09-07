FROM registry.ci.openshift.org/openshift/release:golang-1.16

ENV KUSTOMIZE_VERSION="4.3.0"

# Install kustomize
RUN curl -sSLo kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" && \
    tar -C /usr/local/bin -zvxf kustomize.tar.gz
