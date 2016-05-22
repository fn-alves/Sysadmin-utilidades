#!/bin/bash
##############################################################################################
# Desligar sistema
# Motivo: mudanca de Rack. (Por exemplo)
# Data: 30/08/2013
# Autor: Elvis Suffi Pompeu
# Analista de Servidores Linux
# Exemplos de uso: Usado para ser agendado em periodos fora do horario do expediente
# ou durante os fins de semana.
# Situacoes que podem ser usadas: Diversas, por exemplo em mudancas de Rack ou desligamento
# da rede eletrica da regiao pre-agendado.
##############################################################################################

# Declaracao da variavel com o binario shutdown
DESLIGAR="/sbin/shutdown"
SENDEMAIL="/usr/local/bin/sendEmail.sh"
EMAILTO="email@suaempresa.com.br"

# Aviso de desligamento
${SENDEMAIL} ${EMAILTO} "Desligamento do servidor: $(hostname)" "Status do Servidor $(hostname): desligando"
# Util para comunicar alguem que esteja em periodo de PLANTÃO

sleep 3

# Desligamento do sistema
${DESLIGAR} -h now
