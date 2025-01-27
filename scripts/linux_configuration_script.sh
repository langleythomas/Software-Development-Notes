#!/usr/bin/env bash

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
    local -r logger_output="${1}"

    print_separator
    printf "%s" "${logger_output}"
    print_separator
}



#######################################################################################################################
##########################################  Packaging Tool Refresh Functions ##########################################
#######################################################################################################################

function update_upgrade_apt() {
    sudo apt update
    sudo apt upgrade --yes
}

function update_flatpak() {
    flatpak update
}

function update_upgrade_pacman() {
    sudo pacman --sync --refresh --sysupgrade
}

function update_snap() {
    sudo snap refresh
}

function update_upgrade_aur() {
    yay --sync --refresh --sysupgrade
}



#######################################################################################################################
############################################# Graphics Driver Configuration ###########################################
#######################################################################################################################

function remove_nvidia_drivers() {
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync docker --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        # Run this command if there are issues booting into an Ubuntu installation. This failure could be caused by
        # Nvidia  driver issues. The commands in this function can resolve this issue. These commands can only be
        # effective in a fresh OS installation.

        log_output "Removing Nvidia drivers.\n"

        update_upgrade_apt

        sudo apt purge nvidia* --yes
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
    log_output "Installing Docker.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync docker --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        # Add Docker's official GPG key:
        sudo apt install ca-certificates --yes
        sudo apt show ca-certificates

        sudo apt install curl --yes
        sudo apt show curl

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
        sudo apt install docker-ce --yes
        sudo apt show docker-ce

        sudo apt install docker-ce-cli --yes
        sudo apt show docker-ce-cli

        sudo apt install containerd.io --yes
        sudo apt show containerd.io

        sudo apt install docker-buildx-plugin --yes
        sudo apt show docker-buildx-plugin

        sudo apt install docker-compose-plugin --yes
        sudo apt show docker-compose-plugin
    fi

    # Add user to Docker group
    sudo usermod --append --groups "docker" "${USER}"
    newgrp "docker"
}

function configure_docker_startup() {
    log_output "Starting Docker.\n"

    # Start Docker
    sudo systemctl start docker.service

    # Configure Docker to start up on initial system boot,
    sudo systemctl enable docker.service

    # Check status of the Docker daemon.
    systemctl status docker.service
}

function test_docker_installation() {
    log_output "Running a Test Docker Image.\n"

    sudo docker run hello-world
}

function install_minikube() {
    log_output "Installing Minikube.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync minikube --noconfirm
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
    log_output "Starting Minikube.\n"

    minikube start
}

function test_minikube_installation() {
    log_output "Testing Minikube Installation.\n"

    minikube status
}

function install_kubernetes() {
    log_output "Installing Kubernetes.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync kubectl --noconfirm
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
    log_output "Testing Kubernetes Installation.\n"

    kubectl version

    kubectl cluster-info
}

function install_helm() {
    log_output "Installing Helm.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync helm --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        local -r install_helm_file_name="get_helm.sh"

        curl "https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get-helm-3" > "${install_helm_file_name}"

        chmod 700 "${install_helm_file_name}"

        ./"${install_helm_file_name}"

        rm --force --verbose "${install_helm_file_name}"
    fi
}

function test_helm_installation() {
    log_output "Testing Helm Installation.\n"

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
    log_output "Installing the .NET SDK for C# development.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync dotnet-sdk --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        sudo dpkg --purge packages-microsoft-prod
        sudo dpkg --install packages-microsoft-prod.deb

        sudo apt install dotnet-sdk-7.0 --yes
        sudo apt show dotnet-sdk-7.0
    fi

    dotnet --list-sdks
    dotnet --info
}

function install_dot_net_runtime() {
    log_output "Installing the .NET Runtime for C# development.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync dotnet-runtime --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        sudo apt install aspnetcore-runtime-7.0 --yes
        sudo apt show aspnetcore-runtime-7.0
    fi

    dotnet --list-runtimes
    dotnet --info
}

function install_asp_net_runtime() {
    log_output "Installing the ASP .NET Runtime for C# development.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync aspnet-runtime --noconfirm
    fi

    dotnet --list-runtimes
    dotnet --info
}

function install_dot_net_development_prerequisites() {
    install_dot_net_sdk
    install_dot_net_runtime
    install_asp_net_runtime
}



#######################################################################################################################
################################# JavaScript Development Prerequisite Installation ####################################
#######################################################################################################################

function install_nodejs_runtime() {
    log_output "Installing the Node JS runtime for JavaScript development.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync nodejs --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        sudo apt install ca-certificates --yes
        sudo apt show ca-certificates

        sudo apt install curl --yes
        sudo apt show curl

        sudo apt install gnupg --yes
        sudo apt show gnupg

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

        sudo apt install nodejs --yes
        sudo apt show nodejs
    fi

    node --version
}

