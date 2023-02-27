#!/usr/bin/env bash
#
# script_post_install_ubuntu.sh - Faz a pós instalação do Ubuntu >= 20.04 LTS.
# ------------------------------------------------------------------------ #
# O QUE ELE FAZ?
# - Esse script instala os programas que utilizo no Ubuntu de forma 100% automática e com 0 interação com o usuário, faz upgrade
#   e limpeza do sistema e é de fácil manutenção.
#
# COMO USAR?
#   - Dar permissões ao arquivo script: chmod +x nome_do_arquivo:
#	- chmod +x ubuntu-post-install.sh
#
#   - Executar o script:
#   	- ./ubuntu-post-install.sh
#
# DICA:
#   - Para descompactar arquivos .tar.gz use:
#   tar -zxvf nome_do_arquivo.tar.gz 
# ------------------------------------------------------------------------ #
# Changelog:
#
#   v1.0 11/11/2021, reinaldogpn:
#     - Inclusão de novos programas e adaptação do script para o meu uso pessoal.
#   v2.0 27/05/2022, reinaldogpn:
#     - Correções, adaptações e adição de novos programas, além de pequenos aperfeiçoamentos.
#   v3.0 31/05/2022, reinaldogpn:
#     - Adicionado suporte a pacotes flatpak; pacotes snap e .deb removidos; correções e melhorias.
#   v3.1 19/06/2022, reinaldogpn:
#     - Remoção de pacotes desnecessários e atualização geral do script.
#   v3.2 31/10/2022, reinaldogpn:
#     - (Re)Adição de alguns pacotes .deb e adição do flatpak Bottles em substituição ao Wine.
#
# ------------------------------------------------------------------------ #
# Extras:
# 
# Fix for LoL "Critical Error":
# - sudo sysctl -w abi.vsyscall32=0 && lutris
#
# Disable 2K Louncher on Steam's Civilization VI init options:
# - eval $( echo "%command%" | sed "s/2KLauncher\/LauncherPatcher.exe'.*/Base\/Binaries\/Win64Steam\/CivilizationVI.exe'/" )
#
# Steam's Counter Strike Global Offensive init options:
# - -tickrate 128 +fps_max 0 -nojoy -novid -fullscreen -r_emulate_gl -limitvsconst -forcenovsync -softparticlesdefaultoff +mat_queue_mode 2 +mat_disable_fancy_blending 1 +r_dynamic 0 -refresh 75
#
# Bottles's permission to add programs shortcut to desktop:
# - flatpak override com.usebottles.bottles --user --filesystem=xdg-data/applications
#
# Install Zotero .deb version:
# - https://github.com/retorquere/zotero-deb#installing-zotero--juris-m
#
# VBox Extension Pack:
# - https://download.virtualbox.org/virtualbox/7.0.2/Oracle_VM_VirtualBox_Extension_Pack-7.0.2.vbox-extpack
#
# Wimlib (Woeusb) requirements:
# - sudo apt install libxml2-dev libfuse-dev ntfs-3g-dev
# - Download Wimlib (https://wimlib.net); extrair; ./configure; make; make install;
# - git clone https://github.com/WoeUSB/WoeUSB
# ---------------------------- VARIÁVEIS --------------------------------- #

# ***** PROGRAMAS *****
PACOTES_APT=(
  calibre
  codeblocks
  dconf-editor
  drawing
  flatpak
  chrome-gnome-shell
  filezilla
  gnome-calendar
  gnome-extensions
  gnome-photos
  gnome-software
  gnome-software-plugin-flatpak
  gnome-sushi
  gnome-tweaks
  gnome-weather
  nautilus-dropbox
  neofetch
  pinhole
  plocate
  qbittorrent
  rhythmbox
  virtualbox
  vlc
  zotero
)

PACOTES_DEB=(
# Chrome
  "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
# Discord
  "https://dl.discordapp.net/apps/linux/0.0.21/discord-0.0.21.deb"
# Visual Studio Code
  "https://az764295.vo.msecnd.net/stable/3b889b090b5ad5793f524b5d1d39fda662b96a2a/code_1.69.2-1658162013_amd64.deb"
)

DIRETORIO_DOWNLOAD_DEB="/home/$USER/Downloads/PACOTES_DEB"

PACOTES_FLATPAK=(
  com.spotify.Client                    # Spotify
  com.usebottles.bottles                # Bottles
  com.getmailspring.Mailspring          # Mailspring
  io.github.mimbrero.WhatsAppDesktop    # Whatsapp
  org.gtk.Gtk3theme.Yaru-dark           # Yaru-dark theme
  org.gnome.Epiphany                    # Epiphany (Gnome Web)
  org.onlyoffice.desktopeditors         # OnlyOffice
)

