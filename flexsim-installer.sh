#!/bin/bash

# Root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
if [[ -z "$SUDO_USER" ]]; then
   user=root
else
   user=$SUDO_USER
fi
home_user=$(getent passwd "$user" | cut -f6 -d:)

# SECTION TO DOWNLOAD THE BINARY
echo "IMPORTANT! UNTIL THE REPOSITORY IS PUBLIC, THIS SCRIPT ONLY INSTALLS DEPENDENCIES! YOU WILL NEED TO INSTALL THE BINARY YOURSELF"
# SECTION TO DOWNLOAD THE BINARY

# To enable root to check for scripts in local/bin
export PATH=$PATH:/usr/local/bin

# If kwokctl not installed -> install kwok and kwokctl
if ! command -v kwokctl &>/dev/null; then
    installedGo=false
    # If go not installed -> install Golang
    if ! sudo -u "$user" bash -i -c 'command -v go &>/dev/null'; then
        apt install golang -y
        installedGo=true
    fi

    GOOS=$(sudo -u "$user" bash -i -c 'go env GOOS')
    GOARCH=$(sudo -u "$user" bash -i -c 'go env GOARCH')

    echo "installing Kwok and Kwokctl"
    KWOK_REPO=kubernetes-sigs/kwok
    KWOK_LATEST_RELEASE=$(curl "https://api.github.com/repos/${KWOK_REPO}/releases/latest" | jq -r '.tag_name')
    wget -O kwokctl -c "https://github.com/${KWOK_REPO}/releases/download/${KWOK_LATEST_RELEASE}/kwokctl-$GOOS-$GOARCH"
    chmod +x kwokctl
    mv kwokctl /usr/local/bin/kwokctl
    wget -O kwok -c "https://github.com/${KWOK_REPO}/releases/download/${KWOK_LATEST_RELEASE}/kwok-$GOOS-$GOARCH"
    chmod +x kwok
    mv kwok /usr/local/bin/kwok
    if "$installedGo" -eq true; then
      apt remove golang -y
      apt autoremove -y
    fi
fi

# If tensorflow libraries not present -> install them
#if [ ! -f /usr/local/lib/libtensorflow.so.2 ]; then
#    echo "Installing tensorflow"
#    wget --no-check-certificate https://storage.googleapis.com/tensorflow/versions/2.17.0/libtensorflow-cpu-linux-x86_64.tar.gz
#    tar -xzf libtensorflow-cpu-linux-x86_64.tar.gz -C /usr/local
#    ldconfig /usr/local/lib
#fi

# If kubectl is not installed -> install kubectl
if ! command -v kubectl &>/dev/null; then
    echo "Installing kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -m 0755 kubectl /usr/local/bin/kubectl
fi

if ! command -v docker &>/dev/null; then
  distro=$(. /etc/os-release; echo "$ID")
  distro_like=$(. /etc/os-release; echo "$ID_LIKE")

  if [ "$distro" == "ubuntu" ] || [ "$distro" == "debian" ] || [[ "$distro_like" =~ "debian" ]]; then
    echo "Installing Docker for Debian"
    apt-get update -y
    apt-get install ca-certificates curl -y
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/$distro/gpg" -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$distro \
      $(lsb_release -cs) stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  elif [ "$distro" == "rhel" ]; then
    dnf -y install dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
    dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    systemctl enable --now docker
  elif [ "$distro" == "fedora" ]; then
    dnf -y install dnf-plugins-core
    dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    systemctl enable --now docker
  elif [ "$distro" == "centos" ]; then
    dnf -y install dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    systemctl enable --now docker
  elif [ "$distro" == "manjaro" ] || [[ "$distro_like" =~ "arch" ]]; then
    pacman -Sy --noconfirm docker docker-compose
    systemctl enable --now docker.service
  fi
  groupadd docker
  usermod -aG docker "$user"
fi

