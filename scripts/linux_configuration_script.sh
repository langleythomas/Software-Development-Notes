#!/usr/bin/env bash

#######################################################################################################################
############################################## Linux Distros Tested & Used ############################################
#######################################################################################################################

# Arch:
# - EndeavourOS

# CentOS:
# - TBD

# Fedora:
# - TBD

# OpenSUSE:
# - TBD

# Red Hat:
# - TBD

# Ubuntu:
# - Zorin OS

#######################################################################################################################
############################################## Determine Linux Distro Base ############################################
#######################################################################################################################

LINUX_DISTRO_BASE=$(cat "/proc/version")
declare -r LINUX_DISTRO_BASE

#######################################################################################################################
################################################ Script Output Function ###############################################
#######################################################################################################################

function print_separator() {
    printf -- "-----------------------------------------------------------------------------------------------------------------------"
}

function log_output() {
    local -r output_message="${1}"

    print_separator
    echo "${output_message}"
    print_separator
}



#######################################################################################################################
##########################################  Packaging Tool Refresh Functions ##########################################
#######################################################################################################################

function update_dnf() {
    sudo dnf upgrade --yes
}

function update_flatpak() {
    flatpak update
}

function update_upgrade_apt() {
    sudo apt update
    sudo apt upgrade --yes
}

function update_upgrade_pacman() {
    sudo pacman --sync --refresh --sysupgrade --noconfirm
}

function update_snap() {
    sudo snap refresh
}

function update_upgrade_aur() {
    yay --sync --refresh --sysupgrade --noconfirm
}



#######################################################################################################################
############################################# Graphics Driver Configuration ###########################################
#######################################################################################################################

