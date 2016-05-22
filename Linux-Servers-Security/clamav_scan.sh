#/bin/bash
##############################################################################################
# Atividade: Rotina semanal de checagem do Antivirus nos Servidores
# Proposito: Evitar incidentes de infeccoes de virus, worms, malwares, etc.
# Data: 12/11/2013
# Autor: Elvis Suffi Pompeu
# Analista de Servidores Linux
# Exemplo de uso: Geralmente utilizo essa rotina semanalmente para ter um relatorio 
# sobre integridade do sistema
###############################################################################################

CLAMAV_SCAN="/usr/bin/clamscan"
DATA_ATUAL=$(date +"%d-%m-%Y")
CLAMAV_LOG="clamav-${DATA_ATUAL}.log"
SENDEMAIL="/usr/local/bin/sendEmail.sh"
EMAILTO="email@suaempresa.com.br"

${CLAMAV_SCAN} -l ${CLAMAV_LOG} -r /

sleep 2

tar -zcvf ${CLAMAV_LOG}.tar.gz ${CLAMAV_LOG}

         if [ -e ${CLAMAV_LOG} ]; then
                 ${SENDEMAIL} ${EMAILTO} "ClamAV: Relatorio semanal do Antivirus no servidor $(hostname)" "Rotina de antivirus semanal: ok\nAutor: Elvis Suffi Pompeu" ${CLAMAV_LOG}.tar.gz
                 sleep 2
                 rm -rf ${CLAMAV_LOG}*
         else
                 ${SENDEMAIL} ${EMAILTO} "ClamAV: Relatorio semanal do Antivirus no servidor $(hostname)" "Rotina de antivirus semanal: falhou\nAutor: Elvis Suffi Pompeu"
                 sleep 2
         fi
