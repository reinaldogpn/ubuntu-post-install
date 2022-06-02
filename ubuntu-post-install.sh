#!/usr/bin/env bash
#
# script_post_install_ubuntu.sh - Faz a pós configuração do Ubuntu 22.04.
# ------------------------------------------------------------------------ #
# O QUE ELE FAZ?
# Esse script instalar os programas que utilizo após a instalação do Ubuntu, faz upgrade
# e limpeza do sistema. É de fácil expensão (mudar variáveis).
#
# COMO USAR?
#   - Dar permissões ao arquivo script: chmod +x nome_do_arquivo ;
#   $ ./script_post_install_ubuntu.sh
#
# DICA:
#   - Para descompactar arquivos .tar.gz use:
#   tar -zxvf nome_do_arquivo.tar.gz 
# ------------------------------------------------------------------------ #
# Changelog:
#
#   v1.0 30/11/2019, Mateus Müller:
#     - Primeira versão com poucos programas.
#   v1.1 11/11/2021, Reinaldo Gonçalves:
#     - Inclusão de novos programas e adaptação do script para o meu uso pessoal.
#   v2.0 27/05/2022, Reinaldo Gonçalves:
#     - Correções, adaptações e adição de novos programas, além de pequenos aperfeiçoamentos.
#   v3.0 31/05/2022, Reinaldo Gonçalves:
#     - Adicionado suporte a pacotes flatpak; pacotes snap e .deb removidos; correções e melhorias.
# ------------------------------------------------------------------------ #
# Extras:
# 
# Link para download Foxit PDF Reader:
# - https://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/linux/2.x/2.4/en_us/FoxitReader.enu.setup.2.4.4.0911.x64.run.tar.gz
# Link para download Etcher (AppImage):
# - https://github.com/balena-io/etcher/releases/download/v1.7.9/balena-etcher-electron-1.7.9-linux-x64.zip?d_id=0d82ff50-dda3-4548-960a-8fa042ff69a4R
# Deezer Player (Unofficial):
# - sudo snap install deezer-unofficial-player
# ---------------------------- VARIÁVEIS --------------------------------- #
#
# ***** DIRETÓRIOS *****
DIRETORIO_PACOTES_TAR="$HOME/Downloads/PACOTES_TAR/"

# ***** PPAs *****
PPAs=(
ppa:allegro/5.2
ppa:codeblocks-devs/release
ppa:graphics-drivers/ppa
)

# ***** PROGRAMAS *****
PACOTES_APT=(
  dconf-editor
  flatpak
  git
  gnome-software-plugin-flatpak
  gnome-sushi
  gnome-tweaks
  gnome-weather
  codeblocks
  gimp
  inkscape
  keepassx
  liballegro5-dev
  neofetch
  qbittorrent
  virtualbox
  vlc
  steam-installer
  steam-devices
  steam:i386
  libvulkan1
  libvulkan1:i386
)

PACOTES_FLATPAK=(
  app.ytmdesktop.ytmdesktop
  com.calibre_ebook.calibre
  com.discordapp.Discord
  com.google.Chrome
  com.visualstudio.code
  io.github.mimbrero.WhatsAppDesktop
  io.atom.Atom
# org.codeblocks.codeblocks     # CodeBlocks
# com.spotify.Client            # Spotify
# com.valvesoftware.Steam 		  # Steam
# com.mojang.Minecraft 			    # Minecraft
# org.videolan.VLC 			        # VLC
# org.gimp.GIMP 			          # GIMP
# org.inkscape.Inkscape 		    # Inkscape
)

# ***** OUTROS *****
PACOTES_TAR=(
  https://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/linux/2.x/2.4/en_us/FoxitReader.enu.setup.2.4.4.0911.x64.run.tar.gz #Foxit PDF Reader
)

# ***** CORES *****
AMARELO='\e[1;93m'
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'

# ------------------------------ TESTES ---------------------------------- #
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

# ------------------------------ FUNÇÕES --------------------------------- #
remover_locks() 
{
  echo -e "${AMARELO}[INFO] - Removendo locks...${SEM_COR}"
  sudo rm /var/lib/dpkg/lock-frontend &> /dev/null
  sudo rm /var/cache/apt/archives/lock &> /dev/null
  echo -e "${VERDE}[INFO] - Locks removidos.${SEM_COR}"
}