PACOTES_GAMES=(
  libvulkan1
  libvulkan1:i386
  lutris
  steam-installer
  steam-devices
  steam:i386
  wine
)

# ***** CORES *****
AMARELO='\e[1;93m'
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'

# ***** EXTRA *****
FILE="/home/$USER/.config/gtk-3.0/bookmarks"

# Adicionar o diretório e o alias respectivamente
DIRETORIOS=(
/home/$USER/Projetos
)

ALIASES=(
"/home/$USER/Projetos Projetos"
"/home/$USER/Dropbox Dropbox"
)

# ------------------------------ FUNÇÕES --------------------------------- #
realizar_testes()
{
# Internet conectando?
if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
  echo -e "${VERMELHO}[ERROR] - Seu computador não tem conexão com a internet. Verifique os cabos e o modem.${SEM_COR}"
  exit 1
else
  echo -e "${VERDE}[INFO] - Conexão com a internet funcionando normalmente.${SEM_COR}"
fi

# wget está instalado?
if [[ ! -x $(which wget) ]]; then
  echo -e "${VERMELHO}[ERROR] - O programa wget não está instalado.${SEM_COR}"
  echo -e "${AMARELO}[INFO] - Instalando wget ...${SEM_COR}"
  sudo apt install wget -y &> /dev/null
else
  echo -e "${VERDE}[INFO] - O programa wget já está instalado.${SEM_COR}"
fi
}

remover_locks() 
{
  echo -e "${AMARELO}[INFO] - Removendo locks...${SEM_COR}"
  sudo rm /var/lib/dpkg/lock-frontend &> /dev/null
  sudo rm /var/cache/apt/archives/lock &> /dev/null
  echo -e "${VERDE}[INFO] - Locks removidos.${SEM_COR}"
}

adicionar_arquitetura_i386() 
{
  wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh
  echo -e "${AMARELO}[INFO] - Adicionando arquitetura i386...${SEM_COR}"
  sudo dpkg --add-architecture i386 &> /dev/null
}

atualizar_repositorios()
{
  echo -e "${AMARELO}[INFO] - Atualizando repositórios ...${SEM_COR}"
  curl -sL https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | sudo bash &> /dev/null # Adds Zotero's repository
  sudo apt update -y &> /dev/null
}

instalar_pacotes_apt()
{
  echo -e "${AMARELO}[INFO] - Instalando pacotes apt ...${SEM_COR}"
  for pacote in ${PACOTES_APT[@]}; do
    if ! dpkg -l | grep -q $pacote; then
      echo -e "${AMARELO}[INFO] - Instalando o pacote $pacote ...${SEM_COR}"
      sudo apt install $pacote -y &> /dev/null
      if dpkg -l | grep -q $pacote; then
        echo -e "${VERDE}[INFO] - O pacote $pacote foi instalado.${SEM_COR}"
      else
        echo -e "${VERMELHO}[ERROR] - O pacote $pacote não foi instalado.${SEM_COR}"
      fi
    else
      echo -e "${VERDE}[INFO] - O pacote $pacote já está instalado.${SEM_COR}"
    fi
  done
}

