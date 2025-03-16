#!/usr/bin/env bash

#######################################################################################################################
############################################## Linux Distros Tested & Used ############################################
#######################################################################################################################

# Alpine:
# - TBD, most likely Alpine (XFCE Desktop Environment)

# Arch:
# - EndeavourOS (KDE Plasma Desktop Environment, Cinnamon Desktop Environment)

# Red Hat:
# - TBD, most likely Fedora Workstation (GNOME Desktop Environment)

# SUSE Linux Enterprise:
# - TBD, most likely OpenSUSE Tumbleweed (KDE Plasma Desktop Environment)

# Ubuntu:
# - Zorin OS (GNOME Desktop Environment)

#######################################################################################################################
############################################## Determine Linux Distro Base ############################################
#######################################################################################################################

LINUX_DISTRO_BASE=$(cat "/proc/version")
declare -r LINUX_DISTRO_BASE

#######################################################################################################################
################################################ Script Output Function ###############################################
#######################################################################################################################

function print_separator() {
    printf -- "-----------------------------------------------------------------------------------------------------------------------\n"
}

function log_output() {
    local -r output_message="${1}"

    print_separator
    printf "%s\n" "${output_message}"
    print_separator
}



#######################################################################################################################
####################################### Package Manager Package Update Functions ######################################
#######################################################################################################################

# Alpine Package Manager
function update_upgrade_apk() {
    su
    apk update
    apk upgrade --yes
}

# Arch Package Manager
function update_upgrade_pacman() {
    sudo pacman --sync --refresh --sysupgrade --noconfirm
}

function update_upgrade_aur() {
    yay --sync --refresh --sysupgrade --noconfirm
}

# Fedora Package Manager
function update_dnf() {
    sudo dnf upgrade --yes
}

# Generic Package Manager
function update_flatpak() {
    flatpak update --assumeyes
}

# Ubuntu Package Managers
function update_upgrade_apt() {
    sudo apt update
    sudo apt upgrade --yes
}

function update_snap() {
    sudo snap refresh
}



#######################################################################################################################
############################################## Package Manager Installation ###########################################
#######################################################################################################################

function install_flatpak() {
    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        log_output "Installing Flatpak."
        update_upgrade_pacman
        sudo pacman --sync flatpak --noconfirm
    # elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
    # elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
    fi

    flatpak --version
}

function install_package_manager() {
    install_flatpak
}

#######################################################################################################################
############################################# Graphics Driver Configuration ###########################################
#######################################################################################################################

function configure_nvidia_drivers() {
    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        log_output "Installing Nvidia drivers."
        update_upgrade_pacman
        sudo pacman --sync nvidia --noconfirm
    # elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        # Run this command if there are issues booting into an Ubuntu installation. This failure could be caused by
        # Nvidia  driver issues. The commands in this function can resolve this issue. These commands can only be
        # effective in a fresh OS installation.

        log_output "Removing Nvidia drivers."

        update_upgrade_apt
        sudo apt purge nvidia* --yes

        update_upgrade_apt
        sudo ubuntu-drivers autoinstall --yes
    fi
}

function configure_graphics_drivers() {
    configure_nvidia_drivers
}



#######################################################################################################################
###################################### Deployment Tools Installation & Configuration ##################################
#######################################################################################################################

function install_docker() {
    log_output "Installing Docker. Reference installation documentation: https://docs.docker.com/engine/install/"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add docker --yes

        update_upgrade_apk
        apk add docker-cli-compose --yes

        # Add user to Docker group
        su usermod --append --groups "docker" "${USER}"
        newgrp "docker"
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync docker --noconfirm

        # Add user to Docker group
        sudo usermod --append --groups "docker" "${USER}"
        newgrp "docker"
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install dnf-plugins-core --yes

        update_dnf
        sudo dnf-3 config-manager --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

        update_dnf
        sudo dnf install docker-ce --yes

        update_dnf
        sudo dnf install docker-ce-cli --yes

        update_dnf
        sudo dnf install containerd.io --yes

        update_dnf
        sudo dnf install docker-buildx-plugin --yes

        update_dnf
        sudo dnf install docker-compose-plugin

        # Add user to Docker group
        sudo usermod --append --groups "docker" "${USER}"
        newgrp "docker"
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        # Add Docker's official GPG key:
        update_upgrade_apt
        sudo apt install ca-certificates --yes

        update_upgrade_apt
        sudo apt install curl --yes

        sudo install \
            --mode=0755 \
            --directory="/etc/apt/keyrings"

        sudo curl \
            --fail \
            --silent \
            --show-error \
            --location "https://download.docker.com/linux/ubuntu/gpg" \
            --output "/etc/apt/keyrings/docker.asc"

        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        # shellcheck disable=SC1091
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
            https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker Engine.
        update_upgrade_apt
        sudo apt install docker-ce --yes

        update_upgrade_apt
        sudo apt install docker-ce-cli --yes

        update_upgrade_apt
        sudo apt install containerd.io --yes

        update_upgrade_apt
        sudo apt install docker-buildx-plugin --yes

        update_upgrade_apt
        sudo apt install docker-compose-plugin --yes

        # Add user to Docker group
        sudo usermod --append --groups "docker" "${USER}"
        newgrp "docker"
    fi

    docker --version
}

function configure_docker_startup() {
    log_output "Configuring Docker to automatically start running at system startup."

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        rc-update add docker default
        service docker start
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        sudo systemctl start docker
        sudo systemctl enable --now docker
        systemctl status docker
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        sudo systemctl start docker
        sudo systemctl enable --now docker
        systemctl status docker
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        sudo service docker start
        systemctl status docker
    fi
}

function test_docker_installation() {
    log_output "Running a test Docker image."

    docker run hello-world
}

