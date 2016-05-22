#!/bin/bash
##############################################################################################
# Atividade: Rotina de Backup da base de dados MySQL .
# Proposito: Evitar incidentes relacionado as base de dados.
# Data: 24/09/2013
# Autor: Elvis Suffi Pompeu
# Analista de Servidores Linux
# Pre-requisitos: s3cmd com s3 Amazon AWS
##############################################################################################

#############################################################################################
# DECLARACAO DAS VARIAVEIS
#############################################################################################

# Caminho do binario do mysqldump.
export PATH_MYSQLDUMP="/usr/bin/mysqldump"

# Caminho do binario do s3cmd.
export PATH_S3CMD="/usr/bin/s3cmd"

# Caminho do binario do sendEmail.
export PATH_SENDEMAIL="/usr/local/bin/sendEmail.sh"

# Destinatario a receber o e-mail.
export DESTINATARIO="email@suaempresa.com.br"

# Nome do Bucket s3.
export PATH_BUCKET="nome_do_seu_bucket_no_s3"

# Data atual do sistema.
export DATA_ATUAL=$(date +"%d-%m-%Y")

# Nome do backup.
export BACKUP_MYSQL="zabbix-bkp-${DATA_ATUAL}"

# Usuario do MySQL. Pode ser qualquer um com permissão, não sendo necessário o root.
export USER_MYSQL="root"

# Password do usuario do MySQL
export PASSWORD_MYSQL="suasenha"

# Base de Dados a ser feita o Backup.
export DATABASE="basededados_x"

# Caminho onde o backup deve ser salvo.
export PATH_BACKUP="/var/lib/mysql/backup/"

#############################################################################################
# Acesso ao caminho do Backup.
#############################################################################################
 cd ${PATH_BACKUP}

#############################################################################################
# Execucao do Backup.
 #############################################################################################
${PATH_MYSQLDUMP} -u ${USER_MYSQL} -p${PASSWORD_MYSQL} ${ZABBIX_DATABASE} > ${PATH_BACKUP}${BACKUP_MYSQL}.sql

#############################################################################################
# Aguarda o intervalo de 10 segundos para economizar recursos do Servidor.
#############################################################################################
sleep 10

#############################################################################################
# Compactacao do Backup.
#############################################################################################
tar -zcvf ${BACKUP_MYSQL}.tar.gz ${BACKUP_MYSQL}.sql

#############################################################################################
# Enviando para o Storage S3 em nossa Cloud Amazon.
#############################################################################################
${PATH_S3CMD} put --acl-public ${BACKUP_MYSQL}.tar.gz s3://${PATH_BUCKET}

#############################################################################################
# Aguarda o intervalo de 10 segundos para economizar recursos do Servidor.
#############################################################################################
sleep 10

#############################################################################################
# Verifica o retorno do comando: se 1 OK se 0 FAIL
#############################################################################################
export CHECK_BACKUP=$(${PATH_S3CMD} ls s3://${PATH_BUCKET} | grep ${DATA_ATUAL} | wc -l)

#############################################################################################
# Verifica e o backup foi enviado para o Storage s3 na Cloud Amazon, e enviando o e-mail.
#############################################################################################
          if [ -d "${PATH_BACKUP}" ]; then

                 if [ $CHECK_BACKUP -eq "1" ]; then
          ${PATH_SENDEMAIL} ${DESTINATARIO} "Backup Data Base Zabbix: OK" "Rotina de backup: OK\nAutor: Elvis Suffi Pompeu\nStatus: Backup realizado com sucesso.\nArquivo: ${    BACKUP_MYSQL}.tar.gz\nData de Backup: ${DATA_ATUAL}\nLink do backup: http://${PATH_BUCKET}.s3.amazonaws.com/${BACKUP_MYSQL}.tar.gz\n\nAteciosamente,\nMonitoria de Servidores     | SAVE Tecnologia da Informacao"
          rm ${BACKUP_MYSQL}.sql
          rm ${BACKUP_MYSQL}.tar.gz
         wall <<< "Backup Data Base Zabbix: OK"
          exit
          else
          ${PATH_SENDEMAIL} ${DESTINATARIO} "Backup Data Base Zabbix: FAIL" "Rotina de backup: Falhou\nAutor: Elvis Suffi Pompeu\nStatus: Falha durante o processo de backup.\    n\nAtenciosamente,\nMonitoria de Servidores | SAVE Tecnologia da Informacao"
          rm ${BACKUP_MYSQL}.sql
          rm ${BACKUP_MYSQL}.tar.gz
          wall <<< "Backup Data Base Zabbix: FAIL"
          fi

                 else
                         mkdir ${PATH_BACKUP}

                         if [ -d "${PATH_BACKUP}" ]; then

                                 if [ $CHECK_BACKUP -eq "1" ]; then
                                 ${PATH_SENDEMAIL} ${DESTINATARIO} "Backup Data Base Zabbix: OK" "Rotina de backup: OK\nAutor: Elvis Suffi Pompeu\nStatus: Backup realizado co    m sucesso.\nArquivo: ${BACKUP_MYSQL}.tar.gz\nData de Backup: ${DATA_ATUAL}\nLink do backup: http://${PATH_BUCKET}.s3.amazonaws.com/${BACKUP_MYSQL}.tar.gz\n\nAnteciosamente,\    nMonitoria de Servidores | SAVE Tecnologia da Informacao"
                                 rm ${BACKUP_MYSQL}.sql
                                 rm ${BACKUP_MYSQL}.tar.gz
                                 wall <<< "Backup Data Base Zabbix: OK"
                                 else
                                 ${PATH_SENDEMAIL} ${DESTINATARIO} "Backup Data Base Zabbix: FAIL" "Rotina de backup: Falhou\nAutor: Elvis Suffi Pompeu\nStatus: Falha durante     o processo de backup.\n\nAtenciosamente,\nMonitoria de Servidores | SAVE Tecnologia da Informacao"
                                 rm ${BACKUP_MYSQL}.sql
                                 rm ${BACKUP_MYSQL}.tar.gz
                                 wall <<< "Backup Data Base Zabbix: FAIL"
                                 exit
                                 fi
                         else
                                 ${PATH_SENDEMAIL} ${DESTINATARIO} "Backup Data Base Zabbix: FAIL" "Rotina de backup: Falhou\nAutor: Elvis Suffi Pompeu\nStatus: Falha durante     o processo de backup.\n\nAtenciosamente,\nMonitoria de Servidores | SAVE Tecnologia da Informacao"
                                 rm ${BACKUP_MYSQL}.sql
                                 rm ${BACKUP_MYSQL}.tar.gz
                                 wall <<< "Backup Data Base Zabbix: FAIL"
                                 exit
                         fi
         fi

# EOF