instalar_pacotes_deb()
{
  echo -e "${AMARELO}[INFO] - Baixando pacotes .deb ...${SEM_COR}"
  for url in ${PACOTES_DEB[@]}; do
    wget -c "$url" -P "$DIRETORIO_DOWNLOAD_DEB" &> /dev/null
  done
  echo -e "${AMARELO}[INFO] - Instalando pacotes .deb baixados ...${SEM_COR}"
  sudo dpkg -i $DIRETORIO_DOWNLOAD_DEB/*.deb &> /dev/null
  sudo apt --fix-broken install -y &> /dev/null
}

instalar_dependencias_allegro()
{
  echo -e "${AMARELO}[INFO] - Instalando dependências do Allegro ...${SEM_COR}"
  sudo apt install -y liballegro5-dev cmake g++ freeglut3-dev libxcursor-dev libpng-dev libjpeg-dev libfreetype6-dev libgtk2.0-dev libasound2-dev libpulse-dev libopenal-dev libflac-dev libdumb1-dev libvorbis-dev libphysfs-dev &> /dev/null
}

adicionar_repositorios_flatpak()
{
  echo -e "${AMARELO}[INFO] - Adicionando repositórios flatpak com o remote-add...${SEM_COR}"
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  echo -e "${VERDE}[INFO] - Nada mais a adicionar.${SEM_COR}"
}

instalar_pacotes_flatpak()
{
  echo -e "${AMARELO}[INFO] - Instalando pacotes flatpak...${SEM_COR}"
  for pacote in ${PACOTES_FLATPAK[@]}; do
    if ! flatpak list | grep -q $pacote; then
      echo -e "${AMARELO}[INFO] - Instalando o pacote $pacote...${SEM_COR}"
      sudo flatpak install -y flathub $pacote &> /dev/null
      if flatpak list | grep -q $pacote; then
        echo -e "${VERDE}[INFO] - O pacote $pacote foi instalado.${SEM_COR}"
      else
        echo -e "${VERMELHO}[ERROR] - O pacote $pacote não foi instalado.${SEM_COR}"
      fi
    else
      echo -e "${VERDE}[INFO] - O pacote $pacote já está instalado.${SEM_COR}"
    fi
  done
}

instalar_driver_TPLinkT2UPlus()
{
#  (Instalação opcional) Driver do adaptador wireless TPLink Archer T2U Plus
  echo -e "${AMARELO}[INFO] - Instalando driver wi-fi TPLink...${SEM_COR}"
  sudo apt install -y dkms git &> /dev/null
  sudo apt install -y build-essential libelf-dev linux-headers-$(uname -r) &> /dev/null
  mkdir $HOME/Downloads/rtl8812au/
  git clone https://github.com/aircrack-ng/rtl8812au.git $HOME/Downloads/rtl8812au/ &> /dev/null
  cd $HOME/Downloads/rtl8812au/
  sudo make dkms_install &> /dev/null
#  se a instalação for abortada, executar o comando: "sudo dkms remove 8812au/5.6.4.2_35491.20191025 --all"
  echo -e "${VERDE}[INFO] - Driver wi-fi instalado!${SEM_COR}"
}

instalar_suporte_games()
{
  echo -e "${AMARELO}[INFO] - Instalando pacotes e drivers de suporte a games ...${SEM_COR}"
  for pacote in ${PACOTES_GAMES[@]}; do
    if ! dpkg -l | grep -q $pacote; then
      echo -e "${AMARELO}[INFO] - Instalando o pacote $pacote ...${SEM_COR}"
      sudo apt install $pacote -y &> /dev/null
      if dpkg -l | grep -q $pacote; then
        echo -e "${VERDE}[INFO] - O pacote $pacote foi instalado.${SEM_COR}"
      else
        echo -e "${VERMELHO}[ERROR] - O pacote $pacote não foi instalado.${SEM_COR}"
      fi
    else
      echo -e "${VERDE}[INFO] - O pacote $pacote já está instalado.${SEM_COR}"
    fi
  done
}

extra_config()
{
#  Cria pastas úteis e adiciona atalhos ao Nautilus
  echo -e "${AMARELO}[INFO] - Criando diretórios pessoais...${SEM_COR}"
  if test -f "$FILE"; then
      echo -e "${VERDE}[INFO] - $FILE já existe.${SEM_COR}"
  else
      echo -e "${AMARELO}[INFO] - $FILE não existe. Criando...${SEM_COR}"
      touch /home/$USER/.config/gkt-3.0/bookmarks &> /dev/null
  fi
  for diretorio in ${DIRETORIOS[@]}; do
    mkdir $diretorio
  done
  for _alias in "${ALIASES[@]}"; do
    echo file://$_alias >> $FILE
  done
}

upgrade_e_limpeza_sistema()
{
  echo -e "${AMARELO}[INFO] - Fazendo upgrade e limpeza do sistema ...${SEM_COR}"
  sudo apt dist-upgrade -y &> /dev/null
  sudo flatpak update -y &> /dev/null
  sudo snap refresh &> /dev/null
  sudo apt autoclean &> /dev/null
  sudo apt autoremove -y &> /dev/null
  rm -rf $HOME/Downloads/rtl8812au $DIRETORIO_DOWNLOAD_DEB &> /dev/null
  neofetch
  echo -e "${VERDE}[INFO] - Configuração concluída!${SEM_COR}"
  echo -e "${AMARELO}[INFO] - Reinicialização necessária, deseja reiniciar agora? [S/n]:${SEM_COR}"
  read opcao
  [ $opcao = "s" ] || [ $opcao = "S" ] && echo -e "${AMARELO}[INFO] - Fim do script! Reiniciando agora...${SEM_COR}" && reboot
  echo -e "${VERDE}[INFO] - Fim do script! ${SEM_COR}"
}

# ----------------------------- EXECUÇÃO --------------------------------- #
realizar_testes
remover_locks
adicionar_arquitetura_i386
atualizar_repositorios
instalar_pacotes_apt
instalar_pacotes_deb
#instalar_dependencias_allegro
adicionar_repositorios_flatpak
instalar_pacotes_flatpak
instalar_driver_TPLinkT2UPlus
#instalar_suporte_games
extra_config
upgrade_e_limpeza_sistema
