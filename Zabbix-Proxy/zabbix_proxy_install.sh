#!/bin/bash
#######################################################################################
# Atividade: Instalar o Agent e Proxy Zabbix.
# Proposito: Instalar de forma automatica o Zabbix Proxy e o Agent.
# Data: 09/04/2014
# Autor: Elvis Suffi Pompeu
# Analista de Servidores Linux
#######################################################################################

#---------------------------------FIM-DESCRICAO----------------------------------------


#######################################################################################
# 				Variaveis usadas no script
#######################################################################################

export DIR_DOWNLOAD="/root"
export URL_ZABBIX="https://s3-sa-east-1.amazonaws.com/zabbixinstall/"
export FILE_ZABBIX="zabbix-2.0.7.tar.gz"
export DIR_ZABBIX="/root/zabbix-2.0.7/"
export APTITUDE_BIN="/usr/bin/apt-get" 
export YUM_REPO="/usr/bin/yum"
export RPM="/bin/rpm"
export HOSTNAME_ZABBIX=$(hostname)
export DB_ZABBIX="/var/lib/sqlite3/zabbix.db"
export PATH_ZABBIX="/usr/local/etc/"
export DIR_SQLITE3="/var/lib/sqlite3"
export DIR_PID_ZABBIX="/tmp"
export DIR_LOG_ZABBIX="/var/log/zabbix"
export DIR_CONF_ZABBIX="/usr/local/etc"
export DIR_DAEMON_ZABBIX="/etc/init.d/"

#---------------------------------FIM-VARIAVEIS----------------------------------------


#######################################################################################
#                               Declaracao de Funcoes
#######################################################################################

#######################################################################################
#                         Funcao: Verifica o usuario logado
#######################################################################################

VerificaRoot(){

	if [ ${UID} -eq 0 ]; then
		echo -e "\nLogado como root...\t\t\t\t[\033[0;32m OK \033[0m]\n"
	else
		echo -e "\nOps, necessario logar como root...\t\t\t\t[\033[0;31m FALHOU \033[0m]\n"
		exit 30
	fi

}

########################################################################################
#                         Funcao: Exibi logo no terminal
########################################################################################

PrintZabbix(){
echo -e "/-------------------------------------------------------------\ \n\t ${0} Zabbix Proxy & Zabbix Agent\n\tDesenvolvido por Elvis Suffi Pompeu \n \-------------------------------------------------------------/"
}

########################################################################################
#                         Funcao: Adicionando usuario Zabbix
########################################################################################

AddUserZabbix(){

	echo -e "\n-------------------------------------------------------------"
	echo -e "Adicionando o usuario Zabbix."
	echo -e "-------------------------------------------------------------"
		useradd zabbix
			CHECK_USER_ZABBIX=$(cat /etc/passwd|grep zabbix|wc -l)
        			if [ ${CHECK_USER_ZABBIX} -eq 1 ]; then
                			echo -e "\nAdicionado...\t\t\t\t[\033[0;32m OK \033[0m]"
        			else
                			echo -e "\nAdicionado...\t\t\t\t[\033[0;31m FALHOU \033[0m]"
        				exit 2
        			fi

	sleep 2 
}

########################################################################################
#                          Funcao: Adicionando ao grupo Adm
########################################################################################

AddGrpDebZabbix(){
	
	adduser zabbix adm > /dev/null
        
		if [ ${?} -eq 0 ]; then
                	echo -e "\nAdicionando ao grupo Adm...\t\t[\033[0;32m OK \033[0m]"
        	else
                	echo -e "\nAdicionando ao grupo Adm...\t\t[\033[0;31m FALHOU \033[0m]"
        		exit 3
        	fi
		sleep 2
}

########################################################################################
#                         Funcao: Efetuando download do zabbix.tar.gz
########################################################################################

ZabbixDownload(){
	cd ${DIR_DOWNLOAD}

	echo -e "\n-------------------------------------------------------------"
	echo -e "\tEfetuando download do zabbix-2.0.7.tar.gz...\n"
	echo -e "-------------------------------------------------------------"
	echo -e "Esse processo leva alguns minutos, dependendo da sua conexao...Por favor, aguarde."
	echo -e "\n..."
	sleep 1
	echo -e "\n......"
	sleep 1
	echo -e "\n........."
	sleep 1
	echo -e "\n..............."
	sleep 1
	echo -e "\n........................."
	sleep 1
	echo -e "\n..................................."
	sleep 1
	echo -e "\n-------------------------------------------------------------\n"
	sleep 2

	wget ${URL_ZABBIX}${FILE_ZABBIX} --no-check-certificate

        	if [ -e ${FILE_ZABBIX} ]; then
                	echo -e "\nVerificando se o arquivo foi baixado com exito...\t[\033[0;32m OK \033[0m]"
        	else
                	echo -e "\nVerificando se o arquivo foi baixado com exito...\t[\033[0;31m FALHOU \033[0m]"
        	exit 4
        	fi

	sleep 2
}

