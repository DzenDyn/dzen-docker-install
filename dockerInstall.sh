#!/usr/bin/env bash
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

#Check root rights
if [[ "$USER" != "root" ]]; then
  echo "Restart with sudo or as root"
  exit
fi

if [[ "$SUDO_USER" != "" ]]; then
  echo -e "User ${GREEN}$SUDO_USER${NC} will be added to docker group"
  echo -e "Continue? (${GREEN}y${NC}/${RED}n${NC})"

  read -r n
  case $n in
    y|Y)
      ;;
    n|N)
      echo "Bye!"
      exit;;
  esac
fi


#apt update
echo "Updating package list with \"apt update\""
tmp=$(sudo apt-get update)

if [[ "$?" == "0" ]]; then
  echo -e "Update ${GREEN}OK${NC}"
else
  echo -e "Update ${RED}FAILED${NC}"
fi

#apt install
echo "Installing dependencies"
tmp=$(yes | sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release)

if [[ "$?" == "0" ]]; then
  echo -e "Dependencies install ${GREEN}OK${NC}"
else
  echo -e "Dependencies install ${RED}FAILED${NC}"
fi

#install docker's gpg key
echo "Add Docker's official GPG key"

tmp=$(curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg)
if [[ "$?" == "0" ]]; then
  echo -e "Add GPG key ${GREEN}OK${NC}"
else
  echo -e "Add GPG key ${RED}FAILED${NC}"
fi

echo "Select architecture:"
echo "1) x86_64 / amd64"
echo "2) armhf"
echo "3) arm64"
echo "4) s390x"
echo "5) quit"

read -r n
case $n in
  1)
    echo "Update sources.list"
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    echo -e "Update sources.list ${GREEN}OK${NC}"
    ;;
  2)
    echo "Update sources.list"
    echo \
      "deb [arch=armhf signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    echo -e "Update sources.list ${GREEN}OK${NC}"
    ;;
  3)
    echo "Update sources.list"
    echo \
      "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    echo -e "Update sources.list ${GREEN}OK${NC}"
    ;;
  4)
    echo "Update sources.list"
    echo \
      "deb [arch=s390x signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    echo -e "Update sources.list ${GREEN}OK${NC}"
    ;;
  5)
    echo "Bye!"
    exit
    ;;
  *)
    echo -e "${RED}Invalid input. Nothing to install${NC}" >&2
    sleep 2
    exit
    ;;
esac


#apt update again

echo "Updating package list with \"apt update\" again"
tmp=$(sudo apt-get update)

# shellcheck disable=SC2181
if [[ "$?" == "0" ]]; then
  echo -e "Update ${GREEN}OK${NC}"
else
  echo -e "Update ${RED}FAILED${NC}"
fi

#install docker
echo "Installing docker"
tmp=$(yes | sudo apt-get install \
    docker-ce \
    docker-ce-cli \
    containerd.io)

# shellcheck disable=SC2181
if [[ "$?" == "0" ]]; then
  echo -e "Docker install ${GREEN}OK${NC}"
else
  echo -e "Docker install ${RED}FAILED${NC}"
fi

#add user to docker group

if [[ "$SUDO_USER" != "" ]]; then
  echo "Add user ${SUDO_USER} to docker group"
  tmp=$(sudo usermod -aG docker ${SUDO_USER})
  # shellcheck disable=SC2181
  if [[ "$?" == "0" ]]; then
    echo -e "User add to docker group ${GREEN}OK${NC}"
  else
    echo -e "User add to docker group ${RED}FAILED${NC}"
  fi
fi

echo "Installing docker-compose"
tmp=$(curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose)
tmp=$(chmod +x /usr/local/bin/docker-compose)
# shellcheck disable=SC2181
if [[ "$?" == "0" ]]; then
  echo -e "Install docker-compose ${GREEN}OK${NC}"
else
  echo -e "Install docker-compose ${RED}FAILED${NC}"
fi
