#!/bin/bash

#---------------------------#
# CONFIGURA��O DOS GATEWAYS #
#---------------------------#

GW1=10.0.2.2
GW2=192.168.1.1
LOG=/root/rc.firewall.log

#------------------------------#
# IN�CIO DA FUN��O DE FAILOVER #
#------------------------------#

# Aqui optei em por uma fun��o para deixar a estrutura do
# script mais organizada e leg�vel. � de suma import�ncia
# que voc� esteja familiarizado com o shell script

failover ()
{

# Cria��o de um loop infinito para testar a disponibilidade
# dos links de internet

while [ 1 ]
do

# Altera sempre para o gateway padr�o dentro da tabela
# main de roteamento, ou seja, quando o link prim�rio voltar,
# autom�ticamente a navega��o volta para este

/sbin/ip route replace default via $GW1

# Neste for, o comando dig retornar� os dois IPs relacionados
# ao site do UOL. Voc� poderia por qualquer site a�, por�m o UOL
# retorna dois IPs que ser�o utilizados pelo script para saber
# se o link de internet principal est� fora

for i in `dig +short uol.com.br`
do

# Verificando a comunica��o do link de internet

        /bin/ping -c 1 $i
done

# Caso o resultado do comando anterior seja 0 (zero), o link
# de internet principal est� ok. Se for 1 (um) houve falha no comando
# deduzindo assim aus�ncia de conex�o. Quem vai determinar isso � o
# comando echo $?. Mais abaixo, haver� um if para testar as condi��es

STATUS_CMD_LINK=`echo $?`

if [ $STATUS_CMD_LINK -eq 0 ]; then

# Caso haja sucesso no teste do comando do ping
# as regras para o compartilhamento de internet ser�o inseridas

        /sbin/iptables -F
        /sbin/iptables -t nat -F

        /sbin/modprobe iptable_nat
        echo 1 > /proc/sys/net/ipv4/ip_forward
        /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
else

# Se o link falhar, os comandos mais abaixo far�o a limpeza
# das regras de iptables e ir�o configurar o segundo link de internet
# e ser� criado um arquivo de log informando quando houve a queda

        echo "_________________________" >> $LOG
        echo " " >> $LOG
        echo "# LINK SECUNDARIO ATIVO.: `date +%d/%m/%y-%H:%M:%S`">> $LOG
        echo " " >> $LOG
        echo "_________________________" >> $LOG

                /sbin/ip route replace default via $GW2

                /sbin/iptables -F
                /sbin/iptables -t nat -F

                /sbin/modprobe iptable_nat
                echo 1 > /proc/sys/net/ipv4/ip_forward
                /sbin/iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

fi

# A cada 2 minutos (120 segundos) ser� feito um teste no link
# principal para constar se o mesmo encontra-se no ar.

sleep 120

done
}

####### CHAMA A FUN��O ########

failover 