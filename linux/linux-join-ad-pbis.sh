#!/bin/bash
pbis_open_url="https://github.com/BeyondTrust/pbis-open/releases/download/9.0.1/pbis-open-9.0.1.525.linux.x86_64.deb.sh"

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

echo "Configurando lightdm"
echo > /etc/lightdm/lightdm.conf.d/00-hide-user-list.conf <<EOF
[SeatDefaults]
greeter-hide-users=true
greeter-show-manual-login=true
EOF
