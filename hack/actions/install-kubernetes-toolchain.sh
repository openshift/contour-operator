#! /usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly KUSTOMIZE_VERS="v4.2.0"
readonly KUBECTL_VERS="v1.21.2"
readonly KIND_VERS="v0.11.1"
readonly KUBEBUILDER_VERS="3.1.0"
readonly ETCD_VERS="v3.5.0"

readonly PROGNAME=$(basename $0)
readonly CURL=${CURL:-curl}

# Google storage is case sensitive, so we we need to lowercase the OS.
readonly OS=$(uname | tr '[:upper:]' '[:lower:]')

# used for operator-sdk binary
readonly ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
readonly OPERATOR_SDK_VERSION="v1.9.0"

usage() {
  echo "Usage: $PROGNAME INSTALLDIR"
}

download() {
    local -r url="$1"
    local -r target="$2"

    echo Downloading "$target" from "$url"
    ${CURL} --progress-bar --location  --output "$target" "$url"
}

case "$#" in
  "1")
    mkdir -p "$1"
    readonly DESTDIR=$(cd "$1" && pwd)
    ;;
  *)
    usage
    exit 64
    ;;
esac


# kind
download \
    "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERS}/kind-${OS}-amd64" \
    "${DESTDIR}/kind"

chmod +x  "${DESTDIR}/kind"

# kubectl
download \
    "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERS}/bin/${OS}/amd64/kubectl" \
    "${DESTDIR}/kubectl"

chmod +x "${DESTDIR}/kubectl"

# kube-apiserver
download \
    "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERS}/bin/${OS}/amd64/kube-apiserver" \
    "${DESTDIR}/kube-apiserver"

chmod +x "${DESTDIR}/kube-apiserver"

# etcd
download \
    "https://storage.googleapis.com/etcd/${ETCD_VERS}/etcd-${ETCD_VERS}-${OS}-amd64.tar.gz" \
    "${DESTDIR}/etcd.tgz"

tar -C "${DESTDIR}" -xf "${DESTDIR}/etcd.tgz" 
rm "${DESTDIR}/etcd.tgz"
sudo mv ${DESTDIR}/etcd-${ETCD_VERS}-${OS}-amd64/etcd /usr/local/bin/

# kustomize
download \
    "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERS}/kustomize_${KUSTOMIZE_VERS}_${OS}_amd64.tar.gz" \
    "${DESTDIR}/kustomize.tgz"

tar -C "${DESTDIR}" -xf "${DESTDIR}/kustomize.tgz" kustomize
rm "${DESTDIR}/kustomize.tgz"

# kubebuilder
download \
    "https://github.com/kubernetes-sigs/kubebuilder/releases/download/v${KUBEBUILDER_VERS}/kubebuilder_${KUBEBUILDER_VERS}_${OS}_amd64" \
    "${DESTDIR}/kubebuilder"

chmod +x "${DESTDIR}/kubebuilder"

# operator-sdk
download \
    "https://github.com/operator-framework/operator-sdk/releases/download/${OPERATOR_SDK_VERSION}/operator-sdk_${OS}_${ARCH}" \
    "${DESTDIR}/operator-sdk_${OS}_${ARCH}"
chmod +x ${DESTDIR}/operator-sdk_${OS}_${ARCH} && sudo mv ${DESTDIR}/operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk

# setup env for kind
sudo mkdir -p /usr/local/kubebuilder/bin
sudo cp ${DESTDIR}/kube-apiserver /usr/local/kubebuilder/bin
sudo cp ${DESTDIR}/etcd-${ETCD_VERS}-${OS}-amd64/etcd /usr/local/kubebuilder/bin
sudo cp ${DESTDIR}/kubectl /usr/local/kubebuilder/bin