########################################################################################
#                      	     Funcao: Descompactando o Zabbix
########################################################################################

DescompactaZabbix(){

	echo -e "\nDescompactando arquivo..."
	echo -e "\nProcesso leva alguns segundos..."
	
		tar zxvpf ${FILE_ZABBIX}

	sleep 2
}

########################################################################################
#                Funcao: Instalando as dependencias: Zabbix Proxy (Debian)
########################################################################################

DepDebPrxZbx(){

	echo -e "-------------------------------------------------------------\n"
	echo -e "\t\tInstalando as dependencias: Zabbix Proxy..."
        echo -e "-------------------------------------------------------------\n"

                ${APTITUDE_BIN} -y install libcurl3-gnutls-dev unixodbc-dev libsnmp-dev libssh2-1-dev libopenipmi-dev fping libsqlite3-dev sqlite3
                        if [ ${?} -eq 0 ]; then
                                echo -e "\nInstalando as dependencias...\t\t[\033[0;32m OK \033[0m]"
                        else
                                echo -e "\nInstalando as dependencias...\t\t[\033[0;31m FALHOU \033[0m]"
                                exit 1
                        fi

        sleep 2
}


########################################################################################
#                   Funcao: Instalando as dependencias: Zabbix agent (Debian)
########################################################################################

DepDebAgtZbx(){

	echo -e "-------------------------------------------------------------\n"
        echo -e "\t\tInstalando as dependencias: Zabbix agent..."
        echo -e "-------------------------------------------------------------\n"

                ${APTITUDE_BIN} -y install build-essential libcurl4-gnutls-dev libssh2-1-dev libldap-2.4-2 
                        if [ ${?} -eq 0 ]; then
                                echo -e "\nInstalando as dependencias...\t\t[\033[0;32m OK \033[0m]"
                        else
                                echo -e "\nInstalando as dependencias...\t\t[\033[0;31m FALHOU \033[0m]"
                                exit 1
                        fi

        sleep 2
}

########################################################################################
#           Funcao: Inicia a instalacao do Zabbix Proxy e Agent (Debian)
########################################################################################

ZabbixProxyDebInstall(){

	cd ${DIR_ZABBIX}

		echo -e "\n-------------------------------------------------------------"
		echo -e "\t\tIniciando instalacao..."
		echo -e "-------------------------------------------------------------\n"
		./configure --enable-proxy --enable-agent --with-ssh2 --with-ldap --with-net-snmp --with-libcurl --with-unixodbc --with-openipmi --with-sqlite3
        	
		if [ ${?} -eq 0 ]; then
               		echo -e "\nPreparado as configuracoes e parametros:\t\t[\033[0;32m OK \033[0m]\n"
        	else
               		echo -e "\nPreparado as configuracoes e parametros:\t\t[\033[0;31m FALHOU \033[0m]\n"
        	fi

		sleep 2

	make
        	if [ ${?} -eq 0 ]; then
                	echo -e "\nPreparando compilacao...:\t\t[\033[0;32m OK \033[0m]\n"
        	else
                	echo -e "\nPreparando compilacao:\t\t[\033[0;31m FALHOU \033[0m]\n"
        	fi

		sleep 2

	make install
        	if [ ${?} -eq 0 ]; then
        	        echo -e "\nPreparando instalacao...:\t\t[\033[0;32m OK \033[0m]"
        	else
                	echo -e "\nPreparando instalacao: \t\t[\033[0;31m FALHOU \033[0m]"
       	 	fi

		sleep 2
}

########################################################################################
#           Funcao: Inicia a instalacao do Zabbix Proxy e Agent (CentOS)
########################################################################################

ZabbixProxyCenInstall(){

        cd ${DIR_ZABBIX}

                echo -e "\n-------------------------------------------------------------"
                echo -e "\t\tIniciando instalacao..."
                echo -e "-------------------------------------------------------------\n"
                ./configure --enable-proxy --enable-agent --with-ssh2 --with-net-snmp --with-libcurl --with-sqlite3

                if [ ${?} -eq 0 ]; then
                        echo -e "\nPreparado as configuracoes e parametros:\t\t[\033[0;32m OK \033[0m]\n"
                else
                        echo -e "\nPreparado as configuracoes e parametros:\t\t[\033[0;31m FALHOU \033[0m]\n"
                fi

                sleep 2

        make
                if [ ${?} -eq 0 ]; then
                        echo -e "\nPreparando compilacao...:\t\t[\033[0;32m OK \033[0m]\n"
                else
                        echo -e "\nPreparando compilacao:\t\t[\033[0;31m FALHOU \033[0m]\n"
                fi

                sleep 2

        make install
                if [ ${?} -eq 0 ]; then
                        echo -e "\nPreparando instalacao...:\t\t[\033[0;32m OK \033[0m]"
                else
                        echo -e "\nPreparando instalacao: \t\t[\033[0;31m FALHOU \033[0m]"
                fi

                sleep 2
}

