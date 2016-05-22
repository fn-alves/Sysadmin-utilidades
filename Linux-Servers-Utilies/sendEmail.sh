#!/bin/bash
##############################################################################################
# Atividade: Envio de e-mail via script
# Data: 13/11/2013
# Autor: Elvis Suffi Pompeu
# Analista de Servidores Linux
# Preparacao do ambiente: aptitude install sendEmail ou yum install sendEmail
# Modo de uso: script.sh seuendereco@suaempresa.com.br destinatario@destino.com "assunto" "corpo" anexo
# Observacao: o Anexo nao e obrigatorio e a porta pode ser alterada de 587 para 25
# Bem como pode desativar o TLS para envio "seguro"
###############################################################################################
  
export EMAILREMETENTE=seuendereco@suaempresa.com.br
export DESTIN="$1"
export ASSUNTO="$2"
export CORPO="$3"
export ANEXO="$4"
export SMTPSERVER=smtp.suaempresa.com.br
export SMTPLOGIN=seuendereco@suaempresa.com.br
export SMTPPASS="suasenha"
export SENDEMAIL="/usr/bin/sendEmail"

${SENDEMAIL} -f ${EMAILREMETENTE} -t ${DESTIN} -u ${ASSUNTO} -m "${CORPO}" -s ${SMTPSERVER}:587 -xu ${SMTPLOGIN} -xp ${SMTPPASS} -o tls=yes -a ${ANEXO}
