#!/bin/bash

#---------------------------#
# CONFIGURAÇÃO DOS GATEWAYS #
#---------------------------#

GW1=10.0.2.2
GW2=192.168.1.1
LOG=/root/rc.firewall.log

#------------------------------#
# INÍCIO DA FUNÇÃO DE FAILOVER #
#------------------------------#

# Aqui optei em por uma função para deixar a estrutura do
# script mais organizada e legível. É de suma importância
# que você esteja familiarizado com o shell script

failover ()
{

# Criação de um loop infinito para testar a disponibilidade
# dos links de internet

while [ 1 ]
do

# Altera sempre para o gateway padrão dentro da tabela
# main de roteamento, ou seja, quando o link primário voltar,
# automáticamente a navegação volta para este

/sbin/ip route replace default via $GW1

# Neste for, o comando dig retornará os dois IPs relacionados
# ao site do UOL. Você poderia por qualquer site aí, porém o UOL
# retorna dois IPs que serão utilizados pelo script para saber
# se o link de internet principal está fora

for i in `dig +short uol.com.br`
do

# Verificando a comunicação do link de internet

        /bin/ping -c 1 $i
done

# Caso o resultado do comando anterior seja 0 (zero), o link
# de internet principal está ok. Se for 1 (um) houve falha no comando
# deduzindo assim ausência de conexão. Quem vai determinar isso é o
# comando echo $?. Mais abaixo, haverá um if para testar as condições

STATUS_CMD_LINK=`echo $?`

if [ $STATUS_CMD_LINK -eq 0 ]; then

# Caso haja sucesso no teste do comando do ping
# as regras para o compartilhamento de internet serão inseridas

        /sbin/iptables -F
        /sbin/iptables -t nat -F

        /sbin/modprobe iptable_nat
        echo 1 > /proc/sys/net/ipv4/ip_forward
        /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
else

# Se o link falhar, os comandos mais abaixo farão a limpeza
# das regras de iptables e irão configurar o segundo link de internet
# e será criado um arquivo de log informando quando houve a queda

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

# A cada 2 minutos (120 segundos) será feito um teste no link
# principal para constar se o mesmo encontra-se no ar.

sleep 120

done
}

####### CHAMA A FUNÇÃO ########

failover 