########################################################################################
#                  Funcao: Inicia a instalacao do Zabbix Agent (Debian)
########################################################################################

ZabbixAgentDebInstall(){

        cd ${DIR_ZABBIX}

                echo -e "\n-------------------------------------------------------------"
                echo -e "\t\tIniciando instalacao..."
                echo -e "-------------------------------------------------------------\n"
                ./configure --enable-agent --enable-ipv6 --with-ldap --with-net-snmp --with-ssh2 --with-libcurl

                if [ ${?} -eq 0 ]; then
                        echo -e "\nPreparado as configuracoes e parametros:\t\t[\033[0;32m OK \033[0m]\n"
                else
                        echo -e "\nPreparado as configuracoes e parametros:\t\t[\033[0;31m FALHOU \033[0m]\n"
                fi

                sleep 2

        make
                if [ ${?} -eq 0 ]; then
                        echo -e "\nPreparando compilacao...:\t\t[\033[0;32m OK \033[0m]\n"
                else
                        echo -e "\nPreparando compilacao:\t\t[\033[0;31m FALHOU \033[0m]\n"
                fi

                sleep 2

        make install
                if [ ${?} -eq 0 ]; then
                        echo -e "\nPreparando instalacao...:\t\t[\033[0;32m OK \033[0m]"
                else
                        echo -e "\nPreparando instalacao: \t\t[\033[0;31m FALHOU \033[0m]"
                fi

                sleep 2
}

########################################################################################
#                  Funcao: Inicia a instalacao do Zabbix Agent (CentOS)
########################################################################################

ZabbixAgentCenInstall(){

        cd ${DIR_ZABBIX}

                echo -e "\n-------------------------------------------------------------"
                echo -e "\t\tIniciando instalacao..."
                echo -e "-------------------------------------------------------------\n"
                ./configure --enable-agent --enable-ipv6 --with-net-snmp --with-ssh2 --with-libcurl

                if [ ${?} -eq 0 ]; then
                        echo -e "\nPreparado as configuracoes e parametros:\t\t[\033[0;32m OK \033[0m]\n"
                else
                        echo -e "\nPreparado as configuracoes e parametros:\t\t[\033[0;31m FALHOU \033[0m]\n"
                fi

                sleep 2

        make
                if [ ${?} -eq 0 ]; then
                        echo -e "\nPreparando compilacao...:\t\t[\033[0;32m OK \033[0m]\n"
                else
                        echo -e "\nPreparando compilacao:\t\t[\033[0;31m FALHOU \033[0m]\n"
                fi

                sleep 2

        make install
                if [ ${?} -eq 0 ]; then
                        echo -e "\nPreparando instalacao...:\t\t[\033[0;32m OK \033[0m]"
                else
                        echo -e "\nPreparando instalacao: \t\t[\033[0;31m FALHOU \033[0m]"
                fi

                sleep 2
}

########################################################################################
#                          Funcao: Cria a base de dados do Zabbix Proxy
########################################################################################

CreateDataBasePrxZbx(){

	echo -e "\n-------------------------------------------------------------"
	echo -e "\t\tCriando a base de dados do Zabbix..."
	echo -e "-------------------------------------------------------------\n"

        	if [ -d "${DIR_SQLITE3}" ]; then
        		echo -e "\nDiretorio ${DIR_SQLITE3} ja existe...\t\t[\033[0;32m OK \033[0m]"
        	else
        		echo -e "\nDiretorio ${DIR_SQLITE3} nao existe, criando...."
        		mkdir ${DIR_SQLITE3}
                		if [ -d "${DIR_SQLITE3}" ]; then
                        		echo -e "Diretorio criado:\t\t[\033[0;32m OK \033[0m]"
                		else
                        		echo -e "Diretorio criado:\t\t[\033[0;31m FALHOU \033[0m]"
                			exit 8
                		fi
        	fi

	sleep 2

	echo -e "\nPreparando a base de dados..."

	sqlite3 ${DIR_SQLITE3}/zabbix.db < $(find / -iname schema.sql | grep sqlite)
	chown -R zabbix:zabbix ${DIR_SQLITE3}/zabbix.db
	chown -R zabbix:zabbix ${DIR_SQLITE3}
        
		if [ -e "${DIR_SQLITE3}/zabbix.db" ]; then
                	echo -e "Base foi criada...\t\t[\033[0;32m OK \033[0m]"
        	else
                	echo -e "Base foi criada...\t\t[\033[0;31m FALHOU \033[0m]"
                	exit 9
        	fi

		sleep 2
}

