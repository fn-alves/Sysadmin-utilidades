#!/bin/bash

# Echanger versao 1.0
# Criado por Fabio de Souza - fsouza@komputer.com.br
# Modificado em 21 Maio de 2012

# Variaveis - Modifique somente se souber o que esta fazendo.
DATE='date +%Y%m%d%H%M'
ECHNGDIR="/root/scripts-adm/echanger"
CFG_PRI="$ECHANGEDIR/SuSEfirewall2-custom-primario"
CFG_SEC="$ECHANGEDIR/SuSEfirewall2-custom-secundario"
CFG_ORI="$ECHANGEDIR/SuSEfirewall2-custom-original"
PATH_SYS="/etc/sysconfig/scripts/SuSEfirewall2-custom"
IP_A="10.238.0.5"
IP_B="10.238.0.5"
INT_A="br0"
INT_B="br0"
LOG="/var/log/echanger.log"
CHECK="nada"
INTERVAL="300"
QTD_PINGS=4
FW_RELOAD="/sbin/rcSuSEfirewall2 reload"
FW_RESTART="/sbin/rcSuSEfirewall2 restart"
NET_RESTART="/sbin/rcnetwork restart"

msgOK () {
echo -e "[ \e[00;32mOK\e[00m ]"
}

msgFAILED () {
echo -e "[ \e[00;31mFAILED\e[00m ]"
}

Linkstts_A () {
ethtool $INT_A | grep "Link detected" >> $LOG 2> /dev/null
ethtool -S $INT_A | grep -vw " 0" >> $LOG 2> /dev/null
}

Linkstts_B () {
ethtool $INT_B | grep "Link detected" >> $LOG 2> /dev/null
ethtool -S $INT_B | grep -vw " 0" >> $LOG 2> /dev/null
}
echo -e "\n\t `$DATE` : Script ECHANGER iniciado ---" >> $LOG

touch $LOG || (msgFAILED && exit 1)

for ip in $IP_A $IP_B
do
    REGEX=$(egrep -c "\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(    25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" <<< ${IP_A})
    if [ $REGEX -eq 0 ]; then
         echo "Endereco IP $ip, que sera monitorado, esta inconsistente." >> $LOG
         exit 1
    else
        echo "Endereco IP $ip , que sera monitorado, esta consistente" >> $LOG
    fi
done

echo "Verificando existencia da $INT_A ..." >> $LOG
ifconfig $INT_A > /dev/null 2> /dev/null && msgOK >> $LOG || (msgFAILED >> $LOG && exit 1)
echo "Verificando existencia da $INT_B ..." >> $LOG
ifconfig $INT_B > /dev/null 2> /dev/null && msgOK >> $LOG || (msgFAILED >> $LOG && exit 1)

echo "Criando diretorio echanger ..." >> $LOG
mkdir -p $ECHNGDIR && msgOK >> $LOG || (msgFAILED >> $LOG && exit 1)

echo "Fazendo backup de $PATH_SYS para $ECHNGDIR$CFG_ORI ..." >> $LOG  
[ -f $PATH_SYS ] && cp $PATH_SYS $ECHNGDIR$CFG_ORI 2> /dev/null && msgOK >> $LOG || (msgFAILED >> $LOG && exit 1)

# Inicio do looping de verificacao de links
while true
do
sleep $INTERVAL

ping $IP_A -I $INT_A -c $QTD_PINGS > /dev/null 2> /dev/null ; STAT_IP0=$? 
ping $IP_B -I $INT_B -c $QTD_PINGS > /dev/null 2> /dev/null ; STAT_IP1=$?


# Problema no link secundario, joga trafego no link principal.
if [ $STAT_IP0 -eq 0 ] && [ $STAT_IP1 -ne 0 ] ; then
	if [ $CHECK == secdown ] ; then
		echo "`$DATE` : Nenhuma alteracao a fazer, $INT_B ainda esta down!" >> $LOG
		Linkstts_B
    else
		echo "`$DATE` : Link Secundario down!" >> $LOG
      	cp $ECHNGDIR$CFG_PRI $PATH_SYS        
		$FW_RELOAD > /dev/null 2> /dev/null
		INTERVAL="240" ; CHECK="secdown"
	fi

# Problema no link primario, joga trafego no link secundario.
elif [ $STAT_IP0 -ne 0 ] && [ $STAT_IP1 -eq 0 ] ; then
	if [ $CHECK == pridown ] ; then
       	echo "`$DATE` : Nenhuma alteracao a fazer, $INT_A ainda esta down!" >> $LOG
		Linkstts_A		
	else
		echo -e "`$DATE` : Link Primário down!" >> $LOG
        cp $ECHNGDIR$CFG_SEC $PATH_SYS        
        $FW_RELOAD > /dev/null 2> /dev/null
		INTERVAL="240" ; CHECK="pridown"
    fi

# Dois links indisponiveis, reinicia interfaces para tentar resolver.
elif [ $STAT_IP0 -ne 0 ] && [ $STAT_IP1 -ne 0 ] ; then
    if [ $CHECK == alldown ] ; then
		echo "`$DATE` : Links $INT_A e $INT_B ainda estao DOWN!" >> $LOG
		INTERVAL="60" ; CHECK="alldown"
	else
		echo -e "`$DATE` : All links DOWN!" >> $LOG
		$NET_RESTART > /dev/null 2> /dev/null
        INTERVAL="30" ; CHECK="alldown"
    fi

# Os dois links estao OK, mantem tabelas.
else
    if [ $CHECK == "allup" ] ; then
	    echo -e "`$DATE` : Nenhuma alteracao a fazer, links $INT_A e $INT_B ainda estao UP." >>  $LOG
	    INTERVAL="300" ; CHECK="allup"
    else
        echo -e "`$DATE` : Links $INT_A e $INT_B estao UP." >> $LOG
        cp $ECHNGDIR$CFG_ORI $PATH_SYS
        $FW_RELOAD > /dev/null 2> /dev/null
        INTERVAL="300" ; CHECK="allup"
    fi
fi
done
