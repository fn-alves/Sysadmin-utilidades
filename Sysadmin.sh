#!/bin/bash
##############################################################################################
# Atividade: Rotina de hora para verificar a performance do sistema
# Proposito: Ter em maos o relatorio em PDF de cada servidor individual
# Data: 03/12/2013
# Autor: Elvis Suffi Pompeu
# Analista de Servidores Linux
# 1) Pre-requisitos aptitude install htmldoc ou yum install htmldoc
# 2) Pre-requisito: aptitude install sendEmail ou yum install sendEmail, e ter o scripts sendEmail.sh
# que se encontra na seção "Utilities" daqui do GitHub.
###############################################################################################

REL="relatorio-${HOSTNAME}-$(date +"%d-%m-%Y").html"
SENDEMAIL="/usr/local/bin/sendEmail.sh"
EMAILTO="email@suaempresa.com.br"

# Cabecalho inicial do relatorio
echo -e "<HTML><HEAD><TITLE>Relatorio Diario - Servidores Linux</TITLE></HEAD><BODY>" > ${REL} 
echo -e "<hr color=navy>" >> ${REL}
echo -e "<p align="center"><font face="arial" size="7"><b>RELATORIO DIARIO LINUX<b></font></p>" >> ${REL}
echo -e "<p align="center"><font face="arial" size="1"><b>Desenvolvido por Elvis Suffi Pompeu<b></font></p>" >> ${REL}
echo -e "<hr color=navy>" >> ${REL}
echo -e "<CENTER>" >> ${REL}
# Logo da sua empresa
echo -e "<img src="http://monitoria.saveti.com.br/wiki/images/04ul.png.1.jpg">" >> ${REL}
echo -e "</CENTER>" >> ${REL}
echo -e "<hr color=navy>" >> ${REL}
echo -e "<font face="arial" size="2">" >> ${REL}
# Pula linha em HTML
echo -e "<br>" >> ${REL}
# Hostname e versao do SO / Distribuicao
echo -e "<TABLE BORDER=1>" >> ${REL}
echo -e "<TR>" >> ${REL}
echo -e "<TD>" >> ${REL}
echo -e "<b>INFORMACOES DO SISTEMA: </b>" >> ${REL}
echo -e "</TD>" >> ${REL}
echo -e "</TR>" >> ${REL}
echo -e "</TABLE>" >> ${REL}
echo -e "<br>" >> ${REL}
echo -e "<b>Nome do Servidor: </b> ${HOSTNAME}" >> ${REL}
echo -e "<br>" >> ${REL}
echo -e "<b>SO:</b> $(echo $OSTYPE) / $(uname)" >> ${REL}

# Qual distribuicao do sistema

DEBIAN=$(cat /etc/issue | grep -i debian | wc -l)
CENTOS=$(cat /etc/issue | grep -i centos | wc -l)
REDHAT=$(cat /etc/issue | grep -i "red hat" | wc -l)
UBUNTU=$(cat /etc/issue | grep -i ubuntu | wc -l)
SUSE=$(cat /etc/issue | grep -i suse | wc -l)
OPENSUSE=$(cat /etc/issue | grep -i opensuse | wc -l || cat /etc/issue | grep -i "open suse" | wc -l)
FEDORA=$(cat /etc/issue | grep -i fedora | wc -l)

echo -e "<br>" >> ${REL}

	if [ ${DEBIAN} -ne 0 ]; then

		echo -e "<b>Distribuicao:</b> Debian" >> ${REL}

	elif [ ${CENTOS} -ne 0 ]; then

		echo -e "<b>Distribuicao:</b> CentOS" >> ${REL}

	elif [ ${REDHAT} -ne 0 ]; then
	
		echo -e "<b>Distribuicao:</b> Red Hat" >> ${REL}

	elif [ ${UBUNTU} -ne 0 ]; then
	
		echo -e "<b>Distribuicao:</b> Ubuntu" >> ${REL}

	elif [ ${SUSE} -ne 0 ]; then

		echo -e "<b>Distribuicao:</b> Suse" >> ${REL}

	elif [ ${OPENSUSE} -ne 0 ]; then

		echo -e "<b>Distribuicao:</b> Open Suse" >> ${REL}

	elif [ ${FEDORA} -ne 0 ]; then

		echo -e "<b>Distribuicao:</b> Fedora" >> ${REL}

	fi


sleep 2

echo -e "<br>" >> ${REL}
echo -e "<b>Data:</b> $(date +"%d/%m/%Y")" >> ${REL}
echo -e "<br>" >> ${REL}
echo -e "<b>Hora: </b> $(date +"%H:%M")" >> ${REL} 