function install_minikube() {
    log_output "Installing Minikube. Reference installation documentation: https://minikube.sigs.k8s.io/docs/start"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        curl \
            --location \
            --output "minikube" \
            "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"

        chmod +x "minikube"

        su mv --verbose "minikube" "/usr/local/bin/"
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync minikube --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        curl \
            --location \
            --output "minikube" \
            "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"

        chmod +x "minikube"

        sudo mv --verbose "minikube" "/usr/local/bin/"
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        curl \
            --location \
            --output "minikube" \
            "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"

        chmod +x "minikube"

        sudo mv --verbose "minikube" "/usr/local/bin/"
    fi

    minikube version
}

function start_minikube() {
    log_output "Starting Minikube."

    minikube start
}

function test_minikube_installation() {
    log_output "Testing Minikube Installation."

    minikube status
}

function install_kubernetes() {
    log_output "Installing Kubernetes. Reference installation documentation: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        local -r latest_kubernetes_release="$(curl --silent \"https://storage.googleapis.com/kubernetes-release/release/stable.txt\")"

        curl \
            --location \
            --output \
            "https://storage.googleapis.com/kubernetes-release/release/${latest_kubernetes_release}/bin/linux/amd64/kubectl"

        chmod +x ./"kubectl"

        su mv --verbose ./"kubectl" "/usr/local/bin/kubectl"
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync kubectl --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install kubectl --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        local -r latest_kubernetes_release="$(curl --silent \"https://storage.googleapis.com/kubernetes-release/release/stable.txt\")"

        curl \
            --location \
            --output \
            "https://storage.googleapis.com/kubernetes-release/release/${latest_kubernetes_release}/bin/linux/amd64/kubectl"

        chmod +x ./"kubectl"

        sudo mv --verbose ./"kubectl" "/usr/local/bin/kubectl"
    fi

    kubectl version
    kubectl cluster-info
}

function install_helm() {
    log_output "Installing Helm. Reference installation documentation: https://helm.sh/docs/intro/install/"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        local -r install_helm_file_name="get_helm.sh"

        curl "https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get-helm-3" > "${install_helm_file_name}"

        chmod 700 "${install_helm_file_name}"

        ./"${install_helm_file_name}"

        rm --force --verbose "${install_helm_file_name}"
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync helm --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install helm --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        local -r install_helm_file_name="get_helm.sh"

        curl "https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get-helm-3" > "${install_helm_file_name}"

        chmod 700 "${install_helm_file_name}"

        ./"${install_helm_file_name}"

        rm --force --verbose "${install_helm_file_name}"
    fi

    helm version
}

function test_helm_installation() {
    log_output "Testing Helm Installation."

    helm repo add bitnami "https://charts.bitnami.com/bitnami"

    helm install odoo bitnami/odoo --set serviceType=NodePort

    kubectl get pods | grep "Running"

    helm delete odoo
}

function install_configure_deployment_tools() {
    install_docker
    configure_docker_startup
    test_docker_installation

    install_minikube
    start_minikube
    test_minikube_installation

    install_kubernetes

    install_helm
    test_helm_installation
}



#######################################################################################################################
#################################### .NET Development Prerequisites Installation ######################################
#######################################################################################################################

function install_dot_net_sdk() {
    log_output "Installing the .NET SDK for C# development. Reference installation documentation: https://learn.microsoft.com/en-us/dotnet/core/install/linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add dotnet9-sdk --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync dotnet-sdk --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install dotnet-sdk-9.0 --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo dpkg --purge packages-microsoft-prod

        update_upgrade_apt
        sudo dpkg --install packages-microsoft-prod.deb

        update_upgrade_apt
        sudo apt install dotnet-sdk-9.0 --yes
    fi

    dotnet --list-sdks
    dotnet --info
}

function install_asp_net_runtime() {
    log_output "Installing the ASP .NET Runtime for C# development. Reference installation documentation: https://learn.microsoft.com/en-us/dotnet/core/install/linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add aspnetcore9-runtime --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync aspnet-runtime --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install aspnetcore-runtime-9.0 --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install aspnetcore-runtime-9.0 --yes
    fi

    dotnet --list-runtimes
    dotnet --info
}

function install_dot_net_runtime() {
    log_output "Installing the .NET Runtime for C# development. Reference installation documentation: https://learn.microsoft.com/en-us/dotnet/core/install/linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add dotnet9-runtime --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync dotnet-runtime --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install dotnet-runtime-9.0 --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install dotnet-runtime-9.0 --yes
    fi

    dotnet --list-runtimes
    dotnet --info
}

function install_dot_net_development_prerequisites() {
    install_dot_net_sdk
    install_asp_net_runtime
    install_dot_net_runtime
}



#######################################################################################################################
################################# JavaScript Development Prerequisite Installation ####################################
#######################################################################################################################

function install_nodejs_runtime() {
    log_output "Installing the Node JS runtime for JavaScript development. Reference installation documentation: https://nodejs.org/en/download/package-manager/all"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add nodejs --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync nodejs --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install nodejs --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install ca-certificates --yes

        update_upgrade_apt
        sudo apt install curl --yes

        update_upgrade_apt
        sudo apt install gnupg --yes

        sudo mkdir --parents "/etc/apt/keyrings"

        curl \
            --fail \
            --silent \
            --show-error \
            --location "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" |
            sudo gpg --dearmor --output "/etc/apt/keyrings/nodesource.gpg"

        local -r node_version=20

        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] \
            https://deb.nodesource.com/node_$node_version.x nodistro main" |
            sudo tee /etc/apt/sources.list.d/nodesource.list

        update_upgrade_apt
        sudo apt install nodejs --yes
    fi

    node --version
}

function install_npm() {
    log_output "Installing the Node Package Manager for JavaScript development. Reference installation documentation: https://nodejs.org/en/download/package-manager/all"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add npm --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync npm --noconfirm
    # elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then # Fedora doesn't need npm to be installed, as nodejs contains npm.
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install npm --yes
    fi

    npm --version
}

