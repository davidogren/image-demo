FROM registry.redhat.io/rhel9/rhel-bootc:9.8

## You'd probably create a custom intermediate based image of bootc with standard P72 stuff
## Instead I'm just going to simulate that with installing some basic tools and config

## kernel-devel and kernel-headers would be used in installation of NVidia drivers

RUN dnf -y install \
        kernel-devel \
        kernel-headers \
        podman \
        tmux \
        tree

COPY etc/sudoers /etc/sudoers
RUN useradd ogren -p '$6$7YSd3WNXIW2wVHrQ$I0ObMnnaZ3QsQL56wh0btjqLyUTZRQxc6dknks1nzGzrSKifNGFMeJPAeS9N8/WXlMpHsIGY5JWc.2VkKoAlW0'


## Then we can do some Kubernetes specific things. First we need to the repos

COPY etc/yum.repos.d/kubernetes.repo etc/yum.repos.d/kubernetes.repo

## Then we can install the rpms from EPEL and Kubernetes

RUN dnf config-manager --set-enabled codeready-builder-for-rhel-9-x86_64-rpms && \
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    mv /etc/selinux /etc/selinux.tmp && \
    dnf -y install \
        kubectl  \
        kubeadm   \
        containerd \
        && \
    dnf clean all && \
    mv /etc/selinux.tmp /etc/selinux

## At this point we'd probably do more config, but I'll just wrap up by updating subscription manager
COPY  config/auth.json /run/containers/0/auth.json 
COPY  config/auth.json /run/ostree/auth.json