########################################################################################
#              Funcao: Criando a arvore de diretorios do Zabbix e suas permissoes
########################################################################################

CreateTreeZbx(){

        echo -e "\n-------------------------------------------------------------"
        echo -e "Criando a arvore de diretorios do Zabbix e suas permissoes..."
        echo -e "-------------------------------------------------------------\n"

                for DIRS_ZABBIX in "${DIR_LOG_ZABBIX}" "${DIR_PID_ZABBIX}" "/usr/local/bin/externalscripts"; do
                        if [ -d "${DIRS_ZABBIX}" ]; then
                                echo -e "Diretorio ${DIRS_ZABBIX} ja existe....\t\t[\033[0;32m OK \033[0m]"
                                chown -R zabbix:zabbix ${DIRS_ZABBIX}
                        else
                                echo -e "Diretorio ${DIRS_ZABBIX} nao existe, criando...."
                                mkdir ${DIRS_ZABBIX}
                                chown -R zabbix:zabbix ${DIRS_ZABBIX}
                                        if [ -d "${DIRS_ZABBIX}" ]; then
                                                echo -e "Diretorio criado:\t\t[\033[0;32m OK \033[0m]"
                                        else
                                                echo -e "Diretorio criado:\t\t[\033[0;31m FALHOU \033[0m]"
                                                exit 10
                                        fi
                        fi
                done

        sleep 2
}

########################################################################################
#                  Funcao: Preparando a estrutura do Zabbix Proxy
########################################################################################

StructurePrxZbx(){
		for ARQS_ZABBIX in "${DIR_CONF_ZABBIX}/zabbix_proxy.conf" "${DIR_LOG_ZABBIX}/zabbix_proxy.log" "${DIR_PID_ZABBIX}/zabbix_proxy.pid" ; do
                        if [ -e "${ARQS_ZABBIX}" ]; then
                                echo -e "Arquivo ${ARQS_ZABBIX} ja existe....\t\t[\033[0;32m OK \033[0m]"
                                chown -R zabbix:zabbix ${ARQS_ZABBIX}
                        else
                                echo -e "\nArquivo ${ARQS_ZABBIX} nao existe, criando...."
                                touch ${ARQS_ZABBIX}
                                chown -R zabbix:zabbix ${ARQS_ZABBIX}
                                if [ -e "${ARQS_ZABBIX}" ]; then
                                        echo -e "Arquivo ${ARQS_ZABBIX} criado:\t\t[\033[0;32m OK \033[0m]"
                                else
                                        echo -e "Arquivo ${ARQS_ZABBIX} criado:\t\t[\033[0;31m FALHOU \033[0m]"
                                        exit 11
                                fi
                        fi
                done

       sleep 2
}

########################################################################################
#                   Funcao: Preparando a estrutura do Zabbix Agent
########################################################################################

StructureAgtZbx(){
		for ARQS_ZABBIX in "${DIR_CONF_ZABBIX}/zabbix_agentd.conf" "${DIR_LOG_ZABBIX}/zabbix_agentd.log" "${DIR_PID_ZABBIX}/zabbix_agentd.pid" ; do
                        if [ -e "${ARQS_ZABBIX}" ]; then
                                echo -e "Arquivo ${ARQS_ZABBIX} ja existe....\t\t[\033[0;32m OK \033[0m]"
                                chown -R zabbix:zabbix ${ARQS_ZABBIX}
                        else
                                echo -e "\nArquivo ${ARQS_ZABBIX} nao existe, criando...."
                                touch ${ARQS_ZABBIX}
                                chown -R zabbix:zabbix ${ARQS_ZABBIX}
                                if [ -e "${ARQS_ZABBIX}" ]; then
                                        echo -e "Arquivo ${ARQS_ZABBIX} criado:\t\t[\033[0;32m OK \033[0m]"
                                else
                                        echo -e "Arquivo ${ARQS_ZABBIX} criado:\t\t[\033[0;31m FALHOU \033[0m]"
                                        exit 11
                                fi
                        fi
                done

       sleep 2
}

########################################################################################
# 		      Funcao: Preparando o zabbix_proxy.conf
########################################################################################