# Processos ativos do sistema
echo -e "<br><br>" >> ${REL}
echo -e "<hr color=navy>" >> ${REL}
echo -e "<br>" >> ${REL}
echo -e "<TABLE BORDER=1>" >> ${REL}
echo -e "<TR>" >> ${REL}
echo -e "<TD>" >> ${REL}
echo -e "<b>PROCESSOS ATIVOS NO SISTEMA:</b>" >> ${REL}
echo -e "</TD>" >> ${REL}
echo -e "</TR>" >> ${REL}
echo -e "</TABLE>" >> ${REL}
echo -e "<br>" >> ${REL}
sleep 2
echo -e "<TABLE BORDER=1>" >> ${REL}
echo -e "<TR>" >> ${REL} 
for i in "USUARIO" "PID" "CPU %" "MEMORIA %" "VSZ" "RSS" "TTY" "STATUS" "INICIADO" "TEMPO DE CPU" "COMANDO"
do

	echo -e "<TD>" >> ${REL}
	echo -e "${i}" >> ${REL}
	echo -e "</TD>" >> ${REL}
done
echo -e "</TR>" >> ${REL}
echo -e "</TABLE>" >> ${REL}
sleep 2
PSAUX=$(ps aux |wc -l)
for (( i=2; i<=${PSAUX}; i++ ));
do
	echo -e "$(ps aux | head -n ${i}|tail -n 1)<br>" >> ${REL}
done

sleep 30

# Uso de memoria RAM
echo -e "<br><br>" >> ${REL}
echo -e "<hr color=navy>" >> ${REL}
echo -e "<br>" >> ${REL}
echo -e "<TABLE BORDER=1>" >> ${REL}
echo -e "<TR>" >> ${REL}
echo -e "<TD>" >> ${REL}
echo -e "<b>USO DE MEMORIA: </b>" >> ${REL}
echo -e "</TD>" >> ${REL}
echo -e "</TR>" >> ${REL}
echo -e "</TABLE>" >> ${REL}
echo -e "<br>" >> ${REL}

echo -e "Memoria RAM:<br>" >> ${REL}
echo -e "<TABLE BORDER=1>" >> ${REL}
echo -e "<TR>" >> ${REL} 
for i in "total" "used" "free" "shared" "buffers" "cached"
do
	echo -e "<TD>" >> ${REL}
	echo -e "${i}" >> ${REL}
	echo -e "</TD>" >> ${REL}
done
echo -e "</TR>" >> ${REL}
echo -e "</TABLE>" >> ${REL}
sleep 2

echo -e "$(free -m | head -n 2| tail -n 1)<br>" >> ${REL}

sleep 2
echo -e "<br>" >> ${REL}

echo -e "Memoria Virtual (SWAP):<br>" >> ${REL}
echo -e "<TABLE BORDER=1>" >> ${REL}
echo -e "<TR>" >> ${REL}
for i in "total" "used" "free"
do
        echo -e "<TD>" >> ${REL}
        echo -e "${i}" >> ${REL}
        echo -e "</TD>" >> ${REL}
done
echo -e "</TR>" >> ${REL}
echo -e "</TABLE>" >> ${REL}

echo -e "$(free -m|grep -i swap|head -n 1)" >> ${REL}

# Espaco em Disco
echo -e "<br><br>" >> ${REL}
echo -e "<hr color=navy>" >> ${REL}
echo -e "<br>" >> ${REL}
echo -e "<TABLE BORDER=1>" >> ${REL}
echo -e "<TR>" >> ${REL}
echo -e "<TD>" >> ${REL}
echo -e "<b>ESPACO EM DISCO: </b>" >> ${REL}
echo -e "</TD>" >> ${REL}
echo -e "</TR>" >> ${REL}
echo -e "</TABLE>" >> ${REL}
echo -e "<br>" >> ${REL}

echo -e "<TABLE BORDER=1>" >> ${REL}
echo -e "<TR>" >> ${REL} 
for i in "SISTEMAS DE ARQUIVOS" "TAMANHO" "USADO" "DISPONIVEL" "USO %" "MONTADO EM"
do
	echo -e "<TD>" >> ${REL}
	echo -e "${i}" >> ${REL}
	echo -e "</TD>" >> ${REL}
done
echo -e "</TR>" >> ${REL}
echo -e "</TABLE>" >> ${REL}
sleep 2
DISKFREE=$(df -lh |wc -l)
for (( i=2; i<=${DISKFREE}; i++ ));
do
           echo -e "$(df -lh | head -n ${i}|tail -n 1)<br>" >> ${REL}
done

sleep 2

# Interfaces de redes
echo -e "<br><br>" >> ${REL}
echo -e "<hr color=navy>" >> ${REL}
echo -e "<br>" >> ${REL}
echo -e "<TABLE BORDER=1>" >> ${REL}
echo -e "<TR>" >> ${REL}
echo -e "<TD>" >> ${REL}
echo -e "<b>CONFIGURACOES DE REDE: </b>" >> ${REL}
echo -e "</TD>" >> ${REL}
echo -e "</TR>" >> ${REL}
echo -e "</TABLE>" >> ${REL}
echo -e "<br>" >> ${REL}