function install_npm() {
    log_output "Installing the Node Package Manager for JavaScript development.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync npm --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        sudo apt install npm --yes
        sudo apt show npm
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
    log_output "Installing Python 3.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync python --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        sudo apt install python3 --yes
        sudo apt show python3
    fi

    python --version
}

function install_python3_pip() {
    log_output "Installing Python 3 PIP.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync python-pip --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        sudo apt install python3-pip --yes
        sudo apt show python3-pip
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
    log_output "Installing Ruby.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync ruby --noconfirm
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
    log_output "Installing Git.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync git --noconfirm
        git --version
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        sudo apt install git --yes
        sudo apt show git
    fi

    git --version
}

function configure_git_global_parameters() {
    log_output "Setting up Git with a default username and email.\n"

    git config --global user.name "langleythomas"

    git config --global user.email "thomas.moorhead.langley@gmail.com"
}

function generate_github_ssh_key() {
    log_output "Generating SSH key for cloning private GitHub repositories.\n"

    ssh-keygen -t ed25519 -C "thomas.moorhead.langley@gmail.com"

    eval "$(ssh-agent -s)"

    ssh-add ~/.ssh/id_ed25519

    log_output "Opening the generated ssh key.\n"

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
    log_output "Configuring .bashrc.\n"

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
    log_output "Installing vim.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync vim --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        log_output "\tNote: vim-gtk3 is being installed, as that supports copying and pasting to and from the system clipboard\n."
        log_output "\tvim-gnome is not being installed, as that is not in the repositories of the latest Ubuntu releases.\n"

        sudo apt install vim-gtk3 --yes
        sudo apt show vim-gtk3
    fi

    vim --version
}

function configure_vim() {
    local -r vimrc_file_path="${1}"
    local -r dot_vim_directory_path="${2}"

    log_output "Creating Vim configuration directories and configuration file.\n"

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

    log_output "Installing Vundle, the Vim package manager, as documented in: https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#installation--usage\n"

    git clone "https://github.com/VundleVim/Vundle.vim.git" "${dot_vim_directory_path}/bundle/Vundle.vim"
}

function install_vim_dracula_theme() {
    log_output "Installing the Dracula Vim theme, as documented in: https://draculatheme.com/vim\n"

    vim +PluginInstall +qall
}

function install_vim_markdown_preview() {
    log_output "Installing Vim plugins using Vundle, as documented in: https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#installation--usage\n"

    vim "${vimrc_file_path}" --cmd "source %" +qall
    vim +PluginInstall +qall
    vim "${vimrc_file_path}" -c "call mkdp#util#install()" +qall
}

function install_neovim() {
    log_output "Installing Neovim.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync neovim --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        log_output "Downloading Neovim AppImage.\n"

        curl --location --remote-name "https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
        chmod u+x "nvim.appimage"

        log_output "Moving Neovim Making it Globally Accessible.\n"

        sudo mkdir --parents "/opt/nvim"
        sudo mv --verbose "nvim.appimage" "/opt/nvim/nvim"
    fi

    nvim --version
}

function configure_neovim() {
    local -r dot_config_neovim_directory_path="${HOME}/.config/nvim"

    log_output "Creating Neovim configuration directories and configuration files.\n"

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
        log_output "Installing xclip, in order to enable neovim's use of the system clipboard.\n"

        update_upgrade_apt

        sudo apt install xclip --yes
        sudo apt show xclip
    fi
}

function install_visual_studio_code() {
    log_output "Installing Visual Studio Code.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yay --sync visual-studio-code-bin --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt
        sudo apt install wget --yes
        sudo apt show wget

        update_upgrade_apt
        sudo apt install gpg --yes
        sudo apt show gpg

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
        sudo apt show apt-transport-https

        update_upgrade_apt
        sudo apt install code --yes
        sudo apt show code

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
    log_output "Installing IntelliJ IDEA Community Edition"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync intellij-idea-community-edition --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_snap

        sudo snap install intellij-idea-community --classic
    fi
}

function install_pycharm() {
    log_output "Installing PyCharm Community Edition"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync pycharm-community-edition --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_snap

        sudo snap install intellij-idea-community --classic
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
    log_output "Installing Brave\n"

    curl --fail --silent --show-error "https://dl.brave.com/install.sh" | sh
}

function install_browser() {
    install_brave
}



#######################################################################################################################
########################################## Social Platform Installation ###############################################
#######################################################################################################################