ConfPrxZbx(){

        echo -e "\n-------------------------------------------------------------"
        echo -e "\t\tPreparando as configuracoes..."
        echo -e "-------------------------------------------------------------\n"


	echo -e "Entre com o IP do Zabbix Server:\n"
	
	read SERVER_ZABBIX
	
	if [ -n $SERVER_ZABBIX ]; then
		
		echo -e "OK, atribuindo endereço IP do Zabbix Server!\n"
		
	fi

        echo -e "\nPreparando o zabbix_proxy.conf"
        echo "Server=${SERVER_ZABBIX}" > ${PATH_ZABBIX}zabbix_proxy.conf
        echo "Hostname=${HOSTNAME_ZABBIX}" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "DBHost=localhost" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "DBName=${DB_ZABBIX}" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "DebugLevel=3" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "PidFile=${DIR_PID_ZABBIX}/zabbix_proxy.pid" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "LogFile=${DIR_LOG_ZABBIX}/zabbix_proxy.log" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "FpingLocation=$(/usr/bin/whereis fping | awk '{print $2}')" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "Fping6Location=$(/usr/bin/whereis fping6 | awk '{print $2}')" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "ExternalScripts=/usr/local/bin/externalscripts" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "Timeout=3" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "StartPollers=8" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "StartPollersUnreachable=8" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "StartTrappers=8" >> ${PATH_ZABBIX}zabbix_proxy.conf
        echo "StartPingers=4" >> ${PATH_ZABBIX}zabbix_proxy.conf

                CONT_ZABBIX_PRX=$(cat ${PATH_ZABBIX}zabbix_proxy.conf|wc -l)

                        if [ ${CONT_ZABBIX_PRX} -eq 15 ]; then
                                echo -e "Preparado:\t\t[\033[0;32m OK \033[0m]"
                        else
                                echo -e "Preparado:\t\t[\033[0;31m FALHOU \033[0m]"
                        fi

                sleep 2
}

########################################################################################
# 		   Funcao: Preparando o zabbix_agentd.conf
########################################################################################

ConfAgtZbx(){

	echo -e "Entre com o IP do Zabbix Server:\n"
	
	read PROXY_ZABBIX
	
	if [ -n $PROXY_ZABBIX ]; then
		
		echo -e "OK, atribuindo endereço IP do Zabbix Proxy!\n"
		
	fi

        echo -e "\n\nPreparando o zabbix_agentd.conf"
        echo "Server=${PROXY_ZABBIX}" > ${PATH_ZABBIX}zabbix_agentd.conf
        echo "ServerActive=${END_PROXY_ZABBIX}" >> ${PATH_ZABBIX}zabbix_agentd.conf
        echo "PidFile=/tmp/zabbix_agentd.pid" >> ${PATH_ZABBIX}zabbix_agentd.conf
        echo "LogFile=/var/log/zabbix/zabbix_agentd.log" >> ${PATH_ZABBIX}zabbix_agentd.conf
        echo "LogFileSize=3" >> ${PATH_ZABBIX}zabbix_agentd.conf
        echo "DebugLevel=3" >> ${PATH_ZABBIX}zabbix_agentd.conf
        echo "Hostname=${HOSTNAME_ZABBIX}" >> ${PATH_ZABBIX}zabbix_agentd.conf
        echo "RefreshActiveChecks=120" >> ${PATH_ZABBIX}zabbix_agentd.conf

                CONT_ZABBIX_AGT=$(cat ${PATH_ZABBIX}zabbix_agentd.conf|wc -l)
                        if [ ${CONT_ZABBIX_AGT} -eq 8 ]; then
                                echo -e "Preparado:\t\t[\033[0;32m OK \033[0m]"
                        else
                                echo -e "Preparado:\t\t[\033[0;31m FALHOU \033[0m]"
                        fi

                sleep 2
}

########################################################################################
#			Funcao: Copiando o Daemon Agent (Debian)
########################################################################################

DaemonDebAgtZbx(){

	echo -e "\n-------------------------------------------------------------"
	echo -e "Preparando o Daemon zabbix-agent para o ${DIR_DAEMON_ZABBIX}zabbix-agent...."
	echo -e "-------------------------------------------------------------\n"

	cd ${DIR_ZABBIX}

	cp misc/init.d/debian/zabbix-agent ${DIR_DAEMON_ZABBIX}

	# Retirando as 6 primeiras linhas do zabbix-agent
	sed '1,10 d' ${DIR_DAEMON_ZABBIX}zabbix-agent > ${DIR_DAEMON_ZABBIX}res

	# Adicionando esse padrao de Daemon no zabbix-agent
	echo -e "#!/bin/bash\n\n### BEGIN INIT INFO
	# Provides: Zabbix-Agent-Daemon
	# Required-Start: \$local_fs \$remote_fs \$network \$syslog
	# Required-Stop: \$local_fs \$remote_fs \$network \$syslog
	# Default-Start: 2 3 4 5
	# Default-Stop: 0 1 6
	# Short-Description: Daemon do Zabbix Agent
	# Description: Ativar o daemon do Zabbix Agent by Elvis Suffi Pompeu
	### END INIT INFO\n\nNAME=zabbix_agentd
	DAEMON=/usr/local/sbin/\${NAME}
	DESC='Zabbix agent daemon'
	PID=${DIR_PID_ZABBIX}/\$NAME.pid" > ${DIR_DAEMON_ZABBIX}zabbix-agent

	cat ${DIR_DAEMON_ZABBIX}res >> ${DIR_DAEMON_ZABBIX}zabbix-agent
	rm ${DIR_DAEMON_ZABBIX}res

	# Setando as permissoes de execucao no zabbix-agent
	chmod +x ${DIR_DAEMON_ZABBIX}zabbix-agent

        	if [ ${?} -eq 0 ]; then
                	echo -e "Preparado permissao:\t\t[\033[0;32m OK \033[0m]"
        	else
                	echo -e "\nPreparado permissao:\t\t[\033[0;31m FALHOU \033[0m]"
        	fi

	sleep 2
}

