#!/usr/bin/env bash

#sudo apt install unzip -y

mkdir -p ~/.local/share/fonts

cd /tmp
fonts=(
"0xProto"
"Agave"
"CascadiaCode"
"CascadiaMono"
"CodeNewRoman"
"Cousine"
"DroidSansMono"
"FiraCode"
"FiraMono"
"Go-Mono" 
"Hack"  
"Inconsolata"
"InconsolataGo"
"InconsolataLGC"
"Iosevka"
"JetBrainsMono" 
"LiberationMono"
"Meslo"
"Mononoki" 
"NerdFontsSymbolsOnly"
"Noto"
"RobotoMono" 
"SourceCodePro" 
"Ubuntu"
"UbuntuMono"
"Terminus"
"VictorMono"
)

for font in ${fonts[@]}
do
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/$font.zip
	unzip $font.zip -d $HOME/.local/share/fonts/$font/
    rm $font.zip
done
fc-cache
