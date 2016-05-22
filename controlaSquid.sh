#!/bin/bash
#criado em 13/05/2010 @author - Denilson Martins

clear
ControlaSquid() {
	echo "##############################################################"
	echo "#              CONTROLADOR BASICO DO SQUID:                  #"
	echo "# ---------------------------------------------------------- #"
	echo "#  1 PARA INCLUIR SITE LIBERADO:                             #"
	echo "#  2 PARA INCLUIR SITE BLOQUEADO:                            #"
	echo "#  3 PARA SAIR:                                              #"
	echo "#  DIGITE A OPCAO:                                           #"
	echo "#____________________________________________________________#"
	read op
	case $op in
		1) Liberar ;;
		2) Bloquear ;;
		3) exit ;;
		*) echo "DIGITE UMA OPCAO VALIDA" ; echo ; ControlaSquid ;;
	esac
}
echo
# liberar site opcao 1
Liberar() {
	echo "##############################################################"
	echo "DIGITE O SITE A SER LIBERADO "
	echo "COLOQUE O SITE SEM O wwww. (ex: compels.net | globo.com)"
	echo "______________________________________________________________"
	read sitelib
	while true
		do
		echo "______________________________________________________________"
		echo "DIGITE O MOTIVO DA LIBERACAO DO SITE COM PALAVRAS "
		echo "MINUSCULAS E SEM ACENTUACAO (MAXIMO 50 CARACTERES): "
		echo "______________________________________________________________"
		read motivolib
		echo $motivolib |grep -qs '^[[:aplha:][:digit:][:space:]]\{1,50\}$' && break
	done
	echo "$sitelib # $motivolib   # $(date +%Y%m%d_%H-%M-%S)" >> /etc/squid/sitelib
	squid -k reconfigure
	echo "______________________________________________________________"
	echo "                 SITE LIBERADO "
	ControlaSquid
}
# Bloquear site opcao 2
Bloquear() {
	echo "##############################################################"
	echo "DIGITE O SITE LIBERADO A SER BLOQUEADO "
	echo "COLOQUE O SITE SEM O wwww. (ex: compels.net | globo.com)"
	echo "______________________________________________________________"
	read siteblo
	while true
		do
		echo "______________________________________________________________"
		echo "DIGITE O MOTIVO DO BLOQUEIO DO SITE COM PALAVRAS "
		echo "MINUSCULAS E SEM ACENTUACAO (MAXIMO 50 CARACTERES): "
		echo "______________________________________________________________"
		read motivoblo
		echo $motivoblo |grep -qs '^[[:aplha:][:digit:][:space:]]\{1,50\}$' && break
	done
	echo "$siteblo # $motivoblo   # $(date +%Y%m%d_%H-%M-%S)" >> /etc/squid/siteblo
	squid -k reconfigure
	echo "______________________________________________________________"
	echo "                 SITE BLOQUEADO "
	ControlaSquid
}
ControlaSquid