########################################################################################
#			Funcao: Copiando o Daemon Proxy (Debian)
########################################################################################

DaemonDebPrxZbx(){

	echo -e "\n-------------------------------------------------------------"
	echo -e "Preparando o Daemon zabbix-proxy para o ${DIR_DAEMON_ZABBIX}zabbix-proxy...."
	echo -e "-------------------------------------------------------------\n"

	cd ${DIR_ZABBIX}

	cp misc/init.d/debian/zabbix-server ${DIR_DAEMON_ZABBIX}zabbix-proxy

	# Retirando as 6 primeiras linhas do zabbix-proxy
	sed '1,10 d' ${DIR_DAEMON_ZABBIX}zabbix-proxy > ${DIR_DAEMON_ZABBIX}res

	# Adicionando esse padrao de Daemon no zabbix-proxy
	echo -e "#!/bin/sh\n\n### BEGIN INIT INFO
	# Provides: Zabbix-Proxy-Daemon
	# Required-Start: \$local_fs \$remote_fs \$network \$syslog
	# Required-Stop: \$local_fs \$remote_fs \$network \$syslog
	# Default-Start: 2 3 4 5
	# Default-Stop: 0 1 6
	# Short-Description: Daemon do Zabbix Agent
	# Description: Ativar o daemon do Zabbix Proxy by Elvis Suffi Pompeu
	### END INIT INFO\n\nNAME=zabbix_proxy
	DAEMON=/usr/local/sbin/\${NAME}
	DESC='Zabbix Proxy Daemon'
	PID=${DIR_PID_ZABBIX}/\${NAME}.pid" > ${DIR_DAEMON_ZABBIX}zabbix-proxy
	cat ${DIR_DAEMON_ZABBIX}res >> ${DIR_DAEMON_ZABBIX}zabbix-proxy
	rm ${DIR_DAEMON_ZABBIX}res

	# Setando as permissoes de execucao no zabbix-proxy
	chmod +x ${DIR_DAEMON_ZABBIX}zabbix-proxy
        
		if [ ${?} -eq 0 ]; then
                	echo -e "\nPreparado permissao:\t\t[\033[0;32m OK \033[0m]"
        	else
                	echo -e "\nPreparado permissao:\t\t[\033[0;31m FALHOU \033[0m]"
        	fi

	sleep 2
	}

# FAZER DAEMON PRO CENTOS

########################################################################################
#	Funcao: Preparando o zabbix-agent para ser executado durante o boot. (Debian)
########################################################################################

BootDebAgtZbx(){

	cd ${DIR_DAEMON_ZABBIX}

	echo -e "\n-------------------------------------------------------------"
	echo -e "Preparando o zabbix-agent para ser executado durante o boot..."
	echo -e "-------------------------------------------------------------\n"

	insserv -d -f zabbix-agent

        if [ ${?} -eq 0 ]; then
                echo -e "Preparado para executar no boot:\t\t[\033[0;32m OK \033[0m]"
        else
                echo -e "Preparado para executar no boot:\t\t[\033[0;31m FALHOU \033[0m]"
        fi

	sleep 2

	# Inicia o servico do Zabbix Agentd
	/etc/init.d/zabbix-agent start > /dev/null

	CONT_SERVICE_ZABBIX_AGT=$(ps ax|grep zabbix_agentd|wc -l)

        	if [ ${CONT_SERVICE_ZABBIX_AGT} -gt 1 ]; then
                	echo -e "Processo zabbix-agentd iniciado:\t\t[\033[0;32m OK \033[0m]"
        	else
                	echo -e "Processo zabbix-agentd iniciado:\t\t[\033[0;31m FALHOU \033[0m]"
        	fi

	sleep 1
}

