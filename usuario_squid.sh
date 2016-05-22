#!/bin/bash
#
###############################################################################
#
# Copyright (C) 2005 Pitanga, Marcos
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
# Script facilitador para cadastro de usuarios em SQUID autenticado
# By Marcos Pitanga - 2005 - mpitanga@gplus.com.br


clear

while true
    do
    
clear
echo -e "****************************************"
echo -e "**   Cadastro de usuarios Proxy-SQUID **"
echo -e "**                                    **"
echo -e "** 1 - Cria usuario                   **"
echo -e "** 2 - Alterar senha                  **"
echo -e "** 3 - Sair                           **"
echo -e "****************************************"
	  
read opcao

case "$opcao"
    in
  
	1)	  echo -e "Digite seu nome: "
		  read nome
		  if cat /etc/squid/.apasswd|grep "$nome:" 1>/dev/null 2>/dev/null		  then
			echo "ERRO!!!! Usuario ja esta cadastrado"
			sleep 2
		  else
			htpasswd /etc/squid/.apasswd "$nome"
			echo "Cadastro efetuado com sucesso!!!"
			sleep 2
		  fi
		  ;;
	
	2)	  echo -e "Digite o nome para alteracao de senha: "
		  read nome
		  
		  if    cat /etc/squid/.apasswd|grep "$nome:" 1>/dev/null 2>/dev/null
		  then
                        htpasswd /etc/squid/.apasswd "$nome"
			echo "Senha alterada com sucesso!!!"
			sleep 2

		  else
		        echo "ERRO!!!! Usuario nao existe no sistema"
			sleep 2
		  fi
		  ;;
		  
	3) 	  echo "Ate logo ........"
		  exit
		  ;;
	
	*)	  echo "Somente sao validas opcoes 1, 2 e 3"
	          sleep 2
		  ;;
	  
esac
done
exit
		