function install_discord() {
    log_output "Installing Discord.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync discord --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
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
    if [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        log_output "Installing GNOME Tweaks.\n"

        update_upgrade_apt

        sudo apt install gnome-tweaks
        sudo apt show gnome-tweaks
    fi
}

function install_ui_configuration_tools() {
    install_gnome_tweaks
}



#######################################################################################################################
############################################ Media Player Installation ################################################
#######################################################################################################################

function install_vlc() {
    log_output "Installing VLC.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync vlc --noconfirm
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
    log_output "Installing Guake. Note: In order to launch Guake, hit the F12 key.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync guake --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        sudo apt install guake --yes
        sudo apt show guake
    fi
}

function configure_guake() {
    log_output "Configuring Guake.\n"

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
    log_output "Installing OpenRazer Daemon to work with Polychromatic.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync openrazer-daemon --noconfirm
        sudo pacman --sync linux-headers --noconfirm
        sudo gpasswd --add "${USER}" plugdev
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_upgrade_apt

        sudo add-apt-repository ppa:openrazer/stable
        sudo add-apt-repository ppa:polychromatic/stable

        update_upgrade_apt

        sudo apt install polychromatic --yes
    fi
}

function install_polychromatic() {
    log_output "Installing Polychromatic.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yay --sync polychromatic --noconfirm
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
    log_output "Installing Steam.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yay --sync melonds --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        flatpak install flathub net.kuribo64.melonDS
    fi
}

function install_gaming_software_utilities() {
    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yay --sync steam --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_and_upgrade_apt

        sudo add-apt-repository "multiverse"

        update_and_upgrade_apt

        sudo apt install steam --yes
    fi
}



#######################################################################################################################
############################################ Gaming Emulator Installation #############################################
#######################################################################################################################

function install_gameboy_emulator() {
    log_output "Installing the emulator, for GameBoy, GameBoy Color, and GameBoy Advance emulation.\n"

    curl "https://github.com/mgba-emu/mgba/releases/download/0.10.4/mGBA-0.10.4-appimage-x64.appimage" \
        --output "mGBA-appimage-x64.appimage"
}

function install_ds_emulator() {
    log_output "Installing the melonDS, for Nintendo DS emulation.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yay --sync melonds --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        flatpak install flathub net.kuribo64.melonDS
    fi
}

function install_gamecube_wii_emulator() {
    log_output "Installing the Dolphin emulator, for Nintendo GameCube and Wii emulation.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        sudo pacman --sync cemu --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak

        flatpak remote-add --if-not-exists "flathub" "https://dl.flathub.org/repo/flathub.flatpakrepo"

        flatpak install flathub org.DolphinEmu.dolphin-emu --yes
    fi
}

function install_wii_u_emulator() {
    log_output "Installing the Cemu emulator, for Wii U emulation. Setup guide: https://wiki.cemu.info/wiki/Installation_guide\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync cemu --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak

        flatpak install flathub info.cemu.Cemu
    fi
}

function install_switch_emulator() {
    log_output "Installing the Suyu emulator. Setup guide: https://suyu-emu.com/how-to-setup/\n"

    curl "https://git.suyu.dev/suyu/suyu/releases/download/latest/Suyu-Linux_x86_64.AppImage" \
        --output "/home/${USER}/Downloads/Suyu-Linux_x86_64.AppImage"
}

function install_xbox_emulator() {
    log_output "Installing the Xemu emulator, for Xbox emulation. Setup guide: https://xemu.app/docs\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yay --sync xemu --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak

        flatpak install app.xemu.xemu --yes
    fi
}

# function install_xbox_360_emulator() {
#     log_output "Installing the Xenia emulator, for Xbox 360 emulation. Setup guide: https://github.com/xenia-canary/xenia-canary/wiki/Quickstart\n"

#     if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then

#     elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then

#     fi
# }

function install_psp_emulator() {
    log_output "Installing the emulator, PlayStation Portable emulation.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_pacman

        sudo pacman --sync ppsspp --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak

        flatpak install flathub org.ppsspp.PPSSPP
    fi
}

function install_playstation_emulator() {
    log_output "Installing the DuckStation emulator, for PlayStation emulation.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yarn --sync duckstation --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak

        flatpak remote-add --if-not-exists flathub "https://dl.flathub.org/repo/flathub.flatpakrepo"

        flatpak install flathub org.duckstation.DuckStation
    fi
}

function install_playstation2_emulator() {
    log_output "Installing the PCXS2 emulator, for PlayStation 2 emulation.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yarn --sync pcxs2 --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak

        flatpak install net.pcsx2.PCSX2
    fi
}

function install_playstation_3_emulator() {
    log_output "Installing the RPCS3 emulator, for PlayStation 3 emulation.\n"

    if [[ "${LINUX_DISTRO_BASE}" == *"arch"* ]]; then
        update_upgrade_aur

        yay --sync rpcs3 --noconfirm
    elif [[ "${LINUX_DISTRO_BASE}" == *"ubuntu"* ]]; then
        update_flatpak

        flatpak install flathub net.rpcs3.RPCS3
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
        log_output "Autoremoving Unused Dependencies.\n"

        update_and_upgrade_apt

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