function install_javascript_development_prerequisites() {
    install_nodejs_runtime
    install_npm
}



#######################################################################################################################
################################### Python Development Prerequisite Installation ######################################
#######################################################################################################################

function install_python3() {
    log_output "Installing Python 3. Reference installation documentation: https://www.geeksforgeeks.org/how-to-install-python-on-linux/"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add python3 --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync python --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install python3 --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install python3 --yes
    fi

    python --version
}

function install_python3_pip() {
    log_output "Installing Python 3 PIP. Reference installation documentation: https://www.tecmint.com/install-pip-in-linux/"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add py3-pip --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync python-pip --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install python3-pip --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install python3-pip --yes
    fi

    pip --version
}

function install_python_development_prerequisites() {
    install_python3
    install_python3_pip
}



#######################################################################################################################
#################################### Ruby Development Prerequisite Installation #######################################
#######################################################################################################################

function install_ruby() {
    log_output "Installing Ruby. Reference installation documentation: https://www.ruby-lang.org/en/documentation/installation/"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add ruby --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync ruby --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install ruby --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install ruby-full --yes
    fi

    ruby --version
}

function install_ruby_development_prerequisites() {
    install_ruby
}



#######################################################################################################################
###################################### Version Control Installation & Configuration ###################################
#######################################################################################################################

function install_git() {
    log_output "Installing Git. Reference installation documentation: https://git-scm.com/downloads/linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add git --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync git --noconfirm
        git --version
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install git --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install git --yes
    fi

    git --version
}

function configure_git_global_parameters() {
    log_output "Setting up Git with a default username and email."

    git config --global user.name "langleythomas"
    git config --global user.email "thomas.moorhead.langley@gmail.com"
}

function generate_github_ssh_key() {
    log_output "Generating SSH key for cloning private GitHub repositories."

    ssh-keygen -t ed25519 -C "thomas.moorhead.langley@gmail.com"

    eval "$(ssh-agent -s)"

    ssh-add ~/.ssh/id_ed25519

    log_output "Opening the generated ssh key."

    cat "${HOME}/.ssh/id_ed25519.pub"
}

function install_configure_version_control_tool() {
    install_git

    configure_git_global_parameters

    generate_github_ssh_key
}



#######################################################################################################################
###################################### Linux System Override Configuration ############################################
#######################################################################################################################

function configure_bashrc() {
    log_output "Configuring .bashrc."

    curl \
        "https://raw.githubusercontent.com/langleythomas/Software-Development-Notes/main/bash-configuration/.bashrc" \
        >> "${HOME}/.bashrc"

    # shellcheck disable=SC1090
    # shellcheck disable=SC1091
    source "${HOME}/.bashrc"
}

function configure_linux_system_overrides() {
    configure_bashrc
}



#######################################################################################################################
################################## Text Editors Installation & Configuration ##########################################
#######################################################################################################################

function install_vim() {
    log_output "Installing Vim. Reference installation documentation: https://tecadmin.net/install-vim-linux/"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add vim --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync vim --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install vim
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        log_output "\tNote: vim-gtk3 is being installed, as that supports copying and pasting to and from the system clipboard."
        log_output "\tvim-gnome is not being installed, as that is not in the repositories of the latest Ubuntu releases."

        sudo apt install vim-gtk3 --yes
    fi

    vim --version
}

function configure_vim() {
    local -r vimrc_file_path="${1}"
    local -r dot_vim_directory_path="${2}"

    log_output "Creating Vim configuration directories and configuration file."

    mkdir \
        --verbose \
        --parents \
        "${dot_vim_directory_path}" \
        "${dot_vim_directory_path}/autoload" \
        "${dot_vim_directory_path}/backup" \
        "${dot_vim_directory_path}/colors" \
        "${dot_vim_directory_path}/plugged"

    curl \
        "https://raw.githubusercontent.com/langleythomas/software-development-notes/main/vim-configuration/.vimrc" \
        >> "${vimrc_file_path}"

    # There is no need for a source command on the .vimrc file, as the .vimrc is automatically read and validated when
    # executing the vim command in a terminal.
}

function install_vundle() {
    local -r dot_vim_directory_path="${1}"

    log_output "Installing Vundle, the Vim package manager. Reference installation documentation: https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#installation--usage"

    git clone "https://github.com/VundleVim/Vundle.vim.git" "${dot_vim_directory_path}/bundle/Vundle.vim"
}

function install_vim_dracula_theme() {
    log_output "Installing the Dracula Vim theme, as documented in: https://draculatheme.com/vim"

    vim +PluginInstall +qall
}

function install_vim_markdown_preview() {
    log_output "Installing Vim plugins using Vundle. Reference installation documentation: https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#installation--usage"

    vim "${vimrc_file_path}" --cmd "source %" +qall
    vim +PluginInstall +qall
    vim "${vimrc_file_path}" -c "call mkdp#util#install()" +qall
}

function install_neovim() {
    log_output "Installing Neovim. Reference installation documentation: https://github.com/neovim/neovim/blob/master/INSTALL.md"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add neovim --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync neovim --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install neovim python3-neovim --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        log_output "Downloading Neovim AppImage."

        curl --location --remote-name "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
        chmod u+x "nvim.appimage"

        log_output "Moving Neovim Making it Globally Accessible."

        sudo mkdir --parents "/opt/nvim"
        sudo mv --verbose "nvim.appimage" "/opt/nvim/nvim"
    fi

    nvim --version
}

function configure_neovim() {
    local -r dot_config_neovim_directory_path="${HOME}/.config/nvim"

    log_output "Creating Neovim configuration directories and configuration files."

    mkdir  \
        --verbose \
        --parents \
        "${dot_config_neovim_directory_path}"

    curl \
        "https://raw.githubusercontent.com/langleythomas/software-development-notes/main/neovim-configuration/init.vim" \
        >> "${dot_config_neovim_directory_path}/init.vim"
}

