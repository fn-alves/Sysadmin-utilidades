#/bin/bash
##############################################################################################
# Atividade: Rotina semanal de checagem de Rootkits nos Servidores
# Proposito: Evitar incidentes de invasores atraves de rootkits ou backdoors
# Data: 11/11/2013
# Autor: Elvis Suffi Pompeu
# Analista de Servidores Linux
# Exemplo de uso: Geralmente usado como rotina semanal de relatorios de Rootkits
###############################################################################################

RKHUNTER_SCAN="/usr/bin/rkhunter"
DATA_ATUAL=$(date +"%d-%m-%Y")
RKHUNTER_LOG="rkhunter-${DATA_ATUAL}.log"
SENDEMAIL="/usr/local/bin/sendEmail.sh"
EMAILTO="email@suaempresa.com.br"

${RKHUNTER_SCAN} -l ${RKHUNTER_LOG} --sk --check

sleep 2

tar -zcvf ${RKHUNTER_LOG}.tar.gz ${RKHUNTER_LOG}

         if [ -e ${RKHUNTER_LOG} ]; then
                  ${SENDEMAIL} ${EMAILTO} "RootKit Hunter: Relatorio semanal do rkhunter no servidor $(hostname)" "Rotina de checagem de rootkit semanal: ok\nData: ${DATA_ATU    AL}\nAutor: Elvis Suffi Pompeu" ${RKHUNTER_LOG}.tar.gz
                  sleep 2
                  rm -rf ${RKHUNTER_LOG}*
         else
                  ${SENDEMAIL} ${EMAILTO} "Rootkit Hunter: Relatorio semanal do rkhunter no servidor $(hostname)" "Rotina de checagem de rootkit semanal: falhou\nData: ${DATA    _ATUAL}\nAutor: Elvis Suffi Pompeu"
                  sleep 2
         fi