echo -e "<b>Configuracoes de IP e Interfaces: </b>" >> ${REL}
echo -e "<br><br>" >> ${REL}
sleep 3

ETHERNET=$(ifconfig | grep -i "eth[0-9]"| wc -l)
for (( i=1; i<=${ETHERNET}; i++ ));
do
	echo -e "Interface de Rede: $( ifconfig | grep -i "eth[0-9]"| awk '{print $1}'| head -n ${i}|tail -n 1)<br>" >> ${REL}
done

echo -e "<br>" >> ${REL}

IPSHOW=$(ifconfig | grep -i "[0-255].[0-255].[0-255].[0-255]"| wc -l)
for (( i=1; i<=${IPSHOW}; i++ ));
do
	echo -e "IP: $(ifconfig | grep -i "[0-255].[0-255].[0-255].[0-255]"| awk '{print $3}'| head -n ${i}|tail -n 1)<br>" >> ${REL}
done

sleep 2

echo -e "<br>" >> ${REL}
	echo -e "<b>Configuracoes de Rotas / Gateway padrao: </b>" >> ${REL}
echo -e "<br>" >> ${REL}
sleep 3

ROUTE=$(route -n | grep -i "[0-255].[0-255].[0-255].[0-255]"| wc -l)

for (( i=1; i<=${ROUTE}; i++ ));
do
         echo -e "Gateway: $(route -n | grep -i "[0-255].[0-255].[0-255].[0-255]"| awk '{print $2}'| head -n ${i}|tail -n 1)<br>" >> ${REL}
done

sleep 2

# Regras de firewall

echo -e "<br><br>" >> ${REL}
echo -e "<hr color=navy>" >> ${REL}
echo -e "<br>" >> ${REL}
echo -e "<TABLE BORDER=1>" >> ${REL}
echo -e "<TR>" >> ${REL}
echo -e "<TD>" >> ${REL}
echo -e "<b>REGRAS DE FIREWALL: </b>" >> ${REL}
echo -e "</TD>" >> ${REL}
echo -e "</TR>" >> ${REL}
echo -e "</TABLE>" >> ${REL}
echo -e "<br>" >> ${REL}

echo -e "<b>Regras do IPTables: </b>" >> ${REL}
echo -e "<br>" >> ${REL}

sleep 3
IPTABLES=$(iptables -L | wc -l)

for (( i=1; i<=${IPTABLES}; i++ ));
do
	echo -e "$(iptables -L | head -n ${i}|tail -n 1)<br>" >> ${REL}
done

sleep 2

# Rodape

echo -e "<br><hr color=navy><br>" >> ${REL}
echo -e "<CENTER>" >> ${REL}
echo -e "Monitoria de Servidores | Tecnologia da Informacao" >>${REL}
echo -e "<br>" >> ${REL}
# Logo da sua empresa
echo -e "<img src="http://monitoria.saveti.com.br/wiki/images/04ul.png.2">" >> ${REL}
echo -e "</CENTER>" >> ${REL}
echo -e "</font>" >> ${REL}

# Fim
echo -e "</BODY></HTML>" >> ${REL}

sleep 2

htmldoc --webpage --color -t pdf14 --size a4 ${REL} -f relatorio-${HOSTNAME}-$(date +"%d-%m-%Y").pdf > /dev/null 2>&1

REL="relatorio-${HOSTNAME}-$(date +"%d-%m-%Y").pdf"

tar -zcvf ${REL}.tar.gz ${REL}

sleep 2

	if [ -e ${REL} ]; then
                 
		${SENDEMAIL} ${EMAILTO} "Sysadmin: Relatorio diario do servidor $(hostname)" "Rotina diaria: ok\nAutor: Elvis Suffi Pompeu\n\nAtenciosamente,\nMonitoria de Servidores | Tecnologia da Informacao" ${REL}.tar.gz > /dev/null 2>&1	
		while [[ ${?} -ne 0 ]] ; do
			${SENDEMAIL} ${EMAILTO} "Sysadmin: Relatorio diario do servidor $(hostname)" "Rotina diaria: ok\nAutor: Elvis Suffi Pompeu\n\nAtenciosamente,\nMonitoria de Servidores | Tecnologia da Informacao" ${REL}.tar.gz > /dev/null 2>&1
			
		done
		
		# LEMBRE-SE de seguir os procedimentos abaixo:
		# Adicione em /etc/rsyslog.conf: local5.*		/var/log/relatorios.log
		# Com TAB ao inves de espacamento.
		logger -t $0 -p local5.info "Sysadmin: Relatorio diario do servidor $(hostname) OK"
		sleep 10
		REL="relatorio-${HOSTNAME}-$(date +"%d-%m-%Y")."
        	rm -rf ${REL}*
       	fi