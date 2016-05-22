#!/bin/bash
#
# Autor: Heros Eloi (heroseloi@gmail.com)
#
# Licen�a: GPL
#
# Executa comandos remotos nas esta��es definidas pelo arquivo $LISTA_MAQUINAS
# e salva a saida no arquivo $LOG_BOM.
# Se a maqiuna naum est� disponivel no momento, ela ir� reponder com um 
# "falso" ao comando ping, esta maquina ent�o ser� inserida no $LOG_RUIM
# 
# A sintaxe � simples:
# info_maquina "comando"
# Importante o uso de aspas duplas para que sejam protegidos os comandos que 
# contem ESPA�O na sua forma��o.
# Exemplo: info_maquina "ls -l /etc"
#
# Ao Final da execu��o o Script imprime o relatorio na impressora padrao 
# instalada pelo CUPS.
#
# Arquivo de registro bem sucedido
LOG_BOM=/mnt/backup/shell/servidor/info_maquinas/acesso.log
#
# Arquivo de registro mal sucedido
LOG_RUIM=/mnt/backup/shell/servidor/info_maquinas/erro.log
#
# limpa log
> $LOG_BOM
echo -e "*** *** Comandos executados com sucesso *** ***\n" >> $LOG_BOM
> $LOG_RUIM
echo -e "### ### Comandos executados sem sucesso ### ###\n" >> $LOG_RUIM
#
# Arquivo com lista de maquinas
LISTA_MAQUINAS=/etc/hosts_ativos
#
# comando a ser executado remotamente
COMANDO1=$1
COMANDO1=`echo ${COMANDO1:="vazio"}`
	if [ $# > 1 ]
	then
	COMANDO2=$2
	COMANDO2=`echo ${COMANDO2:="vazio"}`
	fi
#
#
# funcao que exibe a ajuda do script
exibe_ajuda()
{
echo "sintaxe:"
echo "info_maquina <parametro> [comando]"
echo "Onde [comando] � o comando que sera executado nas esta��es"
echo " "
echo "Parametros:"
echo "-p Envia o relat�rio para a impressora padrao do CUPS"
echo "-v Mostra o relat�rio na tela"
echo "-h Mostra esta ajuda"
echo " "
echo "Para maiores informa��es, leia o cabe�alho do Script."
echo "heroseloi@gmail.com"
}
#
# executa os comandos
executa()
{
echo -e "Comando enviado: $COMANDO2\n\n" >> $LOG_BOM
echo "---------------------------------" >> $LOG_BOM
echo -e "Comando enviado: $COMANDO2\n\n" >> $LOG_RUIM
echo "---------------------------------" >> $LOG_RUIM
for MAQUINA in `cat $LISTA_MAQUINAS | awk '{print $1}'`
do
	ping $MAQUINA -c 1 > /dev/null
	if [ $? == 0 ]
	then
		echo "$MAQUINA OK"
		echo -e "Maquina $MAQUINA\n" >> $LOG_BOM
		ssh $MAQUINA $COMANDO2 >> $LOG_BOM
		echo "---------------------------------" >> $LOG_BOM
	else
		echo -e "$MAQUINA FALHOU\n" >> $LOG_RUIM
		echo "---------------------------------" >> $LOG_RUIM
	fi
done
}
#
# imprime os relatorios na impressora padr�o do CUPS
imprime()
{
echo "Imprimindo relarorio de acessos..."
lpr-cups $LOG_BOM
#echo "Imprimindo relarorio de erros..."
#lpr-cups $LOG_RUIM
}
#
# exibe o relatorio na tela
exibe_relatorio()
{
less $LOG_BOM
clear
less $LOG_RUIM
}


#
# funcao principal
case $COMANDO1 in
	"-h")
	exibe_ajuda;;
	
	"-p")
	executa
	imprime;;

	"-v")
	executa
	exibe_relatorio;;

	"vazio")
	exibe_ajuda;;

	*)
	COMANDO2=$COMANDO1
	executa;;
esac
