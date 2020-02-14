#!/bin/bash
releases="https://api.github.com/repos/BeyondTrust/pbis-open/releases/latest"
arch="x86_64" # or x86

pbis_open_url=`curl --silent $releases | grep -e "url.*$arch.deb.sh" | sed -E 's/.*"([^"]+)".*/\1/'`

if [ ! -f /opt/pbis/bin/domainjoin-cli ]; then
    echo "Baixando e instalando pbis-open"
    wget $pbis_open_url -O /tmp/pbis-open.sh
    chmod +x /tmp/pbis-open.sh
    /tmp//pbis-open.sh
fi

echo "Configurando"
/opt/pbis/bin/config LoginShellTemplate /bin/bash
/opt/pbis/bin/config HomeDirTemplate %H/%D/%U
/opt/pbis/bin/config AssumeDefaultDomain True

dlgtitle="Ingressar maquina no Active Directory"
computername=$(whiptail --inputbox "Digite o nome do computador" 8 78 --title $dlgtitle 3>&1 1>&2 2>&3)
if [ -z "$computername" ];then
    echo "Nome do computador não informado"
    exit 1
fi
/opt/pbis/bin/domainjoin-cli setname $computername
domain=$(whiptail --inputbox "Digite o Domínio do Active Directory" 8 78 --title $dlgtitle 3>&1 1>&2 2>&3)
if [ -z "$domain" ];then
    echo "Dominio não informado"
    exit 1
fi
echo "Ingressando no dominio"
/opt/pbis/bin/domainjoin-cli join $domain

if [ -d /etc/lightdm/lightdm.conf.d ];then
echo "Configurando lightdm"
echo > /etc/lightdm/lightdm.conf.d/00-hide-user-list.conf <<EOF
[SeatDefaults]
greeter-hide-users=true
greeter-show-manual-login=true
EOF
fi