function install_neovim_system_clipboard_dependency() {
    if [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        log_output "Installing xclip, in order to enable neovim's use of the system clipboard."

        update_upgrade_apt
        sudo apt install xclip --yes
    fi
}

function install_emacs() {
    log_output "Installing Emacs. Reference installation documentation: https://www.gnu.org/software/emacs/download.html"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add texinfo --yes

        update_upgrade_apk
        apk add emacs-docs --yes

        update_upgrade_apk
        apk add emacs --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync emacs --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install emacs --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install emacs --yes
    fi

    nvim --version
}

function install_sublime_text() {
    log_output "Installing Sublime Text Editor. Reference installation documentation: https://www.sublimetext.com/docs/linux_repositories.html"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        curl --remote-name "https://download.sublimetext.com/sublimehq-pub.gpg"
        sudo pacman-key --add "sublimehq-pub.gpg"
        sudo pacman-key --lsign-key 8A8F901A
        rm --verbose "sublimehq-pub.gpg"

        echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" \
            | sudo tee --append "/etc/pacman.conf"

        update_upgrade_pacman
        sudo pacman -Syu sublime-text --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        sudo rpm --verbose --import "https://download.sublimetext.com/sublimehq-rpm-pub.gpg"

        sudo dnf config-manager --add-repo "https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo"

        sudo dnf install sublime-text
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        wget --quiet -O - "https://download.sublimetext.com/sublimehq-pub.gpg" | gpg --dearmor | sudo tee "/etc/apt/trusted.gpg.d/sublimehq-archive.gpg" > /dev/null

        update_upgrade_apt
        sudo apt install "sublime-text"
    fi
}

function configure_sublime_text_settings() {
    log_output "Creating Sublime Text settings configuration file."

    curl \
        "https://raw.githubusercontent.com/langleythomas/Software-Development-Notes/refs/heads/main/sublime-text-configuration/Preferences.sublime-settings" \
        >> "${HOME}/.config/sublime-text/Packages/User/Preferences.sublime-settings"
}

function configure_sublime_text_packages() {
    log_output "Creating Sublime Text package configuration file."

    curl \
        "https://raw.githubusercontent.com/langleythomas/Software-Development-Notes/refs/heads/main/sublime-text-configuration/Package%20Control.sublime-settings" \
        >> "${HOME}/.config/sublime-text/Packages/User/Package Control.sublime-settings"

    curl \
        "https://raw.githubusercontent.com/langleythomas/Software-Development-Notes/refs/heads/main/sublime-text-configuration/Markdown.sublime-settings" \
        >> "${HOME}/.config/sublime-text/Packages/User/Markdown.sublime-settings"
}

function install_visual_studio_code() {
    log_output "Installing Visual Studio Code. Reference installation documentation: https://code.visualstudio.com/docs/setup/linux"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync visual-studio-code-bin --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install code --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install wget --yes

        update_upgrade_apt
        sudo apt install gpg --yes

        wget --quiet -output-document=- "https://packages.microsoft.com/keys/microsoft.asc" \
            | gpg --dearmor > "packages.microsoft.gpg"

        sudo install --directory \
            --owner=root \
            --group=root \
            --mode=644 \
            "packages.microsoft.gpg" \
            "/etc/apt/keyrings/packages.microsoft.gpg"

        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
            https://packages.microsoft.com/repos/code stable main" |
            sudo tee /etc/apt/sources.list.d/vscode.list > "/dev/null"

        rm \
            --force \
            --verbose \
            "packages.microsoft.gpg"

        update_upgrade_apt
        sudo apt install apt-transport-https --yes

        update_upgrade_apt
        sudo apt install code --yes

        # Execute the following command there is an issue loading the Visual Studio Code GUI after an update, as described
        # here: https://code.visualstudio.com/Docs/supporting/FAQ#_vs-code-is-blank:
        # rm --recursive "${HOME}/.config/Code/GPUCache"
    fi

    code --version
}

function install_configure_text_editors() {
    local -r vimrc_file_path="${HOME}/.vimrc"
    local -r dot_vim_directory_path="${HOME}/.vim"
    install_vim "${vimrc_file_path}" "${dot_vim_directory_path}"
    configure_vim "${vimrc_file_path}" "${dot_vim_directory_path}"
    install_vundle "${dot_vim_directory_path}"
    install_vim_dracula_theme
    install_vim_markdown_preview "${vimrc_file_path}"

    install_neovim
    configure_neovim
    install_neovim_system_clipboard_dependency

    install_emacs

    install_sublime_text
    configure_sublime_text_settings
    configure_sublime_text_packages

    install_visual_studio_code
}



#######################################################################################################################
################################# Integrated Development Environment (IDE) Installation ###############################
#######################################################################################################################

function install_intellij() {
    log_output "Installing IntelliJ IDEA Community Edition. Reference installation documentation: https://www.jetbrains.com/help/idea/installation-guide.html"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync intellij-idea-community-edition --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_snap
        sudo snap install intellij-idea-community --classic
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_snap
        sudo snap install intellij-idea-community --classic
    fi
}

function install_pycharm() {
    log_output "Installing PyCharm Community Edition. Reference installation documentation: https://www.jetbrains.com/help/pycharm/installation-guide.html"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync pycharm-community-edition --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_snap
        sudo snap install pycharm-community --classic
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_snap
        sudo snap install pycharm-community --classic
    fi
}

function install_integrated_development_environments() {
    install_intellij

    install_pycharm
}



#######################################################################################################################
############################################# Browser Installation ####################################################
#######################################################################################################################

function install_brave() {
    log_output "Installing Brave. Reference installation documentation: https://brave.com/linux/"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync brave-browser --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install dnf-plugins-core --yes

        update_dnf
        sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

        update_dnf
        sudo dnf install brave-browser --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install curl --yes

        sudo curl --fail --silent --show-error --location --output \
            "/usr/share/keyrings/brave-browser-archive-keyring.gpg" \
            "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
            | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

        update_upgrade_apt
        sudo apt install brave-browser --yes
    fi

    brave --version
}

function install_chromium() {
    log_output "Installing Chromium. Reference installation documentation: https://www.fosslinux.com/111944/how-to-install-chromium-web-browser-on-linux.htm"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add chromium --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync chromium --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install chromium-browser --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install chromium-browser --yes
    fi

    chromium --version
}

function install_browsers() {
    install_brave

    install_chromium
}



#######################################################################################################################
########################################## Social Platform Installation ###############################################
#######################################################################################################################

function install_discord() {
    log_output "Installing Discord. Reference installation documentation: https://wiki.archlinux.org/title/Discord"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync discord --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub com.discordapp.Discord --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub com.discordapp.Discord --assumeyes
    fi
}

function install_social_platforms() {
    install_discord
}



#######################################################################################################################
############################################ UI Tool Installation #####################################################
#######################################################################################################################

function install_gnome_tweaks() {
    local -r desktop_environment="${XDG_CURRENT_DESKTOP}"

    if [[ "${desktop_environment}" == *"GNOME"* ]]; then
        log_output "Installing GNOME Tweaks. Reference installation documentation: https://www.geeksforgeeks.org/install-gnome-tweaks-on-ubuntu/"

        if [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
            update_upgrade_apt
            sudo add-apt-repository universe

            update_upgrade_apt
            sudo apt install gnome-tweaks --yes
        fi
    fi
}

function install_ui_configuration_tools() {
    install_gnome_tweaks
}



#######################################################################################################################
############################################ Media Player Installation ################################################
#######################################################################################################################

function install_spotify() {
    log_output "Installing Spotify. Reference installation documentation: https://www.spotify.com/de-en/download/linux/, https://itsfoss.com/install-spotify-arch/"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync spotify-launcher --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub com.spotify.Client
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub com.spotify.Client
    fi

    spotify-launcher --version
}

function install_vlc() {
    log_output "Installing VLC. Reference installation documentation: https://www.videolan.org/vlc/"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add vlc --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync vlc --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub org.videolan.VLC --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub org.videolan.VLC --assumeyes
    fi

    vlc --version
}

function install_media_players() {
    install_spotify

    install_vlc
}



#######################################################################################################################
####################################### Terminal Installation & Configuration #########################################
#######################################################################################################################

function install_guake() {
    log_output "Installing Guake. Note: In order to launch Guake, hit the F12 key. Reference installation documentation: https://guake.readthedocs.io/en/stable/user/installing.html"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add guake --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync guake --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install guake --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install guake --yes
    fi

    guake --version
}

function configure_guake() {
    log_output "Configuring Guake."

    curl \
        "https://raw.githubusercontent.com/langleythomas/Software-Development-Notes/main/guake-configuration/guake_configuration.conf" \
        >> "${HOME}/Downloads/guake_configuration.conf"

    guake --restore-preferences="${HOME}/Downloads/guake_configuration.conf"
}

function install_warp() {
    log_output "Installing Guake. Note: In order to launch Guake, hit the F12 key. Reference installation documentation: https://guake.readthedocs.io/en/stable/user/installing.html"

#    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
#        update_upgrade_apk
#        apk add guake --yes
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
#        update_upgrade_pacman
#        sudo pacman --sync guake --noconfirm
        wget --output ~/"Downloads/warp-terminal.pkg.tar.zst" "https://app.warp.dev/download?package=pacman"

	sudo pacman -U ~/"Downloads/waro-terminal.pkg.tar.zst"

	sudo sh -c "echo -e '\n[warpdotdev]\nServer = https://releases.warp.dev/linux/pacman/\$repo/\$arch' >> /etc/pacman.conf"
	sudo pacman-key -r "linux-maintainers@warp.dev"
	sudo pacman-key --lsign-key "linux-maintainers@warp.dev"

	sudo pacman -Sy warp-terminal
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install guake --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install guake --yes
    fi

    guake --version
}

function install_configure_terminals() {
    install_guake
    configure_guake

    install_warp
}



#######################################################################################################################
####################################### Gaming Software & Utility Installation ########################################
#######################################################################################################################

function install_steam() {
    log_output "Installing Steam. Reference installation documentation: https://www.howtogeek.com/753511/how-to-download-and-install-steam-on-linux/"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yay --sync melonds --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

        update_dnf
        sudo dnf install steam --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo add-apt-repository "multiverse"

        update_upgrade_apt
        sudo apt install steam --yes
    fi
}

function install_gaming_software_utilities() {
    install_steam
}



#######################################################################################################################
############################################ Gaming Emulator Installation #############################################
#######################################################################################################################

# function install_gameboy_emulator() {
#     log_output "Installing the mGBA emulator, for GameBoy, GameBoy Color, and GameBoy Advance emulation. Reference installation documentation: https://mgba.io/downloads.html"

#     curl "https://github.com/mgba-emu/mgba/releases/download/0.10.4/mGBA-0.10.4-appimage-x64.appimage" \
#         --output "/home/${USER}/Downloads/mGBA-appimage-x64.appimage"

#     chmod u+x "/home/${USER}/Downloads/mGBA-appimage-x64.appimage"
# }

function install_ds_emulator() {
    log_output "Installing the melonDS, for Nintendo DS emulation. Reference installation documentation: https://melonds.kuribo64.net/downloads.php"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync melonds --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        update_flatpak
        flatpak install flathub net.kuribo64.melonDS --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        update_flatpak
        flatpak install flathub net.kuribo64.melonDS --assumeyes
    fi
}

function install_n64_emulator() {
    log_output "Installing the simple64 emulator, for N64 emulation. Reference installation documentation: https://linux-packages.com/aur/package/simple64, https://github.com/simple64/simple64/releases"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync simple64 --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub io.github.simple64.simple64 --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub io.github.simple64.simple64 --assumeyes
    fi
}

function install_gamecube_wii_emulator() {
    log_output "Installing the Dolphin emulator, for Nintendo GameCube and Wii emulation. Reference installation documentation: https://wiki.dolphin-emu.org/index.php?title=Installing_Dolphin"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add dolphin --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync dolphin-emu --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists "flathub" "https://dl.flathub.org/repo/flathub.flatpakrepo"

        update_flatpak
        flatpak install flathub org.DolphinEmu.dolphin-emu --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists "flathub" "https://dl.flathub.org/repo/flathub.flatpakrepo"

        update_flatpak
        flatpak install flathub org.DolphinEmu.dolphin-emu --assumeyes
    fi
}

function install_wii_u_emulator() {
    log_output "Installing the Cemu emulator, for Wii U emulation. Reference installation documentation: https://wiki.cemu.info/wiki/Installation_guide"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync cemu --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub info.cemu.Cemu --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub info.cemu.Cemu --assumeyes
    fi
}

# function install_switch_emulator() {
#     log_output "Installing the Suyu emulator. Reference installation documentation: https://suyu-emu.com/how-to-setup/"

#     curl "https://git.suyu.dev/suyu/suyu/releases/download/latest/Suyu-Linux_x86_64.AppImage" \
#         --output "/home/${USER}/Downloads/Suyu-Linux_x86_64.AppImage"

#     chmod u+x "/home/${USER}/Downloads/Suyu-Linux_x86_64.AppImage"
# }

function install_xbox_emulator() {
    log_output "Installing the Xemu emulator, for Xbox emulation. Reference installation documentation: https://xemu.app/docs"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync xemu --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install app.xemu.xemu --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install app.xemu.xemu --assumeyes
    fi
}

# function install_xbox_360_emulator() {
#     log_output "Installing the Xenia emulator, for Xbox 360 emulation. Setup guide: https://github.com/xenia-canary/xenia-canary/wiki/Quickstart"

#     if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then

#     elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then

#     elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then

#     elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then

#     fi
# }

function install_psp_emulator() {
    log_output "Installing the emulator, PlayStation Portable emulation. Reference installation documentation: https://www.ppsspp.org/download/"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add ppsspp --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync ppsspp --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub org.ppsspp.PPSSPP --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub org.ppsspp.PPSSPP --assumeyes
    fi
}

function install_playstation_emulator() {
    log_output "Installing the DuckStation emulator, for PlayStation emulation. Reference installation documentation: https://github.com/stenzek/duckstation?tab=readme-ov-file#linux"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync duckstation --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists flathub "https://dl.flathub.org/repo/flathub.flatpakrepo"

        update_flatpak
        flatpak install flathub org.duckstation.DuckStation --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists flathub "https://dl.flathub.org/repo/flathub.flatpakrepo"

        update_flatpak
        flatpak install flathub org.duckstation.DuckStation --assumeyes
    fi
}

function install_playstation_2_emulator() {
    log_output "Installing the PCXS2 emulator, for PlayStation 2 emulation. Reference installation documentation: https://pcsx2.net/downloads, https://flathub.org/apps/net.pcsx2.PCSX2"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_flatpak
        flatpak install net.pcsx2.PCSX2 --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install net.pcsx2.PCSX2 --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install net.pcsx2.PCSX2 --assumeyes
    fi
}

function install_playstation_3_emulator() {
    log_output "Installing the RPCS3 emulator, for PlayStation 3 emulation. Reference installation documentation: https://rpcs3.net/download, https://flathub.org/apps/net.rpcs3.RPCS3"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_flatpak
        flatpak install flathub net.rpcs3.RPCS3 --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub net.rpcs3.RPCS3 --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub net.rpcs3.RPCS3 --assumeyes
    fi
}

function install_emulators() {
    # GameBoy Emulator
    # install_gameboy_emulator

    # DS Emulator
    install_ds_emulator

    # N64 Emulator
    install_n64_emulator

    # GameCube & Wii Emulator
    install_gamecube_wii_emulator

    # Wii U Emulator
    install_wii_u_emulator

    # Switch Emulator
    # install_switch_emulator

    # Xbox Emulator
    install_xbox_emulator

    # # Xbox 360 Emulator
    # install_xbox_360_emulator

    # PlayStation Emulator
    install_playstation_emulator

    # PlayStation 2 Emulator
    install_playstation_2_emulator

    # PlayStation 3 Emulator
    install_playstation_3_emulator
}



#######################################################################################################################
######################################## Command Line Utility Installation  ###########################################
#######################################################################################################################

function install_okular() {
    log_output "Installing okular, a universal document viewer. Reference installation documentation: https://okular.kde.org/download/"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add okular --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync okular --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub org.kde.okular --assumeyes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub org.kde.okular --assumeyes
    fi

    okular --version
}

function install_document_viewer_utilities() {
    install_okular
}



#######################################################################################################################
######################################## Command Line Utility Installation  ###########################################
#######################################################################################################################

function install_bat() {
    log_output "Installing bat, a cat clone with syntax highlighting and Git integration. Reference installation documentation: https://github.com/sharkdp/bat"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add bat --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync bat --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install bat --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install bat --yes
    fi

    bat --version
}

function install_btop() {
    log_output "Installing btop, a resource monitor that show usage and stats for processor, memory, disks, networks, and processes. Reference installation documentation: https://github.com/aristocratos/btop"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add btop --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync btop --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install btop --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install btop --yes
    fi

    btop --version
}

function install_diff_so_fancy() {
    log_output "Installing diff-so-fancy, to identify human-readable differences between files. Reference installation documentation: https://github.com/so-fancy/diff-so-fancy?tab=readme-ov-file#install"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync diff-so-fancy --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install diff-so-fancy --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install diff-so-fancy --yes
    fi

    diff-so-fancy --help
}

function configure_diff_so_fancy_git_diff() {
    log_output "Configuring Git to use diff-so-fancy to identify all diff output. Reference installation documentation: https://github.com/so-fancy/diff-so-fancy?tab=readme-ov-file#with-git"

    git config --global core.pager "diff-so-fancy | less --tabs=4 -RF"
    git config --global interactive.diffFilter "diff-so-fancy --patch"
}

function install_dust() {
    log_output "Installing dust, providing an instant overview of which directories are using disk space without requiring sort or head. Reference installation documentation: https://github.com/bootandy/dust"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add dust --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync dust --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install dust --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install dust --yes
    fi

    dust --version
}

function install_eza() {
    log_output "Installing eza, a modern alternative to the ls program that ships with Unix and Linux operating systems. Reference installation documentation: https://github.com/eza-community/eza/blob/main/INSTALL.md"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add eza --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync eza --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install dust --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install eza --yes

        sudo mkdir --parents "/etc/apt/keyrings"
        wget --quiet --output "https://raw.githubusercontent.com/eza-community/eza/main/deb.asc" | sudo gpg --dearmor --output "/etc/apt/keyrings/gierens.gpg"
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 "/etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list"

        update_upgrade_apt
        sudo apt install eza --yes
    fi

    eza --version
}

function install_fastfetch() {
    log_output "Installing fastfetch, a \"Bash Screen Information Tool\" that auto-detects the system's distribution and some valuable information to the right. Reference installation documentation: https://github.com/fastfetch-cli/fastfetch?tab=readme-ov-file#linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add upgrade --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync fastfetch --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install fastfetch --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install fastfetch --yes
    fi

    fastfetch --version

    fastfetch
}

function install_fzf() {
    log_output "Installing fzf, a general-purpose command-line fuzzy finder. Reference installation documentation: https://github.com/junegunn/fzf?tab=readme-ov-file#installation"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add fzf --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync fzf --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install fzf --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install fzf --yes
    fi

    fzf --version
}

function install_kdash() {
    log_output "Installing kdash, a terminal dashboard for Kubernetes built with Rust. Reference installation documentation: https://github.com/kdash-rs/kdash?tab=readme-ov-file#installation"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync kdash --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install kdash --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        wget "https://github.com/kdash-rs/kdash/releases/download/v0.6.1/kdash-linux.tar.gz" \
            --output-document "${HOME}/Downloads/kdash-linux.tar.gz"

        sudo tar --directory="/usr/local/bin" --extract --gzip --file "${HOME}/Downloads/kdash-linux.tar.gz"
    fi

    kdash --version
}

function install_powershell() {
    log_output "Installing PowerShell. Reference installation documentation: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    sudo apk add --no-cache \
        ca-certificates \
        less \
        ncurses-terminfo-base \
        krb5-libs \
        libgcc \
        libintl \
        libssl3 \
        libstdc++ \
        tzdata \
        userspace-rcu \
        zlib \
        icu-libs \
        curl

        apk --repository "https://dl-cdn.alpinelinux.org/alpine/edge/main" add --no-cache \
            lttng-ust \
            openssh-client \

        # Download the powershell '.tar.gz' archive
        curl --location https://github.com/PowerShell/PowerShell/releases/download/v7.5.0/powershell-7.5.0-linux-musl-x64.tar.gz --output /tmp/powershell.tar.gz

        # Create the target folder where powershell will be placed
        sudo mkdir --parents "/opt/microsoft/powershell/7"

        # Expand powershell to the target folder
        sudo tar zxf "/tmp/powershell.tar.gz" -C "/opt/microsoft/powershell/7"

        # Set execute permissions
        sudo chmod +x "/opt/microsoft/powershell/7/pwsh"

        # Create the symbolic link that points to pwsh
        sudo ln -s "/opt/microsoft/powershell/7/pwsh" "/usr/bin/pwsh"
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync powershell --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        sudo rpm --import "https://packages.microsoft.com/keys/microsoft.asc"
        curl "https://packages.microsoft.com/config/rhel/7/prod.repo" | sudo tee "/etc/yum.repos.d/microsoft.repo"
        sudo dnf makecache --yes
        sudo dnf install powershell --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install wget --yes
        sudo apt install apt-transport-https --yes
        sudo apt install software-properties-common --yes

        # shellcheck disable=SC1091
        source "/etc/os-release"

        wget --quiet "https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb"

        sudo dpkg --install "packages-microsoft-prod.deb"

        rm "packages-microsoft-prod.deb"

        update_upgrade_apt
        sudo apt install powershell --yes
    fi

    pwsh --version
}

function install_procs() {
    log_output "Installing procs, a replacement for ps written in Rust. Reference installation documentation: https://github.com/dalance/procs?tab=readme-ov-file#installation"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add procs --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync procs --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install procs --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install procs --yes
    fi

    procs --version
}

function install_rip() {
    log_output "Installing rip, a command-line deletion tool focused on safety, ergonomics, and performance. Reference installation documentation: https://github.com/nivekuil/rip?tab=readme-ov-file#-installation"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync rm-improved --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        wget "https://github.com/nivekuil/rip/archive/refs/tags/0.13.1.tar.gz" --output-document "${HOME}/Downloads/rip.tar.gz"
        tar --extract --verbose --gzip --file "${HOME}/Downloads/rip.tar.gz" --directory "${HOME}/Downloads"
        sudo mv "${HOME}/Downloads/rip-0.13.1" /usr/local/bin
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        wget "https://github.com/nivekuil/rip/archive/refs/tags/0.13.1.tar.gz" --output-document "${HOME}/Downloads/rip.tar.gz"
        tar --extract --verbose --gzip --file "${HOME}/Downloads/rip.tar.gz" --directory "${HOME}/Downloads"
        sudo mv "${HOME}/Downloads/rip-0.13.1" /usr/local/bin
    fi

    rip --version
}

function install_ripgrep() {
    log_output "Installing ripgrep, a line-oriented search tool that recursively searches the current directory for a regex pattern. Reference installation documentation: https://github.com/BurntSushi/ripgrep?tab=readme-ov-file#installation"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add ripgrep --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync ripgrep --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install ripgrep --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install ripgrep --yes
    fi

    rg --version
}

function install_sd() {
    log_output "Installing sd, an intuitive find and replace CLI. Reference installation documentation: https://github.com/chmln/sd?tab=readme-ov-file#installation"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add sd --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync sd --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install sd --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install sd --yes
    fi

    sd --version
}

function install_tldr() {
    log_output "Installing tldr, a tool to output a collection of simpler, more-approachable complement to traditional man pages. Reference installation documentation: https://github.com/tldr-pages/tldr/wiki/Clients"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync tldr --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install tldr --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install tldr --yes
    fi

    tldr --version
}

function install_command_line_utilities() {
    install_bat

    install_btop

    install_diff_so_fancy
    configure_diff_so_fancy_git_diff

    install_dust

    install_eza

    install_fastfetch

    install_fzf

    install_kdash

    install_powershell

    install_procs

    install_rip

    install_ripgrep

    install_sd

    install_tldr
}



#######################################################################################################################
######################################### Installation of Hosted Hypervisors ##########################################
#######################################################################################################################

function install_bash_language_server() {
    log_output "Installing the bash language server. Reference installation documentation: https://github.com/bash-lsp/bash-language-server"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync bash-language-server --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        dnf install nodejs-bash-language-server --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_snap
        sudo snap install bash-language-server --classic
    fi
}

function install_marksman() {
    log_output "Installing marksman, a Markdown LSP. Reference installation documentation: https://github.com/artempyanykh/marksman"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync marksman --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_snap
        sudo snap install marksman --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_snap
        sudo snap install marksman --yes
    fi
}

function install_language_sever_protocols() {
    install_bash_language_server

    install_marksman
}



#######################################################################################################################
######################################### Installation of Hosted Hypervisors ##########################################
#######################################################################################################################

function install_virtualbox() {
    log_output "Installing VirtualBox, a hypervisor to run systems on a host computer. Reference installation documentation: https://www.virtualbox.org/wiki/Linux_Downloads"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync virtualbox --noconfirm
        sudo modprobe --remove kvm_intel
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install virtualbox --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install virtualbox --yes
    fi
}

function install_hosted_hypervisor() {
    install_virtualbox
}


#######################################################################################################################
###################################### Automatic Removal of Unused Dependencies #######################################
#######################################################################################################################

function autoremove_unused_dependencies() {
    log_output "Automatically removing unused dependencies."

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    # if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf autoremove --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt autoremove --yes
    fi
}

function remove_unused_dependencies() {
    autoremove_unused_dependencies
}



#######################################################################################################################
####################################### Terminal Installation & Configuration #########################################
#######################################################################################################################

function install_openrazer_daemon() {
    log_output "Installing OpenRazer Daemon to work with Polychromatic. Reference installation documentation: https://openrazer.github.io/#download"

    if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
        update_upgrade_apk
        apk add openrazer

        update_upgrade_apk
        apk add openrazer-src
    elif [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync openrazer-daemon --noconfirm

        update_upgrade_pacman
        sudo pacman --sync linux-headers --noconfirm

        sudo gpasswd --add "${USER}" plugdev
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf config-manager addrepo --from-repofile=https://openrazer.github.io/hardware:razer.repo

        update_dnf
        sudo dnf install openrazer-meta --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo add-apt-repository ppa:openrazer/stable

        update_upgrade_apt
        sudo add-apt-repository ppa:polychromatic/stable

        update_upgrade_apt
        sudo apt install openrazer-meta --yes
    fi
}

function install_polychromatic() {
    log_output "Installing Polychromatic. Reference installation documentation: https://polychromatic.app/download/"

    # if [[ "${LINUX_DISTRO_BASE}" == *"alpine"* ]]; then
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yay --sync polychromatic --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf config-manager addrepo --from-repofile=https://openrazer.github.io/hardware:razer.repo

        update_dnf
        sudo dnf install polychromatic --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        sudo add-apt-repository ppa:openrazer/stable
        sudo add-apt-repository ppa:polychromatic/stable

        update_upgrade_apt

        sudo apt install polychromatic --yes
    fi
}

function install_peripheral_tools() {
    install_openrazer_daemon
    install_polychromatic
}



#######################################################################################################################
########################################### Execute Other Functions ###################################################
#######################################################################################################################

# configure_graphics_drivers

# install_package_manager

# install_configure_deployment_tools

# install_dot_net_development_prerequisites

# install_javascript_development_prerequisites

# install_python_development_prerequisites

# install_ruby_development_prerequisites

# install_configure_version_control_tool

# configure_linux_system_overrides

# install_configure_text_editors

# install_integrated_development_environments

# install_browsers

# install_social_platforms

# install_ui_configuration_tools

# install_media_players

# install_configure_terminals

# install_gaming_software_utilities

# install_emulators

# install_document_viewer_utilities

# install_command_line_utilities

# install_language_sever_protocols

# install_hosted_hypervisor

# remove_unused_dependencies

# A restart is required after running these commands, in order for the changes to take effect.
# install_peripheral_tools
