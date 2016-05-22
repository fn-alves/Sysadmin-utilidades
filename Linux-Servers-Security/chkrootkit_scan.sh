#/bin/bash
##############################################################################################
# Atividade: Rotina semanal de checagem de Rootkits nos Servidores
# Proposito: Evitar incidentes de invasores atraves de rootkits ou backdoors
# Data: 13/11/2013
# Autor: Elvis Suffi Pompeu
# Analista de Suporte Linux
###############################################################################################

CHKROOTKIT_SCAN="/usr/sbin/chkrootkit"
DATA_ATUAL=$(date +"%d-%m-%Y")
CHKROOTKIT_LOG="rkhunter-${DATA_ATUAL}.log"
SENDEMAIL="/usr/local/bin/sendEmail_seguranca.sh"
EMAILTO="monitoria@saveti.com.br"

${CHKROOTKIT_SCAN} > ${CHKROOTKIT_LOG} 

sleep 2

tar -zcvf ${CHKROOTKIT_LOG}.tar.gz ${CHKROOTKIT_LOG}

         if [ -e ${CHKROOTKIT_LOG} ]; then
                  ${SENDEMAIL} ${EMAILTO} "Check Rootkit: Relatorio semanal do chkrootkit no servidor $(hostname)" "Rotina de checagem de rootkit semanal: ok\nData: ${DATA_ATUAL}\nAutor: Elvis Suffi Pompeu\n\nAtenciosamente,\nMonitoria de Servidores | SAVE Tecnologia da Informacao" ${CHKROOTKIT_LOG}.tar.gz
                  sleep 2
                  rm -rf ${RKHUNTER_LOG}*
         else
                  ${SENDEMAIL} ${EMAILTO} "Check Rootkit: Relatorio semanal do chkrootkit no servidor $(hostname)" "Rotina de checagem de rootkit semanal: falhou\nData: ${DATA_ATUAL}\nAutor: Elvis Suffi Pompeu\n\nAteciosamente,\nMonitoria de Servidores | SAVE Tecnologia da Informacao"
                  sleep 2
         fi
