# Define the names/tags of the container
#!BuildTag: cobbler-test-github:latest cobbler-test-github:main cobbler-test-github:main.%RELEASE%

FROM opensuse/tumbleweed

# Define labels according to https://en.opensuse.org/Building_derived_containers
# labelprefix=org.opensuse.example
LABEL org.opencontainers.image.title="cobbler-test-github"
LABEL org.opencontainers.image.description="This contains the environment to run the testsuites of Cobbler inside a container."
LABEL org.opencontainers.image.version="0.1.0.%RELEASE%"
LABEL org.opensuse.reference="registry.opensuse.org/home/cobbler-project/github-ci/cobbler-test-github:main.%RELEASE%"
LABEL org.openbuildservice.disturl="%DISTURL%"
LABEL org.opencontainers.image.created="%BUILDTIME%"
# endlabelprefix

# ENV Variables we are using.
ENV container docker
ENV DISTRO SUSE
# Add Developer scripts to PATH
ENV PATH="/code/docker/develop/scripts:${PATH}"

# Runtime & dev dependencies
RUN zypper install --no-recommends -y \
    gdb                        \
    acl                        \
    apache2                    \
    apache2-devel              \
    apache2-mod_wsgi           \
    python3-gunicorn           \
    bash-completion            \
    createrepo_c               \
    fence-agents               \
    genders                    \
    git                        \
    gzip                       \
    ipmitool                   \
    make                       \
    curl                       \
    wget2                      \
    openssl                    \
    bind                       \
    systemd-devel              \
    cyrus-sasl-devel           \
    python3                    \
    python3-pip                \
    python3-Sphinx             \
    python3-sphinx_rtd_theme   \
    python3-coverage           \
    python3-devel              \
    python3-distro             \
    python3-schema             \
    python3-setuptools         \
    python3-systemd            \
    python3-pip                \
    python3-wheel              \
    python3-Cheetah3           \
    python3-distro             \
    python3-dnspython          \
    python3-Jinja2             \
    python3-requests           \
    python3-PyYAML             \
    python3-pykickstart        \
    python3-netaddr            \
    python3-pymongo            \
    python3-pytest-benchmark   \
    python3-black              \
    python3-librepo            \
    python3-legacycrypt        \
    go                         \
    rpm-build                  \
    rsync                      \
    supervisor                 \
    tftp                       \
    tree                       \
    util-linux                 \
    vim                        \
    which                      \
    xorriso                    \
    mtools                     \
    dosfstools

# Add virtualization repository
RUN zypper install -y \
    python3-hivex     \
    python3-pefile

# Add bootloader packages
RUN zypper install --no-recommends -y \
    syslinux            \
    shim                \
    ipxe-bootimgs       \
    grub2               \
    grub2-i386-efi      \
    grub2-x86_64-efi
#    grub2-arm64-efi

# Required for dhcpd
RUN zypper install --no-recommends -y \
    system-user-nobody                \
    sysvinit-tools

# Required for ldap tests
RUN zypper install --no-recommends -y \
    openldap2                         \
    openldap2-client                  \
    hostname                          \
    python3-ldap

# Dependencies for system-tests
RUN zypper install --no-recommends -y \
    dhcp-server                       \
    iproute2                          \
    qemu-kvm                          \
    time

# Install packages and dependencies via pip
RUN zypper install --no-recommends -y \
    python3-magic              \
    python3-pycodestyle        \
    python3-pyflakes           \
    python3-pytest             \
    python3-pytest-cov         \
    python3-pytest-mock

# Required for reposync tests
RUN zypper install --no-recommends -y \
    dnf                               \
    dnf-plugins-core                  \
    wget

# Required for reposync apt test
RUN zypper install --no-recommends -y \
    perl-LockFile-Simple              \
    perl-Net-INET6Glue                \
    perl-LWP-Protocol-https           \
    ed
# FIXME: We don't have debmirror in the right OBS projects.
#RUN dnf install -y http://download.fedoraproject.org/pub/fedora/linux/releases/35/Everything/x86_64/os/Packages/d/debmirror-2.35-2.fc35.noarch.rpm

# Clean zypper cache
RUN zypper clean -a

# Add Testuser for the PAM tests
RUN useradd -p $(perl -e 'print crypt("test", "password")') test

# Enable the Apache Modules
RUN ["a2enmod", "version"]
RUN ["a2enmod", "proxy"]
RUN ["a2enmod", "proxy_http"]
RUN ["a2enmod", "wsgi"]

# create working directory
RUN ["mkdir", "/code"]
VOLUME ["/code"]
WORKDIR "/code"

# Set this as an entrypoint
CMD ["/bin/bash"]
