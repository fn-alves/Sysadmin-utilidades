#!/bin/bash
clear
echo "
##########################################################################
# Autor: Felipe Assunção                                                 #
# Email: felipeassuncaoj@gmail.com                                       #
#                                                                        #
# Script desenvolvido para receber nome do usuário e endereço MAC        #
# para cadastra-los nos seguintes arquivos:                              #
#									 #
# /etc/dhcp/dhcpd.conf (Distribui IP's automático, amarrando-os nos MAC) #
# /etc/ethers (Amarra IP x MAC)						 #
# /etc/sarg/sarg.usertab (Nome de usuário no relatório SARG)		 #
# /etc/hosts (Relaciona nome de usuário ao invés de IP)			 #
#									 #
# - O IP usado será o próximo disponível no dhcpd.conf			 #
# - Validador de MAC							 #
# - Limitador de IP 							 #
# - Atualização automática da tabela ARP (arp -f) 			 #
# - Restart automático do dhcpd (/etc/init.d/isc-dhcp-server restart)	 #
##########################################################################
"
ip_final_atual=$(cut -d " " -f 8 /etc/dhcp/dhcpd.conf | tr -d ';','}}}' | tail -2 | cut -d "." -f 4)
ip_final_proximo=$(($ip_final_atual+1))
ip_inicio=$(cut -d " " -f 8 /etc/dhcp/dhcpd.conf | tr -d ';','}}}' | tail -2 | cut -d "." -f 1-3)
ip_proximo=$ip_inicio.$ip_final_proximo
valida_mac=0

if [ "$ip_final_proximo" -gt "254" ]; then
	echo
	echo "Endereços IP's esgotados"
	echo
		else
		echo
		echo "Digite o nome do usuário, sem acentuação e/ou espaço - Ex: Jose-Cel, Jose-Note"
		read nome
		echo

while [ "$valida_mac" != "" ]; do

	echo Digite o endereço MAC - Ex: 11:aa:22:bb:33:cc
	read mac

		valida_mac=`echo $mac | sed "s/[0-9\a-f\A-F\:]//g"`; 

			if [ "$valida_mac" != "" ]; then
			echo
			echo "Endereço MAC Inválido"
			echo
				else

				tac /etc/dhcp/dhcpd.conf | tail -n +2 | tac > /etc/dhcp/dhcpd.tmp
				echo "host $nome { hardware ethernet $mac; fixed-address $ip_proximo; }" >> /etc/dhcp/dhcpd.tmp
				tail -1 /etc/dhcp/dhcpd.conf >> /etc/dhcp/dhcpd.tmp
				mv /etc/dhcp/dhcpd.tmp /etc/dhcp/dhcpd.conf

				sed -i s/$ip_proximo\ \aa:bb:cc:dd:ee:ff/$ip_proximo\ $mac/g /etc/ethers

				echo $ip_proximo $nome >> /etc/sarg/sarg.usertab 

				echo $ip_proximo $nome >> /etc/hosts

				echo
				echo Atualizando tabela ARP...
				arp -f
				echo

				echo Reiniciando servidor DHCP...
				/etc/init.d/isc-dhcp-server restart

				echo
				echo O IP $ip_proximo foi definido para $nome
				echo
			fi

done

fi