########################################################################################
#	Funcao: Preparando o zabbix-proxy para ser executado durante o boot. (Debian)
########################################################################################

BootDebPrxZbx(){

	cd ${DIR_DAEMON_ZABBIX}

	echo -e "\n-------------------------------------------------------------"
	echo -e "Preparando o zabbix-proxy para ser executado durante o boot..."
	echo -e "-------------------------------------------------------------\n"
	
	insserv -d -f zabbix-proxy
        
		if [ ${?} -eq 0 ]; then
                	echo -e "Preparado para executar no boot:\t\t[\033[0;32m OK \033[0m]"
        	else
                	echo -e "Preparado para executar no boot:\t\t[\033[0;31m FALHOU \033[0m]"
        	fi

	sleep 1

	# Inicia o servico do Zabbix Proxy
	/etc/init.d/zabbix-proxy start > /dev/null
	
	CONT_SERVICE_ZABBIX_PRX=$(ps ax|grep zabbix_proxy|wc -l)
        
	if [ ${CONT_SERVICE_ZABBIX_PRX} -gt 1 ]; then
                echo -e "Processo zabbix-proxy iniciado:\t\t[\033[0;32m OK \033[0m]"
        else
                echo -e "Processo zabbix-proxy iniciado:\t\t[\033[0;31m FALHOU \033[0m]"
        fi

	sleep 1

	echo -e "\n"

}


########################################################################################
#       		Funcao: Verifica a versao do CentOS
########################################################################################

CheckVersionCentOS(){

	VERSIONCENT=$(grep -i "CentOS release 6" /etc/issue | wc -l)
		
		if [ ${VERSIONCENT} -eq 1 ]; then
		
			${RPM} -ivh http://repo.plenatech.com.br/el6/i386/plenatech-repo-1.0-12.el6.pl.noarch.rpm
			yum update

				if [ ${?} -eq 0 ]; then

                                        echo -e "Atualizando repositorio:\t\t[\033[0;32m OK \033[0m]"
                                else

                                        echo -e "Atualizando repositorio:\t\t[\033[0;31m FALHOU \033[0m]"

                                fi			

		fi		

	VERSIONCENT=$(grep -i "CentOS release 5" /etc/issue | wc -l)

		if [ ${VERSIONCENT} -eq 1 ]; then
			
			${RPM} -ivh http://repo.plenatech.com.br/el5/i386/plenatech-repo-1.0-12.el5.pl.noarch.rpm
			yum update
			
				if [ ${?} -eq 0 ]; then
			
					echo -e "Atualizando repositorio:\t\t[\033[0;32m OK \033[0m]"		
				else
					
					echo -e "Atualizando repositorio:\t\t[\033[0;31m FALHOU \033[0m]"				

				fi
		fi

}


########################################################################################
#                      Funcao: Instala as Dependencias do CentOS
########################################################################################

DepCenPrxZbx(){

	${YUM_REPO} -y install sqlite sqlite-devel net-snmp net-snmp-devel net-snmp-utils net-snmp-libs gcc gcc-devel gcc-devel curl curl-devel libssh2 libssh2-devel fping
	
		if [ ${?} -eq 0 ]; then
	
			echo -e "Instalando dependencias:\t\t[\033[0;32m OK \033[0m]"
				
		else

			echo -e "Instalando dependencias:\t\t[\033[0;31m FALHOU \033[0m]"

		fi

}

########################################################################################
#                      Funcao: Instala as Dependencias do CentOS
########################################################################################

DepCenAgtZbx(){

        ${YUM_REPO} -y install net-snmp net-snmp-devel net-snmp-utils net-snmp-libs gcc gcc-devel gcc-devel curl curl-devel libssh2 libssh2-devel fping

                if [ ${?} -eq 0 ]; then

                        echo -e "Instalando dependencias:\t\t[\033[0;32m OK \033[0m]"

                else

                        echo -e "Instalando dependencias:\t\t[\033[0;31m FALHOU \033[0m]"

                fi

}

########################################################################################
#                      Funcao: Adiciona o Zabbix Proxy no Boot do CentOS
########################################################################################

BootCenPrxZbx(){

	echo -e "$(/usr/bin/whereis zabbix_proxy | awk '{print $2}')" >> /etc/rc.d/rc.local

		TESTERCLOCAL=$(grep zabbix_proxy /etc/rc.d/rc.local | wc -l)
	
			if [ ${TESTERCLOCAL} -eq 1 ]; then
	
				echo -e "Adicionado no boot:\t\t[\033[0;32m OK \033[0m]"

			else

				echo -e "Adicionado no boot:\t\t[\033[0;31m FALHOU \033[0m]"

			fi


}