# Set required env in .bashrc (or equivalent)
function shell_env() {
  shell_name=$(basename "$(getent passwd "$user" | cut -d: -f7)")
  case "$shell_name" in
    bash)
      if ! grep -q "export LD_LIBRARY_PATH" "$home_user"/.bashrc; then
          echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" >> "$home_user"/.bashrc
      fi
      if ! grep -q "export TF_CPP_MIN_LOG_LEVEL" "$home_user"/.bashrc; then
          echo "export TF_CPP_MIN_LOG_LEVEL=3" >> "$home_user"/.bashrc
      fi
      if ! grep -q "source <(flexsim completion bash)" "$home_user"/.bashrc; then
          echo "source <(flexsim completion bash)" >> "$home_user"/.bashrc
      fi
      ;;
    zsh)
      if ! grep -q "export LD_LIBRARY_PATH" "$home_user"/.zshrc; then
          echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" >> "$home_user"/.zshrc
      fi
      if ! grep -q "export TF_CPP_MIN_LOG_LEVEL" "$home_user"/.zshrc; then
          echo "export TF_CPP_MIN_LOG_LEVEL=3" >> "$home_user"/.zshrc
      fi
      if ! grep -q "source <(flexsim completion zsh)" "$home_user"/.zshrc; then
          echo "source <(flexsim completion zsh)" >> "$home_user"/.zshrc
      fi
      ;;
    fish)
      if ! grep -q "export LD_LIBRARY_PATH" "$home_user"/.config/fish/config.fish; then
          echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" >> "$home_user"/.config/fish/config.fish
      fi
      if ! grep -q "export TF_CPP_MIN_LOG_LEVEL" "$home_user"/.config/fish/config.fish; then
          echo "export TF_CPP_MIN_LOG_LEVEL=3" >> "$home_user"/.config/fish/config.fish
      fi
      if ! grep -q "flexsim completion fish | source" "$home_user"/.config/fish/config.fish; then
          echo "flexsim completion fish | source" >> "$home_user"/.config/fish/config.fish
      fi
      ;;
    csh)
      if ! grep -q "setenv LD_LIBRARY_PATH" "$home_user"/.cshrc; then
          echo "setenv LD_LIBRARY_PAT $LD_LIBRARY_PATH:/usr/local/lib" >> "$home_user"/.cshrc
      fi
      if ! grep -q "setenv TF_CPP_MIN_LOG_LEVEL" "$home_user"/.cshrc; then
          echo "setenv TF_CPP_MIN_LOG_LEVEL 3" >> "$home_user"/.cshrc
      fi
      ;;
    tcsh)
      if ! grep -q "setenv LD_LIBRARY_PATH" "$home_user"/.tcshrc; then
          echo "setenv LD_LIBRARY_PAT $LD_LIBRARY_PATH:/usr/local/lib" >> "$home_user"/.tcshrc
      fi
      if ! grep -q "setenv TF_CPP_MIN_LOG_LEVEL" "$home_user"/.tcshrc; then
          echo "setenv TF_CPP_MIN_LOG_LEVEL 3" >> "$home_user"/.tcshrc
      fi
      ;;
    ksh)
      if ! grep -q "export LD_LIBRARY_PATH" "$home_user"/.kshrc; then
          echo "export LD_LIBRARY_PAT=$LD_LIBRARY_PATH:/usr/local/lib" >> "$home_user"/.kshrc
      fi
      if ! grep -q "export TF_CPP_MIN_LOG_LEVEL" "$home_user"/.kshrc; then
          echo "export TF_CPP_MIN_LOG_LEVEL=3" >> "$home_user"/.kshrc
      fi
      ;;
    *)
      echo "$shell_name not recognized, be sure to put 'export LD_LIBRARY_PAT=$LD_LIBRARY_PATH:/usr/local/lib' and 'export TF_CPP_MIN_LOG_LEVEL=3' in your .bashrc equivalent."
      ;;
      esac
}
shell_env

# Install Kind if not present
if ! command -v kind &>/dev/null; then
  # For AMD64 / x86_64
  [ "$(uname -m)" = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
  # For ARM64
  [ "$(uname -m)" = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-arm64
  chmod +x ./kind
  mv ./kind /usr/local/bin/kind
fi

# Install liqoctl if not present
if ! command -v liqoctl &>/dev/null; then
  curl --fail -LS "https://github.com/liqotech/liqo/releases/download/v1.0.1/liqoctl-linux-amd64.tar.gz" | tar -xz
  install -o root -g root -m 0755 liqoctl /usr/local/bin/liqoctl
  rm ./liqoctl
fi