function remove_nvidia_drivers() {
    # if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then

    # elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then

    if [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
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
    remove_nvidia_drivers
}



#######################################################################################################################
###################################### Deployment Tools Installation & Configuration ##################################
#######################################################################################################################

function install_docker() {
    log_output "Installing Docker. Reference documentation: https://docs.docker.com/engine/install/"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync docker --noconfirm
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
    fi

    # Add user to Docker group
    sudo usermod --append --groups "docker" "${USER}"
    newgrp "docker"
}

function configure_docker_startup() {
    log_output "Starting Docker."

    # Start Docker
    sudo systemctl start docker

    # Configure Docker to start up on initial system boot,
    sudo systemctl enable --now docker

    # Check status of the Docker daemon.
    systemctl status docker
}

function test_docker_installation() {
    log_output "Running a Test Docker Image."

    sudo docker run hello-world
}

function install_minikube() {
    log_output "Installing Minikube. Reference documentation: https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
    log_output "Installing Kubernetes. Reference documentation: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
}

function test_kubernetes_installation() {
    log_output "Testing Kubernetes Installation."

    kubectl version
    kubectl cluster-info
}

function install_helm() {
    log_output "Installing Helm. Reference documentation: https://helm.sh/docs/intro/install/"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
    test_kubernetes_installation

    install_helm
    test_helm_installation
}



#######################################################################################################################
#################################### .NET Development Prerequisites Installation ######################################
#######################################################################################################################

function install_dot_net_sdk() {
    log_output "Installing the .NET SDK for C# development. Reference documentation: https://learn.microsoft.com/en-us/dotnet/core/install/linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
    log_output "Installing the ASP .NET Runtime for C# development. Reference documentation: https://learn.microsoft.com/en-us/dotnet/core/install/linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
    log_output "Installing the .NET Runtime for C# development. Reference documentation: https://learn.microsoft.com/en-us/dotnet/core/install/linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync dotnet-runtime --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install dotnet-runtime-9.0 --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_and_upgrade_apt
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
    log_output "Installing the Node JS runtime for JavaScript development. Reference documentation: https://nodejs.org/en/download/package-manager/all"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
    log_output "Installing the Node Package Manager for JavaScript development."

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
    log_output "Installing Python 3. Reference documentation: https://www.geeksforgeeks.org/how-to-install-python-on-linux/"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
    log_output "Installing Python 3 PIP. Reference documentation: https://www.tecmint.com/install-pip-in-linux/"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
    log_output "Installing Ruby. Reference documentation: https://www.ruby-lang.org/en/documentation/installation/"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
    log_output "Installing Git. Reference documentation: https://git-scm.com/downloads/linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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

    cat ~/.ssh/id_ed25519.pub
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
    log_output "Installing Vim."

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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

    # There is no need for a source command on the .vimrc, as the .vimrc is automatically read and validated when
    # executing the vim command in a terminal.
}

function install_vundle() {
    local -r dot_vim_directory_path="${1}"

    log_output "Installing Vundle, the Vim package manager. Reference documentation: https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#installation--usage"

    git clone "https://github.com/VundleVim/Vundle.vim.git" "${dot_vim_directory_path}/bundle/Vundle.vim"
}

function install_vim_dracula_theme() {
    log_output "Installing the Dracula Vim theme, as documented in: https://draculatheme.com/vim"

    vim +PluginInstall +qall
}

function install_vim_markdown_preview() {
    log_output "Installing Vim plugins using Vundle. Reference documentation: https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#installation--usage"

    vim "${vimrc_file_path}" --cmd "source %" +qall
    vim +PluginInstall +qall
    vim "${vimrc_file_path}" -c "call mkdp#util#install()" +qall
}

function install_neovim() {
    log_output "Installing Neovim. Reference documentation: https://github.com/neovim/neovim/blob/master/INSTALL.md"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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

    # There is no need for a source command on the init.vim, as the init.vim is automatically read and validated when
    # executing the vim command in a terminal.
}

function install_neovim_system_clipboard_dependency() {
    if [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        log_output "Installing xclip, in order to enable neovim's use of the system clipboard."

        update_upgrade_apt
        sudo apt install xclip --yes
    fi
}

function install_visual_studio_code() {
    log_output "Installing Visual Studio Code. Reference documentation: https://code.visualstudio.com/docs/setup/linux"

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

        sudo install -D \
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
        # rm -r ~/.config/Code/GPUCache
    fi
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

    install_visual_studio_code
}



#######################################################################################################################
################################# Integrated Development Environment (IDE) Installation ###############################
#######################################################################################################################

function install_intellij() {
    log_output "Installing IntelliJ IDEA Community Edition. Reference documentation: https://www.jetbrains.com/help/idea/installation-guide.html"

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
    log_output "Installing PyCharm Community Edition. Reference documentation: https://www.jetbrains.com/help/pycharm/installation-guide.html"

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
    log_output "Installing Brave. Reference documentation: https://brave.com/linux/"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync brave-browser --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install dnf-plugins-core --yes

        update_dnf
        sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

        update_dnf
        sudo dnf install brave-browser --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_and_upgrade_apt
        sudo apt install curl --yes

        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

        update_and_upgrade_apt
        sudo apt install brave-browser --yes
    fi
}

function install_browser() {
    install_brave
}



#######################################################################################################################
########################################## Social Platform Installation ###############################################
#######################################################################################################################

function install_discord() {
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        log_output "Installing Discord. Reference documentation: https://wiki.archlinux.org/title/Discord"

        update_upgrade_pacman
        sudo pacman --sync discord --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        log_output "Installing Discord. Reference documentation: https://flathub.org/apps/com.discordapp.Discord"

        update_flatpak
        flatpak install flathub com.discordapp.Discord --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        log_output "Installing Discord. Reference documentation: https://flathub.org/apps/com.discordapp.Discord"

        update_flatpak
        flatpak install flathub com.discordapp.Discord --yes
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
        log_output "Installing GNOME Tweaks. Reference documentation: https://www.geeksforgeeks.org/install-gnome-tweaks-on-ubuntu/"

        if [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
            update_and_upgrade_apt
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

function install_vlc() {
    log_output "Installing VLC. Reference documentation: https://www.videolan.org/vlc/"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync vlc --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub org.videolan.VLC --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub org.videolan.VLC --yes
    fi
}

function install_media_players() {
    install_vlc
}



#######################################################################################################################
####################################### Terminal Installation & Configuration #########################################
#######################################################################################################################

function install_guake() {
    log_output "Installing Guake. Note: In order to launch Guake, hit the F12 key. Reference documentation: https://guake.readthedocs.io/en/stable/user/installing.html"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync guake --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_dnf
        sudo dnf install guake --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install guake --yes
    fi
}

function configure_guake() {
    log_output "Configuring Guake."

    curl \
        "https://raw.githubusercontent.com/langleythomas/Software-Development-Notes/main/guake-configuration/guake_configuration.conf" \
        >> "${HOME}/Downloads/guake_configuration.conf"

    guake --restore-preferences="${HOME}/Downloads/guake_configuration.conf"
}

function install_configure_terminals() {
    install_guake
    configure_guake
}



#######################################################################################################################
####################################### Terminal Installation & Configuration #########################################
#######################################################################################################################

function install_openrazer_daemon() {
    log_output "Installing OpenRazer Daemon to work with Polychromatic. Reference documentation: https://openrazer.github.io/#download"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
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
    log_output "Installing Polychromatic. Reference documentation: https://polychromatic.app/download/"

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
####################################### Gaming Software & Utility Installation ########################################
#######################################################################################################################

function install_steam() {
    log_output "Installing Steam. Reference documentation: https://www.howtogeek.com/753511/how-to-download-and-install-steam-on-linux/"

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

function install_gameboy_emulator() {
    log_output "Installing the emulator, for GameBoy, GameBoy Color, and GameBoy Advance emulation. Reference documentation: https://mgba.io/downloads.html"

    curl "https://github.com/mgba-emu/mgba/releases/download/0.10.4/mGBA-0.10.4-appimage-x64.appimage" \
        --output "/home/${USER}/Downloads/mGBA-appimage-x64.appimage"

    chmod u+x "/home/${USER}/Downloads/mGBA-appimage-x64.appimage"
}

function install_ds_emulator() {
    log_output "Installing the melonDS, for Nintendo DS emulation. Reference documentation: https://melonds.kuribo64.net/downloads.php"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync melonds --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        update_flatpak
        flatpak install flathub net.kuribo64.melonDS --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        update_flatpak
        flatpak install flathub net.kuribo64.melonDS --yes
    fi
}

function install_gamecube_wii_emulator() {
    log_output "Installing the Dolphin emulator, for Nintendo GameCube and Wii emulation. Reference documentation: https://wiki.dolphin-emu.org/index.php?title=Installing_Dolphin"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        sudo pacman --sync cemu --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists "flathub" "https://dl.flathub.org/repo/flathub.flatpakrepo"

        update_flatpak
        flatpak install flathub org.DolphinEmu.dolphin-emu --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists "flathub" "https://dl.flathub.org/repo/flathub.flatpakrepo"

        update_flatpak
        flatpak install flathub org.DolphinEmu.dolphin-emu --yes
    fi
}

function install_wii_u_emulator() {
    log_output "Installing the Cemu emulator, for Wii U emulation. Reference documentation: https://wiki.cemu.info/wiki/Installation_guide"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync cemu --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub info.cemu.Cemu --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub info.cemu.Cemu --yes
    fi
}

function install_switch_emulator() {
    log_output "Installing the Suyu emulator. Reference documentation: https://suyu-emu.com/how-to-setup/"

    curl "https://git.suyu.dev/suyu/suyu/releases/download/latest/Suyu-Linux_x86_64.AppImage" \
        --output "/home/${USER}/Downloads/Suyu-Linux_x86_64.AppImage"

    chmod u+x "/home/${USER}/Downloads/Suyu-Linux_x86_64.AppImage"
}

function install_xbox_emulator() {
    log_output "Installing the Xemu emulator, for Xbox emulation. Reference documentation: https://xemu.app/docs"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync xemu --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install app.xemu.xemu --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install app.xemu.xemu --yes
    fi
}

# function install_xbox_360_emulator() {
#     log_output "Installing the Xenia emulator, for Xbox 360 emulation. Setup guide: https://github.com/xenia-canary/xenia-canary/wiki/Quickstart"

#     if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then

#     elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then

#     elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then

#     fi
# }

function install_psp_emulator() {
    log_output "Installing the emulator, PlayStation Portable emulation. Reference documentation: https://www.ppsspp.org/download/"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman
        sudo pacman --sync ppsspp --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub org.ppsspp.PPSSPP --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub org.ppsspp.PPSSPP --yes
    fi
}

function install_playstation_emulator() {
    log_output "Installing the DuckStation emulator, for PlayStation emulation. Reference documentation: https://github.com/stenzek/duckstation?tab=readme-ov-file#linux"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yarn --sync duckstation --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists flathub "https://dl.flathub.org/repo/flathub.flatpakrepo"

        update_flatpak
        flatpak install flathub org.duckstation.DuckStation --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak remote-add --if-not-exists flathub "https://dl.flathub.org/repo/flathub.flatpakrepo"

        update_flatpak
        flatpak install flathub org.duckstation.DuckStation --yes
    fi
}

function install_playstation2_emulator() {
    log_output "Installing the PCXS2 emulator, for PlayStation 2 emulation. Reference documentation: https://pcsx2.net/downloads"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yarn --sync pcxs2 --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install net.pcsx2.PCSX2 --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install net.pcsx2.PCSX2 --yes
    fi
}

function install_playstation_3_emulator() {
    log_output "Installing the RPCS3 emulator, for PlayStation 3 emulation. Reference documentation: https://rpcs3.net/download"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur
        yay --sync rpcs3 --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"fedora"* ]]; then
        update_flatpak
        flatpak install flathub net.rpcs3.RPCS3 --yes
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak
        flatpak install flathub net.rpcs3.RPCS3 --yes
    fi
}

function install_emulators() {
    # GameBoy Emulator
    install_gameboy_emulator

    # GameCube & Wii Emulator
    install_gamecube_wii_emulator

    # Wii U Emulator
    install_wii_u_emulator

    # Switch Emulator
    install_switch_emulator

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
##################### Automatic Removal of Dependencies from Debian Advanced Packaging Tool (APT) #####################
#######################################################################################################################

function autoremove_unused_dependencies() {
    if [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        log_output "Automatically removing unused dependencies."

        update_upgrade_apt
        sudo apt autoremove --yes
    fi

}

function remove_unused_dependencies() {
    autoremove_unused_dependencies
}



#######################################################################################################################
########################################### Execute Other Functions ###################################################
#######################################################################################################################

# configure_graphics_drivers

# install_configure_deployment_tools

# install_dot_net_development_prerequisites

# install_javascript_development_prerequisites

# install_python_development_prerequisites

# install_ruby_development_prerequisites

# install_configure_version_control_tool

# configure_linux_system_overrides

# install_configure_text_editors

# install_integrated_development_environments

# install_browser

# install_social_platforms

# install_ui_configuration_tools

# install_media_players

# install_configure_terminals

# A restart is required after running these commands, in order for the changes to take effect.
# install_peripheral_tools

# install_gaming_software_utilities

# install_emulators

# remove_unused_dependencies