########################################################################################
#                      Funcao: Adiciona o Zabbix Proxy no Boot do CentOS
########################################################################################

BootCenAgtZbx(){

        echo -e "$(/usr/bin/whereis zabbix_agentd | awk '{print $2}')" >> /etc/rc.d/rc.local

		TESTERCLOCAL=$(grep zabbix_agentd /etc/rc.d/rc.local | wc -l)

                        if [ ${TESTERCLOCAL} -eq 1 ]; then

                                echo -e "Adicionado no boot:\t\t[\033[0;32m OK \033[0m]"

                        else

                                echo -e "Adicionado no boot:\t\t[\033[0;31m FALHOU \033[0m]"

                        fi
}

# ------------------------------FIM-DAS-FUNCOES-----------------------------------------


########################################################################################
#       	Estrutura de Decisao: Selecao de Distribuicao Linux
########################################################################################

case $1 in

	debian)

		echo -e "\nDigite o numero para instalar: \n\n\n \033[0;32m 1)\033[0m Zabbix Proxy + Zabbix Agent\n \033[0;32m 2)\033[0m Zabbix Agent\n\nOpcao[ENTER]:\n"
		read OPCAO

			if [ ${OPCAO} -eq 1 ]; then
	
				cd ${DIR_DOWNLOAD}
				AddUserZabbix
				AddGrpDebZabbix
				ZabbixDownload
				DescompactaZabbix
				DepDebPrxZbx
				DepDebAgtZbx
				CreateDataBasePrxZbx
				CreateTreeZbx
				StructurePrxZbx
				StructureAgtZbx
				ConfPrxZbx
				ConfAgtZbx
				ZabbixProxyDebInstall
				DaemonDebAgtZbx
				DaemonDebPrxZbx
				BootDebAgtZbx
				BootDebPrxZbx
				rm -rf ${DIR_ZABBIX}
                                rm -rf ${DIR_DOWNLOAD}/zabbix-*
				echo -e "\n\t FIM :) \n"; exit 0			

			elif [ ${OPCAO} -eq 2 ]; then

				cd ${DIR_DOWNLOAD}
				AddUserZabbix
				AddGrpDebZabbix
				ZabbixDownload
				DescompactaZabbix
				DepDebAgtZbx
				CreateTreeZbx
				StructureAgtZbx
				ConfAgtZbx
				ZabbixAgentDebInstall
				DaemonDebAgtZbx
				BootDebAgtZbx
				rm -rf ${DIR_ZABBIX}
                                rm -rf ${DIR_DOWNLOAD}/zabbix-*
			 	echo -e "\n\t FIM :) \n"; exit 0
			
			else
	
			echo -e	"\nExiste apenas alternativa 1 ou 2!\n"
			exit 1
			fi

;;

	centos) 

		echo -e "\nDigite o numero para instalar: \n\n\n1) Zabbix Proxy + Zabbix Agent\n2) Zabbix Agent\n\nOpcao[ENTER]:\n"
                read OPCAO

                        if [ ${OPCAO} -eq 1 ]; then

				cd ${DIR_DOWNLOAD}
				CheckVersionCentOS
                                AddUserZabbix
                                ZabbixDownload
                                DescompactaZabbix
                                DepCenPrxZbx
				CreateDataBasePrxZbx
                                CreateTreeZbx
                                StructurePrxZbx
                                StructureAgtZbx
                                ConfPrxZbx
                                ConfAgtZbx
                                ZabbixProxyCenInstall
                                #DaemonCenAgtZbx
                                #DaemonCenPrxZbx
                                BootCenAgtZbx
                                BootCenPrxZbx
				rm -rf ${DIR_ZABBIX}
				rm -rf ${DIR_DOWNLOAD}/zabbix-*
                                echo -e "\n\t 			FIM :) \n"; exit 0

                        elif [ ${OPCAO} -eq 2 ]; then

                                cd ${DIR_DOWNLOAD}
				CheckVersionCentOS
				AddUserZabbix
                                ZabbixDownload
                                DescompactaZabbix
				DepCenAgtZbx
                                CreateTreeZbx
                                StructureAgtZbx
                                ConfAgtZbx
                                ZabbixAgentCenInstall
                                #DaemonCenAgtZbx
                                BootCenAgtZbx
                                rm -rf ${DIR_ZABBIX}
                                rm -rf ${DIR_DOWNLOAD}/zabbix-*
				echo -e "\n\t FIM :) \n"; exit 0

                        else

                        echo -e "\nExiste apenas alternativa 1 ou 2!\n"
                        exit 1
                        fi

;;

*) echo "Use: debian ou centos. Exemplo: root@${HOSTNAME}:${PWD}# $0 debian" ;;

esac

# -------------------------------------EOF---------------------------------------------