adicionar_arquitetura_i386() 
{
  echo -e "${AMARELO}[INFO] - Adicionando arquitetura i386...${SEM_COR}"
  sudo dpkg --add-architecture i386 &> /dev/null
}

adicionar_ppas()
{
  for url in ${PPAs[@]}; do
    echo -e "${AMARELO}[INFO] - Adicionando repositório $url...${SEM_COR}"
    sudo apt-add-repository $url -y &> /dev/null
  done
  echo -e "${VERDE}[INFO] - Nada mais a adicionar.${SEM_COR}"
}

atualizar_repositorios()
{
  echo -e "${AMARELO}[INFO] - Atualizando repositórios ...${SEM_COR}"
  sudo apt update -y &> /dev/null
}

instalar_pacotes_tar()
{
  echo -e "${AMARELO}[INFO] - Baixando e instalando pacotes .tar...${SEM_COR}"
  [[ ! -d "$DIRETORIO_PACOTES_TAR" ]] && mkdir "$DIRETORIO_PACOTES_TAR"
  for url in ${PACOTES_TAR[@]}; do
    cd $DIRETORIO_PACOTES_TAR
    echo -e "${AMARELO}[INFO] - Baixando o pacote ${url##*/}...${SEM_COR}"
    echo -e "${AMARELO}[INFO] - Isso pode levar alguns minutos...${SEM_COR}"
    wget -c $url -P $DIRETORIO_PACOTES_TAR/${url##*/} &> /dev/null
    cd $DIRETORIO_PACOTES_TAR/${url##*/}
    echo -e "${AMARELO}[INFO] - Descompactando o pacote ${url##*/}...${SEM_COR}"
    tar -vzxf ${url##*/} &> /dev/null
    echo -e "${AMARELO}[INFO] - Instalando o pacote ${url##*/}...${SEM_COR}"
    ./*.run &> /dev/null
    echo -e "${VERDE}[INFO] - O pacote ${url##*/} foi instalado.${SEM_COR}"
  done
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

instalar_dependencias_allegro()
{
  echo -e "${AMARELO}[INFO] - Instalando dependências do Allegro ...${SEM_COR}"
  sudo apt install -y cmake g++ freeglut3-dev libxcursor-dev libpng-dev libjpeg-dev libfreetype6-dev libgtk2.0-dev libasound2-dev libpulse-dev libopenal-dev libflac-dev libdumb1-dev libvorbis-dev libphysfs-dev &> /dev/null
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
  git clone https://github.com/aircrack-ng/rtl8812au.git &> /dev/null
  cd rtl8812au
  sudo make dkms_install &> /dev/null
#  se a instalação for abortada, executar o comando: "sudo dkms remove 8812au/5.6.4.2_35491.20191025 --all" , se der erro... "usar: remove / --all"
  echo -e "${VERDE}[INFO] - Driver wi-fi instalado!${SEM_COR}"
}

upgrade_e_limpeza_sistema()
{
  echo -e "${AMARELO}[INFO] - Fazendo upgrade e limpeza do sistema ...${SEM_COR}"
  sudo apt dist-upgrade -y &> /dev/null
  sudo apt autoclean &> /dev/null
  sudo apt autoremove -y &> /dev/null
  rm -rf $DIRETORIO_PACOTES_TAR &> /dev/null
  sudo flatpak update -y &> /dev/null
  neofetch
  echo -e "${VERDE}[INFO] - Configuração concluída!${SEM_COR}"
  echo -e "${AMARELO}[INFO] - Reinicialização necessária, deseja reiniciar agora? [S/n]:${SEM_COR}"
  read opcao
  [ $opcao = "s" ] || [ $opcao = "S" ] && echo -e "${AMARELO}[INFO] - Fim do script! Reiniciando agora...${SEM_COR}" && reboot
  echo -e "${VERDE}[INFO] - Fim do script! ${SEM_COR}"
}

# ----------------------------- EXECUÇÃO --------------------------------- #
remover_locks
adicionar_arquitetura_i386
adicionar_ppas
atualizar_repositorios
instalar_pacotes_tar
instalar_pacotes_apt
instalar_dependencias_allegro
adicionar_repositorios_flatpak
instalar_pacotes_flatpak
#instalar_driver_TPLinkT2UPlus
upgrade_e_limpeza_sistema
# ------------------------------------------------------------------------ #
