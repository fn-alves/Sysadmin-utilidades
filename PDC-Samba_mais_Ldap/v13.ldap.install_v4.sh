#!/bin/bash
######################################################## 
#                                                      #
#    Script para Instalação Serviço SAMBA & LDAP       #
#                                                      # 
#       Criado por Edson Rosa dos Santos Júnior        #
#             edsonrsjr@yahoo.com.br                   #
#                                                      #
#                      V13                             #
########################################################

clear

echo "    Este SCRIPT fará a instalação de um servidor SAMBA/LDAP"
echo ""
echo "    se já existirem configurações, estas serão apagadas!"
echo ""
echo ""
echo ""
echo "    Entre com os valores desejados no inicio do SCRIPT e"
echo "    responda aos dialogos apresentados nas janelas azuis"
echo "    do processo de instalação com <ENTER>"
echo ""
echo ""
echo ""
echo "    A senha de root local sera setada para a mesma do"
echo "    administrador do LDAP"
echo ""
echo ""
echo ""
echo "    Certifique-se de ter os repositorios de internet"
echo "    configurados para sua distro"
echo ""
echo ""
echo ""

if [ -f ./info.ldap.txt ];then
	rm ./info.ldap.txt
fi

if [ ! -d /mnt/configurador ];then
	mkdir -p /mnt/configurador
fi

echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

##########################################
#                                        #
#      Variaveis     do     DOMINIO      #
#                                        #
##########################################

echo "Deseja REINSTALAR um DOMINIO informando o SID? Lembre-se que"
echo "sera necessario possuir o arquivo ldif ou a copia do banco de"
echo "dados /var/lib/ldap"
echo ""
read -p "REINSTALAR um DOMINIO informando o SID ( N / s ):  " REINSTALAR
if [ "$REINSTALAR" = "" ];then
	REINSTALAR="N"
	else
	if [ `echo $REINSTALAR | tr '[:lower:]' '[:upper:]'` = "N" ];then
		REINSTALAR="N"
		else
		if [ `echo $REINSTALAR | tr '[:lower:]' '[:upper:]'` = "NAO" ];then
			REINSTALAR="N"
			else
			read -p "Informe o SID do DOMINIO (Ex: S-1-5-21-1829205145-2526807370-2697981366) :  " SID
			REINSTALAR="S"
		fi
	fi
fi

echo ""
echo ""

read -p "Entre com o nome de DOMINIO completo: (exemplo.com.br) " DOMINIO
while [ "$DOMINIO" = "" ];do
	clear
	read -p "Entre com o nome de DOMINIO completo: " DOMINIO
done
echo ""

read -p "Endereço IP utilizado no servidor: " IPADDRESS
while [ "$IPADDRESS" = "" ];do
	read -p "Endereço IP utilizado no servidor: " IPADDRESS
done
echo ""

read -p "Mascara de REDE: " MASK
while [ "$MASK" = "" ];do
	read -p "Mascara de REDE: " MASK
done
echo ""

read -p "Entre com a senha para o LDAP SAMBA : " PASSWORD
echo ""

read -p "Entre com o nome de DOMINIO SAMBA ( `echo $DOMINIO | tr '[:lower:]' '[:upper:]' | cut -d"." -f1` ): " DSAMBA
	if [ "$DSAMBA" = "" ];then
		DSAMBA="`echo $DOMINIO | tr '[:lower:]' '[:upper:]' | cut -d"." -f1`"
	fi
echo ""

read -p "Entre com o nome de NETBIOS: " NTNAME
while [ "$NTNAME" = "" ];do
	read -p "Entre com o nome de NETBIOS: " NTNAME
done
echo ""

read -p "Entre com o Server String: " SVSTRING
echo ""

read -p "Deseja utilizar PERFIL MOVEL? ( N / s ):  " REMOTO
if [ "$REMOTO" = "" ];then
	REMOTO="N"
	else
	if [ `echo $REMOTO | tr '[:lower:]' '[:upper:]'` != "S" ];then
		REMOTO="N"
		else
		REMOTO="S"
	fi
fi
echo ""

read -p "Entre com o local do home ( padrao /home ): " SMBHOME
	if [ "$SMBHOME" = "" ];then
		SMBHOME="/home"
	fi
echo ""

read -p "Entre com o local do netlogon ( $SMBHOME/netlogon ): " SMBNETLOGON
	if [ "$SMBNETLOGON" = "" ];then
		SMBNETLOGON="$SMBHOME/netlogon"
	fi
echo ""

read -p "Entre com o local do profiles ( $SMBHOME/profiles ): " SMBPROFILES
	if [ "$SMBPROFILES" = "" ];then
		SMBPROFILES="$SMBHOME/profiles"
	fi
echo ""

read -p "Entre com o local do usr ( $SMBHOME ): " SMBUSR
	if [ "$SMBUSR" = "" ];then
		SMBUSR="$SMBHOME"
	fi
echo ""

read -p "Entre com o mapeamento ( P: ): " SMBMAP
	if [ "$SMBMAP" = "" ];then
		SMBMAP="P:"
	fi
echo ""

read -p "Entre com a CRIPTOGRAFIA DESEJADA ( cleartext, crypt, md5, smd5 sha, SSHA ): " CRIPTO
	if [ "$CRIPTO" = "" ];then
		CRIPTO="SSHA"
		else
		CRIPTO="`echo $CRIPTO | tr '[:lower:] ' '[:upper:]'`"
	fi
echo ""

##########################################
#                                        #
#     Setando a Senha de root Local      #
#                                        #
##########################################

if [ "`grep ldap /etc/nsswitch.conf`" = "" ];then

	echo ""
	echo " Atualizando a senha de root "
	echo ""

	( echo $PASSWORD; echo $PASSWORD ) | passwd root
	echo ""
	echo ""

	else

		echo ""
		echo " Atualizando a senha de root "
		echo ""

		echo "account	required	pam_unix.so" > /etc/pam.d/common-account
		echo "auth	required	pam_unix.so nullok_secure" > /etc/pam.d/common-auth
		echo "password	required	pam_unix.so nullok obscure min=4 max=8 md5" > /etc/pam.d/common-password
		echo "session	required	pam_unix.so" > /etc/pam.d/common-session

		echo "passwd:         compat" > /etc/nsswitch.conf 
		echo "group:          compat" >> /etc/nsswitch.conf 
		echo "shadow:         compat" >> /etc/nsswitch.conf
		echo "" >> /etc/nsswitch.conf 
		echo "hosts:          files dns" >> /etc/nsswitch.conf 
		echo "networks:       files" >> /etc/nsswitch.conf
		echo "" >> /etc/nsswitch.conf 
		echo "protocols:      db files" >> /etc/nsswitch.conf 
		echo "services:       db files" >> /etc/nsswitch.conf 
		echo "ethers:         db files" >> /etc/nsswitch.conf 
		echo "rpc:            db files" >> /etc/nsswitch.conf
		echo "" >> /etc/nsswitch.conf
		echo "netgroup:       nis" >> /etc/nsswitch.conf 

		( echo $PASSWORD; echo $PASSWORD ) | passwd root
		echo ""
		echo ""
fi

##########################################
#                                        #
#       Configurando BACKPORTS           #
#            DEBIAN LENNY                #
#                                        #
##########################################

if [ "`cat /etc/debian_version | cut -c\-\2`" = "5." ];then

   if [ "`grep debian-backports /etc/apt/sources.list`" = "" ];then

      echo "" >> /etc/apt/sources.list
      echo "" >> /etc/apt/sources.list
      echo "deb http://archive.debian.org/debian-backports lenny-backports main contrib non-free" >> /etc/apt/sources.list
      echo "" >> /etc/apt/sources.list
      DISTRO="LENNY"

   fi

fi

##########################################
#                                        #
#   Carregando atualizacao dos Pacotes   #
#                                        #
##########################################

apt-get update

##########################################
#                                        #
# Instalando   Pacotes   dos   Serviços  #
#                                        #  
#               LDAP                     #
#               SAMBA                    #
#               APACHE                   #
#               PHPLDAPADMIN             #
#                                        #
##########################################

if test `ps -e | grep smbd | cut -d" " -f 12 | tail -n1`;then

   if [ -f /etc/init.d/smbd ];then 

      service samba stop

      else
   
      /etc/init.d/samba stop

   fi
      
   rm /var/lib/samba/secrets.tdb

fi

if test `ps -e | grep slapd | cut -d" " -f 12 | tail -n1`;then

   /etc/init.d/slapd stop
#   /etc/init.d/nscd stop
   rm /var/lib/ldap/*
   rm /etc/ldap/slapd.d/*

fi

##########################################
#                                        #
#    Instalando    Pacotes   do   LDAP   #
#                                        #
##########################################

if [ "$DISTRO" = "LENNY" ];then

	apt-get install -t lenny-backports -y --force-yes samba samba-common samba-doc smbclient smbfs smbldap-tools
	apt-get install -y --force-yes slapd ldap-utils db4.8-util libpam-ldap libnss-ldap nscd libpam-foreground mcrypt libgd-tools resolvconf nfs-kernel-server ssl-cert

	else
	apt-get install -y --force-yes slapd ldap-utils db4.8-util libpam-ldap libnss-ldap nscd libpam-foreground mcrypt libgd-tools samba samba-common samba-doc smbclient cifs-utils smbldap-tools resolvconf nfs-kernel-server ssl-cert
		
fi

if [ "$REINSTALAR" = "S" ];then
	net setlocalsid $SID
fi


##########################################
#                                        #
#            samba.schema                #
#                                        #
##########################################

zcat /usr/share/doc/samba-doc/examples/LDAP/samba.schema.gz > /etc/ldap/schema/samba.schema

##########################################
#                                        #
#    Configurando    /etc/resolv.conf    #
#                                        #
##########################################

echo "search `echo $DOMINIO | tr '[:upper:]' '[:lower:]'` localdomain" > /etc/resolv.conf

echo "nameserver $IPADDRESS" >> /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolv.conf

##########################################
#                                        #
#     Configurando     /etc/hosts        #
#                                        #
##########################################

echo "127.0.0.1		localhost.localdomain		localhost"  >  /etc/hosts
echo "$IPADDRESS	`uname -n`.`echo $DOMINIO | tr '[:upper:]' '[:lower:]'`		`uname -n`" >> /etc/hosts

##########################################
#                                        #
#    Configurando    /etc/host.conf      #
#                                        #
##########################################

echo "order hosts,bind"  >  /etc/host.conf
echo "multi on" >> /etc/host.conf

##########################################
#                                        #
#         etc/ldap/slapd.conf            #
#                                        #
##########################################

echo "include         /etc/ldap/schema/core.schema" > /etc/ldap/slapd.conf
echo "include         /etc/ldap/schema/cosine.schema" >> /etc/ldap/slapd.conf
echo "include         /etc/ldap/schema/nis.schema" >> /etc/ldap/slapd.conf
echo "include         /etc/ldap/schema/inetorgperson.schema" >> /etc/ldap/slapd.conf
echo "include         /etc/ldap/schema/misc.schema" >> /etc/ldap/slapd.conf
echo "include         /etc/ldap/schema/samba.schema" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "pidfile         /var/run/slapd/slapd.pid" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "argsfile        /var/run/slapd/slapd.args" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "loglevel        64" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "modulepath	/usr/lib/ldap" >> /etc/ldap/slapd.conf
echo "moduleload	back_bdb" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "sizelimit 500" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "tool-threads 1" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "backend	bdb" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "database bdb" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "suffix \"dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\"" >> /etc/ldap/slapd.conf
echo "rootdn \"cn=admin,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\"" >> /etc/ldap/slapd.conf
echo "rootpw `slappasswd -h {$(echo $CRIPTO | tr '[:lower:]' '[:upper:]')} -s $PASSWORD`" >> /etc/ldap/slapd.conf
echo "directory \"/var/lib/ldap\"" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "dbconfig set_cachesize 0 2097152 0" >> /etc/ldap/slapd.conf
echo "dbconfig set_lk_max_objects 1500" >> /etc/ldap/slapd.conf
echo "dbconfig set_lk_max_locks 1500" >> /etc/ldap/slapd.conf
echo "dbconfig set_lk_max_lockers 1500" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "index objectClass                             eq" >> /etc/ldap/slapd.conf
echo "index uid,uidNumber,gidNumber,memberUid       eq" >> /etc/ldap/slapd.conf
echo "index sn,displayName                          pres,sub,eq" >> /etc/ldap/slapd.conf
echo "index cn,mail,givenname		            eq,subinitial" >> /etc/ldap/slapd.conf
echo "index sambaSID                                eq" >> /etc/ldap/slapd.conf
echo "index sambaPrimaryGroupSID                    eq" >> /etc/ldap/slapd.conf
echo "index sambaDomainName                         eq" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "lastmod on" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "checkpoint 512 30" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "access to attrs=userPassword" >> /etc/ldap/slapd.conf
echo "        by dn=\"cn=admin,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\" write" >> /etc/ldap/slapd.conf
echo "        by dn=\"cn=`uname -n`,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\" write" >> /etc/ldap/slapd.conf
echo "        by dn=\"uid=smbclient,ou=Users,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\" write" >> /etc/ldap/slapd.conf
echo "        by dn=\"cn=root,ou=Groups,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\" write" >> /etc/ldap/slapd.conf
echo "        by anonymous auth" >> /etc/ldap/slapd.conf
echo "        by self write" >> /etc/ldap/slapd.conf
echo "        by * none" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "access to *" >> /etc/ldap/slapd.conf
echo "        by dn=\"cn=admin,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\" write" >> /etc/ldap/slapd.conf
echo "        by dn=\"cn=`uname -n`,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\" write" >> /etc/ldap/slapd.conf
echo "        by dn=\"uid=smbclient,ou=Users,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\" write" >> /etc/ldap/slapd.conf
echo "        by dn=\"cn=root,ou=Groups,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\" write" >> /etc/ldap/slapd.conf
echo "        by * read" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf
echo "access to dn.base=\"\" by * read" >> /etc/ldap/slapd.conf
echo "" >> /etc/ldap/slapd.conf

chown openldap.openldap /etc/ldap/slapd.conf

##########################################
#                                        #
#          etc/ldap/ldap.conf            #
#                                        #
##########################################

echo "BASE dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`" > /etc/ldap/ldap.conf
echo "URI ldaps://`uname -n`.`echo $DOMINIO | tr '[:upper:]' '[:lower:]'`/" >> /etc/ldap/ldap.conf
echo "" >> /etc/ldap/ldap.conf
echo "HOST 127.0.0.1" >> /etc/ldap/ldap.conf
echo "" >> /etc/ldap/ldap.conf
echo "rootbinddn cn=admin,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`" >> /etc/ldap/ldap.conf
echo "" >> /etc/ldap/ldap.conf
echo "nss_base_passwd ou=Users,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`?sub" >> /etc/ldap/ldap.conf
echo "nss_base_passwd ou=Computers,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`?sub" >> /etc/ldap/ldap.conf
echo "nss_base_shadow ou=Users,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`?sub" >> /etc/ldap/ldap.conf
echo "nss_base_group ou=Groups,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`?sub" >> /etc/ldap/ldap.conf
echo "" >> /etc/ldap/ldap.conf
echo "" >> /etc/ldap/ldap.conf
echo "ssl yes" >> /etc/ldap/ldap.conf

chown openldap.openldap /etc/ldap/ldap.conf

##########################################
#                                        #
#  etc/smbldap-tools/smbldap_bind.conf   #
#                                        #
##########################################

echo "slaveDN=\"cn=admin,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\"" > /etc/smbldap-tools/smbldap_bind.conf
echo "slavePw=\"$PASSWORD\"" >> /etc/smbldap-tools/smbldap_bind.conf
echo "masterDN=\"cn=admin,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\"" >> /etc/smbldap-tools/smbldap_bind.conf
echo "masterPw=\"$PASSWORD\"" >> /etc/smbldap-tools/smbldap_bind.conf

chmod 600 /etc/smbldap-tools/smbldap_bind.conf

##########################################
#                                        #
#           etc/nsswitch.conf            #
#                                        #
##########################################

echo "passwd:         compat ldap" > /etc/nsswitch.conf
echo "group:          compat ldap" >> /etc/nsswitch.conf
echo "shadow:         compat ldap" >> /etc/nsswitch.conf
echo "" >> /etc/nsswitch.conf
echo "hosts:          files dns" >> /etc/nsswitch.conf
echo "networks:       files" >> /etc/nsswitch.conf
echo "" >> /etc/nsswitch.conf
echo "protocols:      db files" >> /etc/nsswitch.conf
echo "services:       db files" >> /etc/nsswitch.conf
echo "ethers:         db files" >> /etc/nsswitch.conf
echo "rpc:            db files" >> /etc/nsswitch.conf
echo "" >> /etc/nsswitch.conf
echo "netgroup:       nis" >> /etc/nsswitch.conf

##########################################
#                                        #
#          etc/libnss-ldap.conf          #
#                                        #
##########################################

echo "host 127.0.0.1" > /etc/libnss-ldap.conf 
echo "base dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`" >> /etc/libnss-ldap.conf
echo "ldap_version 3" >> /etc/libnss-ldap.conf
echo "" >> /etc/libnss-ldap.conf
echo "nss_base_passwd	ou=Users,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`" >> /etc/libnss-ldap.conf
echo "nss_base_passwd	ou=Computers,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`" >> /etc/libnss-ldap.conf
echo "nss_base_shadow	ou=Users,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`" >> /etc/libnss-ldap.conf
echo "nss_base_group	ou=Groups,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`" >> /etc/libnss-ldap.conf

##########################################
#                                        #
#          etc/pam.d/common-auth         #
#                                        #
##########################################

echo "auth	sufficient	pam_ldap.so" > /etc/pam.d/common-auth
echo "auth	required	pam_unix.so nullok_secure try_first_pass shadow crypt" >> /etc/pam.d/common-auth

##########################################
#                                        #
#         etc/pam.d/common-account       #
#                                        #
##########################################

echo "account	sufficient	pam_ldap.so" > /etc/pam.d/common-account
echo "account	required	pam_unix.so try_first_pass" >> /etc/pam.d/common-account

##########################################
#                                        #
#        etc/pam.d/common-password       #
#                                        #
##########################################

echo "password   sufficient   pam_ldap.so" > /etc/pam.d/common-password
echo "password   required  	pam_unix.so nullok obscure min=4 max=8 try_first_pass crypt shadow" >> /etc/pam.d/common-password

##########################################
#                                        #
#        etc/pam.d/common-session        #
#                                        #
##########################################

echo "session 	sufficient	pam_ldap.so" > /etc/pam.d/common-session
echo "session	required	pam_unix.so try_frist_pass shadow" >> /etc/pam.d/common-session
echo "session	optional	pam_mkhomedir.so skel=/etc/skel umask=077" >> /etc/pam.d/common-session

##########################################
#                                        #
#             etc/pam_ldap.conf          #
#                                        #
##########################################

echo "host 127.0.0.1" > /etc/pam_ldap.conf
echo "base dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`" >> /etc/pam_ldap.conf
echo "ldap_version 3" >> /etc/pam_ldap.conf
echo "#pam_password `echo $CRIPTO | tr '[:upper:]' '[:lower:]' `" >> /etc/pam_ldap.conf
echo "" >> /etc/pam_ldap.conf
echo "nss_base_passwd	ou=Users,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`?sub" >> /etc/pam_ldap.conf
echo "nss_base_passwd	ou=Computers,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`?sub" >> /etc/pam_ldap.conf
echo "nss_base_shadow	ou=Users,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`?sub" >> /etc/pam_ldap.conf
echo "nss_base_group 	ou=Groups,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`?sub" >> /etc/pam_ldap.conf

##########################################
#                                        #
#        etc/libnss_ldap.secret          #
#                                        #
#         etc/pam_ldap.secret            #
#                                        #
##########################################

echo "$PASSWORD" > /etc/libnss_ldap.secret
echo "$PASSWORD" > /etc/pam_ldap.secret

chmod 600 /etc/libnss_ldap.secret
chmod 600 /etc/pam_ldap.secret

##########################################
#                                        #
#  Configurando SCRIPT de inicializacao  #
#  do SLAPD                              #
#                                        #
##########################################


/etc/init.d/slapd restart #
/etc/init.d/slapd stop #

rm -rf /etc/ldap/slapd.d/*

chown -R openldap.openldap /var/lib/ldap/*

/etc/init.d/slapd start
/etc/init.d/slapd stop #

slaptest -f /etc/ldap/slapd.conf -F /etc/ldap/slapd.d/

chown -R openldap.openldap /etc/ldap/slapd.d/*

/etc/init.d/slapd start #

##########################################
#                                        #
#  Configuracao dos diretorios de home   #
#                                        #
##########################################

if [ "`echo $SMBHOME | tr '[:upper:]' '[:lower:]'`" != "/home" ];then
	mkdir -p `echo $SMBHOME | tr '[:upper:]' '[:lower:]'`
	chmod 755 `echo $SMBHOME | tr '[:upper:]' '[:lower:]'`
fi

mkdir -p `echo $SMBNETLOGON | tr '[:upper:]' '[:lower:]'`

mkdir -p `echo $SMBPROFILES | tr '[:upper:]' '[:lower:]'`
chmod 770 `echo $SMBPROFILES | tr '[:upper:]' '[:lower:]'`


if [ "`echo $SMBUSR | tr '[:upper:]' '[:lower:]'`" != "/home" ];then
	mkdir -p `echo $SMBUSR | tr '[:upper:]' '[:lower:]'`
	chmod 755 `echo $SMBUSR | tr '[:upper:]' '[:lower:]'`
fi

##########################################
#                                        #
#     etc/samba/smb.conf COM LDAP        #
#                                        #
##########################################

echo "[global]" > /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	#	Configuracao da Estacao      #" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	workgroup 			= `echo $DSAMBA | tr '[:lower:]' '[:upper:]'`" >> /etc/samba/smb.conf
echo "	netbios name 			= `echo $NTNAME | tr '[:lower:]' '[:upper:]'`" >> /etc/samba/smb.conf
echo "	server string 			= $SVSTRING" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	#	Configuracao P D C           #" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	security			= user" >> /etc/samba/smb.conf
echo "	domain logons			= yes" >> /etc/samba/smb.conf
echo "	preferred master		= yes" >> /etc/samba/smb.conf
echo "	domain master			= yes" >> /etc/samba/smb.conf
echo "	os level			= 65" >> /etc/samba/smb.conf
echo "	wins support			= yes" >> /etc/samba/smb.conf
echo "	obey pam restrictions		= no" >> /etc/samba/smb.conf
echo "	encrypt passwords	 	= yes" >> /etc/samba/smb.conf
echo "	mangling method			= hash2" >> /etc/samba/smb.conf
echo "	password server 		= *" >> /etc/samba/smb.conf
echo "	nt acl support 			= yes" >> /etc/samba/smb.conf
echo "	client use spnego               = yes" >> /etc/samba/smb.conf
echo "	dns proxy 			= no " >> /etc/samba/smb.conf
echo "	time server 			= yes" >> /etc/samba/smb.conf
echo "	" >> /etc/samba/smb.conf
echo "	################################################" >> /etc/samba/smb.conf
echo "	#  EQUIVALENCIA DE USUARIOS UNIX e WINDOWS     #" >> /etc/samba/smb.conf
echo "	################################################" >> /etc/samba/smb.conf
echo "	username map			= /etc/samba/smbusers" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	#                                            #" >> /etc/samba/smb.conf
echo "	#             L  O  G                        #" >> /etc/samba/smb.conf
echo "	#                                            #" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	log file 			= /var/log/samba/log.%m" >> /etc/samba/smb.conf
echo "	log level			= 3" >> /etc/samba/smb.conf
echo "	max log size			= 10000" >> /etc/samba/smb.conf
echo "	debug level			= 3	" >> /etc/samba/smb.conf
echo "	syslog				= 0" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	#                                            #" >> /etc/samba/smb.conf
echo "	#             R  E  D  E                     #" >> /etc/samba/smb.conf
echo "	#                                            #" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	interfaces			= lo, eth0" >> /etc/samba/smb.conf
echo "	bind interfaces only		= no" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	#                                            #" >> /etc/samba/smb.conf
echo "	#         CARACTERISTICAS  WINDOWS           #" >> /etc/samba/smb.conf
echo "	#                                            #" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	#   Acentuacao (Internacionalizacao) #" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	dos  charset			= CP850" >> /etc/samba/smb.conf
echo "	unix charset			= ISO8859-1" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	#  Nao fazer lock nesses arquivos    #" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	veto oplock files		= /*.eml/*.nws/*.{*}/*.doc/*.xls/*.mdb/" >> /etc/samba/smb.conf
echo "	" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	#  . eh arquivo oculto               #" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	hidedotfiles			= yes" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	#  Simular Lixeira do Windows        #" >> /etc/samba/smb.conf
echo "	######################################" >> /etc/samba/smb.conf
echo "	vfs object                      = /usr/lib/samba/vfs/recycle.so" >> /etc/samba/smb.conf
echo "	recycle:keeptree		= yes" >> /etc/samba/smb.conf
echo "	recycle:exclude                 = *.tmp, *.log, *.obj, ~*.*, *.bak, *.iso, ._*" >> /etc/samba/smb.conf
echo "	" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	########                                ##########" >> /etc/samba/smb.conf
echo "	########          L D A P               ##########" >> /etc/samba/smb.conf
echo "	########                                ##########" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	passdb backend			= ldapsam:ldap://127.0.0.1" >> /etc/samba/smb.conf
echo "	ldap passwd sync		= yes" >> /etc/samba/smb.conf
echo "	ldap suffix			= dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`" >> /etc/samba/smb.conf
echo "	ldap admin dn			= cn=admin,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`" >> /etc/samba/smb.conf
echo "	ldap machine suffix		= ou=Computers" >> /etc/samba/smb.conf
echo "	ldap user suffix		= ou=Users" >> /etc/samba/smb.conf
echo "	ldap group suffix		= ou=Groups" >> /etc/samba/smb.conf
echo "	ldap idmap suffix		= ou=Users" >> /etc/samba/smb.conf
echo "	idmap backend			= ldap:ldaps://127.0.0.1" >> /etc/samba/smb.conf
echo "	idmap uid			= 10000-20000" >> /etc/samba/smb.conf
echo "	idmap gid			= 10000-20000" >> /etc/samba/smb.conf
echo "	ldap delete dn			= yes" >> /etc/samba/smb.conf
echo "	" >> /etc/samba/smb.conf
echo "	ldap ssl			= no" >> /etc/samba/smb.conf
echo "	" >> /etc/samba/smb.conf
echo "	#	Permite que os usuarios do grupo \"Administrador do Dominio\" possam " >> /etc/samba/smb.conf
echo "	#	colocar as maquinas WIN no dominio samba" >> /etc/samba/smb.conf
echo "	enable privileges		= yes" >> /etc/samba/smb.conf
echo "	" >> /etc/samba/smb.conf
echo "	#	Script utilizado para adicionar e remover usuario/grupo windows " >> /etc/samba/smb.conf
echo "	" >> /etc/samba/smb.conf
echo "	add user script			= /usr/sbin/smbldap-useradd -m \"%u\"" >> /etc/samba/smb.conf
echo "	add machine script		= /usr/sbin/smbldap-useradd -w \"%u\"" >> /etc/samba/smb.conf
echo "	add group script		= /usr/sbin/smbldap-groupadd -p \"%g\"" >> /etc/samba/smb.conf
echo "	add user to group script	= /usr/sbin/smbldap-groupmod -m \"%u\" \"%g\"" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "	delete user  script		= /usr/sbin/smbldap-userdel -r \"%u\"" >> /etc/samba/smb.conf
echo "	delete group script		= /usr/sbin/smbldap-groupdel \"%g\"" >> /etc/samba/smb.conf
echo "	delete user from group script	= /usr/sbin/smbldap-groupmod -x \"%u\" \"%g\"" >> /etc/samba/smb.conf
echo "	" >> /etc/samba/smb.conf
echo "	#" >> /etc/samba/smb.conf
echo "	#	Definir o grupo Primario do Usuario " >> /etc/samba/smb.conf
echo "	#" >> /etc/samba/smb.conf
echo "	set primary group script	= /usr/sbin/smbldap-groupmod -g \"%g\" \"%u\"" >> /etc/samba/smb.conf
echo "	#" >> /etc/samba/smb.conf
echo "	#	Recomendacoes: http://us4.samba.org " >> /etc/samba/smb.conf
echo "	#" >> /etc/samba/smb.conf
echo "	smb ports			= 139 445" >> /etc/samba/smb.conf
echo "	name resolve order		= hosts wins bcast" >> /etc/samba/smb.conf
echo "	utmp				= yes" >> /etc/samba/smb.conf
echo "	time server			= yes" >> /etc/samba/smb.conf
echo "	#tamplete shell			= /bin/false" >> /etc/samba/smb.conf
echo "	winbind use default domain	= no" >> /etc/samba/smb.conf
echo "	map acl inherit			= yes" >> /etc/samba/smb.conf
echo "	strict locking			= yes" >> /etc/samba/smb.conf
echo "	socket options			= TCP_NODELAY SO_RCVBUF=8192 SO_SNDBUF=8192" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf		
echo "" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	#                                            #" >> /etc/samba/smb.conf
echo "	#           Perfil Ambulante                 #" >> /etc/samba/smb.conf
echo "	#                                            #" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf
echo "	##############################################" >> /etc/samba/smb.conf

if [ "$REMOTO" != "N" ]; then

	echo "	#logon script			= STARTUP.BAT" >> /etc/samba/smb.conf
	echo "	logon path			= \\\\`echo $NTNAME | tr '[:lower:]' '[:upper:]'`\Profiles\%U" >> /etc/samba/smb.conf
	echo "	logon home			= \\\\`echo $NTNAME | tr '[:lower:]' '[:upper:]'`\Profiles\%U" >> /etc/samba/smb.conf
	echo "	logon drive			= $SMBMAP" >> /etc/samba/smb.conf
else

	echo "	#logon script			= STARTUP.BAT" >> /etc/samba/smb.conf
	echo "	logon path			= " >> /etc/samba/smb.conf
	echo "	logon home			= " >> /etc/samba/smb.conf
	echo "	logon drive			= " >> /etc/samba/smb.conf
fi

echo "" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	########                                  ########" >> /etc/samba/smb.conf
echo "	######## C O M P A R T I L H A M E N T O  ########" >> /etc/samba/smb.conf
echo "	########                                  ########" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "[netlogon]" >> /etc/samba/smb.conf
echo "	path				= $SMBNETLOGON" >> /etc/samba/smb.conf
echo "	browseable			= no" >> /etc/samba/smb.conf
echo "	read only			= yes" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "[Profiles]" >> /etc/samba/smb.conf
echo "	comment				= Perfil ambulante" >> /etc/samba/smb.conf
echo "	path				= $SMBPROFILES" >> /etc/samba/smb.conf
echo "	nt acl support 			= yes" >> /etc/samba/smb.conf
echo "	read only			= no" >> /etc/samba/smb.conf
echo "	browseable			= yes" >> /etc/samba/smb.conf
echo "	create mask			= 0755" >> /etc/samba/smb.conf
echo "	directory mask			= 0755" >> /etc/samba/smb.conf
echo "	guest ok			= no" >> /etc/samba/smb.conf
echo "	profile acls			= yes" >> /etc/samba/smb.conf
echo "	csc policy			= disable" >> /etc/samba/smb.conf
echo "	force user 			= %U" >> /etc/samba/smb.conf
echo "	valid users			= %U %u @\"Domain Admins\" @\"Domain Users\"" >> /etc/samba/smb.conf
echo "	write list		        = %U %u" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	########                                  ########" >> /etc/samba/smb.conf
echo "	########       D I R E T O R I O S        ########" >> /etc/samba/smb.conf
echo "	########                                  ########" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "	##################################################" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "#[Exemplo]" >> /etc/samba/smb.conf
echo "#       write list                       = @\"grupo exemplo\", @\"Domain Admins\", root" >> /etc/samba/smb.conf
echo "#       valid users                      = @\"grupo exemplo\", @\"Domain Admins\", root" >> /etc/samba/smb.conf
echo "#       path                             = /local/pasta_exemplo" >> /etc/samba/smb.conf
echo "#       unix extensions                  = no" >> /etc/samba/smb.conf
echo "#       force directory mode             = 0777" >> /etc/samba/smb.conf
echo "#       create mask                      = 0777" >> /etc/samba/smb.conf
echo "#       directory mode                   = 0777" >> /etc/samba/smb.conf
echo "#       directory mask                   = 0777" >> /etc/samba/smb.conf
echo "#       veto files 			= /*.mp3/*.wav/*.wma/*.avi/*.mpg/*.mpeg/*.mov/*.wmv/*.jpg/*.jpeg/*.bmp/*.gif/*.inf/*.exe/*.com/*.bat/*.scr/*.msi/*.bin/*.cmd/*.zip/*.tar/*.lha/*.rar/*.gz/*.bz/*.bz2/" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "[Configurador]" >> /etc/samba/smb.conf
echo "	comment				= Configurador de Clientes" >> /etc/samba/smb.conf
echo "	path				= /mnt/configurador" >> /etc/samba/smb.conf
echo "	nt acl support 			= yes" >> /etc/samba/smb.conf
echo "	read only			= no" >> /etc/samba/smb.conf
echo "	browseable			= yes" >> /etc/samba/smb.conf
echo "	create mask			= 0755" >> /etc/samba/smb.conf
echo "	directory mask			= 0755" >> /etc/samba/smb.conf
echo "	guest ok			= no" >> /etc/samba/smb.conf
echo "	profile acls			= yes" >> /etc/samba/smb.conf
echo "	csc policy			= disable" >> /etc/samba/smb.conf
echo "	force user 			= %U" >> /etc/samba/smb.conf
echo "	valid users			= %U %u @\"Domain Admins\" @\"Domain Users\"" >> /etc/samba/smb.conf
echo "	write list		        = %U %u" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf


if [ -f /etc/init.d/smbd ];then

   service samba restart

   else

   /etc/init.d/samba restart

fi


if [ "$REINSTALAR" = "S" ];then
	net setlocalsid $SID

   if [ -f /etc/init.d/smbd ];then 

      service samba restart

      else
   
      /etc/init.d/samba restart

   fi

fi

##########################################
#                                        #
#    Administrador LDAP para o Samba     #
#                                        #
##########################################

smbpasswd -w $PASSWORD

##########################################
#                                        #
#    etc/smbldap-tools/smbldap.conf      #
#             getlocalsid                # 
#                                        #
##########################################

if [ "$REINSTALAR" = "S" ];then

	echo "SID=$SID" > /etc/smbldap-tools/smbldap.conf
	else
	echo "SID=\"`net getlocalsid | cut -d" " -f6`\"" > /etc/smbldap-tools/smbldap.conf

fi

echo "slaveLDAP=\"127.0.0.1\"" >> /etc/smbldap-tools/smbldap.conf
echo "slavePort=\"389\"" >> /etc/smbldap-tools/smbldap.conf
echo "masterLDAP=\"127.0.0.1\"" >> /etc/smbldap-tools/smbldap.conf
echo "masterPort=\"389\"" >> /etc/smbldap-tools/smbldap.conf
echo "ldapTLS=\"0\"" >> /etc/smbldap-tools/smbldap.conf
echo "verify=\"require"\" >> /etc/smbldap-tools/smbldap.conf
echo "cafile=\"/etc/smbldap-tools/ca.pem\"" >> /etc/smbldap-tools/smbldap.conf
echo "clientcert=\"/etc/smbldap-tools/smbldap-tools.pem\"" >> /etc/smbldap-tools/smbldap.conf
echo "clientkey=\"/etc/smbldap-tools/smbldap-tools.key\"" >> /etc/smbldap-tools/smbldap.conf
echo "suffix=\"dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed "s/\./,dc=/g"`\"" >> /etc/smbldap-tools/smbldap.conf
echo "usersdn=\"ou=Users,\${suffix}\"" >> /etc/smbldap-tools/smbldap.conf
echo "computersdn=\"ou=Computers,\${suffix}\"" >> /etc/smbldap-tools/smbldap.conf
echo "groupsdn=\"ou=Groups,\${suffix}\"" >> /etc/smbldap-tools/smbldap.conf
echo "idmapdn=\"ou=Idmap,\${suffix}\"" >> /etc/smbldap-tools/smbldap.conf
echo "sambaUnixIdPooldn=\"sambaDomainName=`echo $DSAMBA | tr '[:lower:]' '[:upper:]'`,\${suffix}\"" >> /etc/smbldap-tools/smbldap.conf
echo "scope=\"sub\"" >> /etc/smbldap-tools/smbldap.conf
echo "hash_encrypt=\"`echo $CRIPTO | tr '[:lower:]' '[:upper:]'`\"" >> /etc/smbldap-tools/smbldap.conf
echo "crypt_salt_format=\"%s\"" >> /etc/smbldap-tools/smbldap.conf
echo "userLoginShell=\"/bin/bash\"" >> /etc/smbldap-tools/smbldap.conf
echo "userHome=\"$SMBUSR/%U\"" >> /etc/smbldap-tools/smbldap.conf
echo "userHomeDirectoryMode=\"755\"" >> /etc/smbldap-tools/smbldap.conf
echo "userGecos=\"Usuario do LDAP\"" >> /etc/smbldap-tools/smbldap.conf
echo "defaultUserGid=\"513\"" >> /etc/smbldap-tools/smbldap.conf
echo "defaultComputerGid=\"515\"" >> /etc/smbldap-tools/smbldap.conf
echo "skeletonDir=\"/etc/skel\"" >> /etc/smbldap-tools/smbldap.conf
echo "defaultMaxPasswordAge=\"-1\"" >> /etc/smbldap-tools/smbldap.conf

if [ "$REMOTO" != "N" ];then
	echo "userSmbHome=\"\\\\`echo $NTNAME | tr '[:lower:]' '[:upper:]'`\Profiles\%U\"" >> /etc/smbldap-tools/smbldap.conf
	echo "userProfile=\"\\\\`echo $NTNAME | tr '[:lower:]' '[:upper:]'`\Profiles\%U\"" >> /etc/smbldap-tools/smbldap.conf
	echo "userHomeDrive=\"$SMBMAP\"" >> /etc/smbldap-tools/smbldap.conf
else 
	echo "userSmbHome=\"\"" >> /etc/smbldap-tools/smbldap.conf
	echo "userProfile=\"\"" >> /etc/smbldap-tools/smbldap.conf
	echo "userHomeDrive=\"\"" >> /etc/smbldap-tools/smbldap.conf
fi

echo "mailDomain=\"`echo $DOMINIO | tr '[:upper:]' '[:lower:]'`\"" >> /etc/smbldap-tools/smbldap.conf
echo "with_smbpasswd=\"123456\"" >> /etc/smbldap-tools/smbldap.conf
echo "smbpasswd=\"/usr/bin/smbpasswd\"" >> /etc/smbldap-tools/smbldap.conf
echo "with_slappasswd=\"123456\"" >> /etc/smbldap-tools/smbldap.conf
echo "slappasswd=\"/usr/sbin/slappasswd\"" >> /etc/smbldap-tools/smbldap.conf

##########################################
#                                        #
#   Reiniciando os Serviços do LDAP      #
#               e SAMBA                  #
#                                        #
##########################################

if [ -f /etc/init.d/smbd ];then 
   
   service samba restart

   else
   
   /etc/init.d/samba restart

fi

/etc/init.d/slapd restart

##########################################
#                                        #
#        Populando a base do LDAP        #
#                                        #
##########################################

( echo $PASSWORD; echo $PASSWORD ) | smbldap-populate

##########################################
#                                        #
#       Setando permissao para           #
#         libnss-ldap.conf               #
#                                        #
##########################################

chmod 644 /etc/libnss-ldap.conf


##########################################
#                                        #
#          Instalando Pacotes            #
#         APACHE / PHPLDAPADMIN          #
#                                        #
##########################################

apt-get install -y --force-yes phpldapadmin apache2-suexec libapache2-mod-php5 php5 php5-cli php5-curl php5-gd php5-imap php5-ldap php5-mcrypt php5-mhash php5-sqlite php5-tidy php5-xmlrpc php-pear mcrypt apache2-doc;

a2enmod ssl
a2ensite default-ssl

/etc/init.d/apache2 restart

##########################################
#                                        #
#   Acertando Grupos na Inicializacao    #
#                                        #
##########################################

addgroup --system nvram
addgroup --system rdma
addgroup --system fuse
addgroup --system kvm
addgroup --system scanner
adduser --system --group --shell /usr/sbin/nologin --home /var/lib/tpm tss

##########################################
#                                        #
#    Servidor Home REMOTO para LINUX     #
#                                        #
##########################################

if [ "$REMOTO" != "N" ]; then

	if [ "`cat /etc/exports | grep ^$SMBUSR`" = "" ];then

		echo "" >> /etc/exports
		echo "	##############################################" >> /etc/exports
		echo "	##############################################" >> /etc/exports
		echo "	##############################################" >> /etc/exports
		echo "	##############################################" >> /etc/exports
		echo "	#                                            #" >> /etc/exports
		echo "	#             Perfil Ambulante               #" >> /etc/exports
		echo "	#                                            #" >> /etc/exports
		echo "	##############################################" >> /etc/exports
		echo "	##############################################" >> /etc/exports
		echo "	##############################################" >> /etc/exports
		echo "	##############################################" >> /etc/exports
		echo "" >> /etc/exports
		echo "`echo $SMBUSR`	`ifconfig | grep $IPADDRESS | cut -d\":\" -f2 | cut -d\" \" -f2 | cut -d\".\" -f1`.`ifconfig | grep $IPADDRESS | cut -d\":\" -f2 | cut -d\" \" -f2 | cut -d\".\" -f2`.`ifconfig | grep $IPADDRESS | cut -d\":\" -f2 | cut -d\" \" -f2 | cut -d\".\" -f3`.0/`ifconfig | grep $IPADDRESS | cut -d\":\" -f4`(rw,sync,no_subtree_check)" >> /etc/exports

		/etc/init.d/nfs-kernel-server restart

	else

		echo "Verifique o compartilhamento `echo $SMBUSR` existente no" >> ./info.ldap.txt
		echo "/etc/exports para ver se condiz com a configuracao!" >> ./info.ldap.txt
		echo "" >> ./info.ldap.txt

	fi
	
fi

##########################################
#                                        #
#       Setando permissao para           #
#         HOME REMOTO WINDOWS            #
#                                        #
##########################################

chown ."Domain Users" `echo $SMBPROFILES | tr '[:upper:]' '[:lower:]'`

##########################################
#                                        #
#      Criando SCRIPT para adicionar     #
#      clientes LINUX no LDAP            #
#                                        #
##########################################

echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "O Script para adicionar clientes Linux ao">> ./info.ldap.txt
echo "dominio será criado em /mnt/configurador/">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt

echo "#!/bin/bash" > /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "############################" >> /mnt/configurador/cliente_ldap.sh
echo "#                          #" >> /mnt/configurador/cliente_ldap.sh
echo "# Instalador do LDAP para  #" >> /mnt/configurador/cliente_ldap.sh
echo "#                          #" >> /mnt/configurador/cliente_ldap.sh
echo "#     clientes LINUX       #" >> /mnt/configurador/cliente_ldap.sh
echo "#                          #" >> /mnt/configurador/cliente_ldap.sh
echo "############################" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Acertando senha do root" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "clear" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "read -p \"Entre com a senha para o root LOCAL : \" PASSWORD" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "	echo \"\"" >> /mnt/configurador/cliente_ldap.sh
echo "	echo \" Atualizando a senha de root\"" >> /mnt/configurador/cliente_ldap.sh
echo "	echo \"\"" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "if [ \"\`cat /etc/nsswitch.conf | grep ldap\`\" = \"\" ];then" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "	( echo \$PASSWORD; echo \$PASSWORD ) | passwd root" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "	else" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "		echo \"account	required	pam_unix.so\" > /etc/pam.d/common-account" >> /mnt/configurador/cliente_ldap.sh
echo "		echo \"auth	required	pam_unix.so nullok_secure\" > /etc/pam.d/common-auth" >> /mnt/configurador/cliente_ldap.sh
echo "		echo \"password	required	pam_unix.so nullok obscure min=4 max=8 md5\" > /etc/pam.d/common-password" >> /mnt/configurador/cliente_ldap.sh
echo "		echo \"session	required	pam_unix.so\" > /etc/pam.d/common-session" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "		echo \"passwd:         compat\" > /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "		echo \"group:          compat\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "		echo \"shadow:         compat\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh
echo "		echo \"\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "		echo \"hosts:          files dns\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "		echo \"networks:       files\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh
echo "		echo \"\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh
echo "		echo \"protocols:      db files\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "		echo \"services:       db files\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "		echo \"ethers:         db files\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "		echo \"rpc:            db files\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh
echo "		echo \"\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh
echo "		echo \"netgroup:       nis\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "		( echo \$PASSWORD; echo \$PASSWORD ) | passwd root" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh		
echo "fi" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Configuracao do Resolvedor de nomes" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"search `echo $DOMINIO | tr '[:upper:]' '[:lower:]'` localdomain\" > /etc/resolv.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"nameserver $IPADDRESS\" >> /etc/resolv.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"nameserver 127.0.0.1\" >> /etc/resolv.conf" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Configuracao do LDAP" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "apt-get update" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "apt-get install -y --force-yes libpam-ldap libnss-ldap ldap-utils;" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Configurando arquivo COMMON-ACCOUNT" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"account	sufficient	pam_ldap.so\" > /etc/pam.d/common-account" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"account	required	pam_unix.so try_first_pass\" >> /etc/pam.d/common-account" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Configurando arquivo COMMON-AUTH" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"auth	sufficient	pam_ldap.so\" > /etc/pam.d/common-auth" >> /mnt/configurador/cliente_ldap.sh 
echo "echo \"auth	required	pam_unix.so nullok_secure try_first_pass shadow md5\" >> /etc/pam.d/common-auth" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Configurando arquivo COMMON-PASSWORD" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"password   sufficient pam_ldap.so\" > /etc/pam.d/common-password" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"password   required   pam_unix.so nullok obscure min=4 max=8 use_first_pass md5\" >> /etc/pam.d/common-password" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Configurando arquivo COMMON-SESSION" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"session	sufficient	pam_ldap.so\" > /etc/pam.d/common-session" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"session	required	pam_unix.so try_first_pass\" >> /etc/pam.d/common-session" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"session	optional	pam_mkhomedir.so skel=/etc/skel umask=077\" >> /etc/pam.d/common-session" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Configurando arquivo LIBNSS-LDAP.CONF" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"host `uname -n`\" > /etc/libnss-ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"base dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed \"s/\./,dc=/g\"`\" >> /etc/libnss-ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"ldap_version 3\" >> /etc/libnss-ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"\" >> /etc/libnss-ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"nss_base_passwd	ou=Users,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed \"s/\./,dc=/g\"`\" >> /etc/libnss-ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"nss_base_passwd	ou=Computers,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed \"s/\./,dc=/g\"`\" >> /etc/libnss-ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"nss_base_shadow	ou=Users,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed \"s/\./,dc=/g\"`\" >> /etc/libnss-ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"nss_base_group	ou=Groups,dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed \"s/\./,dc=/g\"`\" >> /etc/libnss-ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Configurando arquivo NSSWITCH.CONF" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"passwd:         compat ldap\" > /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "echo \"group:          compat ldap\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"shadow:         compat ldap\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "echo \"hosts:          files dns\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "echo \"networks:       files\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "echo \"protocols:      db files\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "echo \"services:       db files\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "echo \"ethers:         db files\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "echo \"rpc:            db files\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"netgroup:       nis\" >> /etc/nsswitch.conf" >> /mnt/configurador/cliente_ldap.sh 
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Configurando arquivo PAM_LDAP.CONF" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"host `uname -n`\" > /etc/pam_ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"base dc=`echo $DOMINIO | tr '[:upper:]' '[:lower:]' | sed \"s/\./,dc=/g\"`\" >> /etc/pam_ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"ldap_version 3\" >> /etc/pam_ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"\" >> /etc/pam_ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"nss_base_passwd	ou=Users,dc=`echo \$DOMINIO | tr '[:upper:]' '[:lower:]' | sed \"s/\./,dc=/g\"`?sub\" >> /etc/pam_ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"nss_base_passwd	ou=Computers,dc=`echo \$DOMINIO | tr '[:upper:]' '[:lower:]' | sed \"s/\./,dc=/g\"`?sub\" >> /etc/pam_ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"nss_base_shadow	ou=Users,dc=`echo \$DOMINIO | tr '[:upper:]' '[:lower:]' | sed \"s/\./,dc=/g\"`?sub\" >> /etc/pam_ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "echo \"nss_base_group 	ou=Groups,dc=`echo \$DOMINIO | tr '[:upper:]' '[:lower:]' | sed \"s/\./,dc=/g\"`?sub\" >> /etc/pam_ldap.conf" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "##########################################" >> /mnt/configurador/cliente_ldap.sh
echo "#                                        #" >> /mnt/configurador/cliente_ldap.sh
echo "#      Acertando Home para LINUX         #" >> /mnt/configurador/cliente_ldap.sh
echo "#                                        #" >> /mnt/configurador/cliente_ldap.sh
echo "##########################################" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh

if [ "$REMOTO" != "N" ]; then

	echo "" >> /mnt/configurador/cliente_ldap.sh
	echo "	if [ \"\`cat /etc/fstab | grep $SMBUSR\`\" = \"\" ];then" >> /mnt/configurador/cliente_ldap.sh
	echo "	" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	##############################################\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	##############################################\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	##############################################\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	##############################################\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	#                                            #\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	#             Perfil Ambulante               #\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	#                                            #\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	##############################################\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	##############################################\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	##############################################\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"	##############################################\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "		echo \"`uname -n`:`echo $SMBUSR`		`echo $SMBUSR`		nfs	rw,sync,users,auto	0	0\" >> /etc/fstab" >> /mnt/configurador/cliente_ldap.sh
	echo "" >> /mnt/configurador/cliente_ldap.sh
	echo "		mount -a" >> /mnt/configurador/cliente_ldap.sh
	echo "" >> /mnt/configurador/cliente_ldap.sh
	echo "	fi" >> /mnt/configurador/cliente_ldap.sh

fi

echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "# Configurar grupos do sistema" >> /mnt/configurador/cliente_ldap.sh
echo "#" >> /mnt/configurador/cliente_ldap.sh
echo "" >> /mnt/configurador/cliente_ldap.sh
echo "addgroup --system nvram" >> /mnt/configurador/cliente_ldap.sh
echo "addgroup --system rdma" >> /mnt/configurador/cliente_ldap.sh
echo "addgroup --system fuse" >> /mnt/configurador/cliente_ldap.sh
echo "addgroup --system kvm" >> /mnt/configurador/cliente_ldap.sh
echo "addgroup --system scanner" >> /mnt/configurador/cliente_ldap.sh
echo "adduser --system --group --shell /usr/sbin/nologin --home /var/lib/tpm tss" >> /mnt/configurador/cliente_ldap.sh

##########################################
#                                        #
#      Criando chave do Registro para    #
#           clientes Windows 7           #
#                                        #
##########################################

echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "A chave do Registro para adicionar clientes">> ./info.ldap.txt
echo "Windows7 ao dominio será criado em /mnt/configurador/">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "Windows Registry Editor Version 5.00" > /mnt/configurador/Registro_W7.reg 
echo "" >> /mnt/configurador/Registro_W7.reg
echo "[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters]" >> /mnt/configurador/Registro_W7.reg
echo "\"DomainCompatibilityMode\"=dword:00000001" >> /mnt/configurador/Registro_W7.reg
echo "\"DNSNameResolutionRequired\"=dword:00000000" >> /mnt/configurador/Registro_W7.reg

##########################################
#                                        #
#       Aviso para insercao no DNS       #
#                                        #
##########################################

echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "Se possuir servidor DNS insira a referencia">> ./info.ldap.txt
echo "nome:  `uname -n`  ao  IP: $IPADDRESS  para">> ./info.ldap.txt
echo "que os clientes linux possam achar o dominio">> ./info.ldap.txt
echo "atraves do nome.">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "Caso deseje, adicione nos clientes a referencia">> ./info.ldap.txt
echo "no arquivo /etc/hosts">> ./info.ldap.txt
echo "$IPADDRESS	`uname -n`.`echo $DOMINIO | tr '[:upper:]' '[:lower:]'`		`uname -n`">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "Insira no servidor DHCP a referencia para o">> ./info.ldap.txt
echo "servidor WINS ip: $IPADDRESS para que os clientes">> ./info.ldap.txt
echo "Windows possam ingressar ao dominio ou configure">> ./info.ldap.txt
echo "manualmente nas configurações TCP/IP da rede.">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt


##########################################
#                                        #
#        Testando o DOMINIO LDAP         #
#                                        #
##########################################

clear

echo "Exibindo IDs do Domínio">> ./info.ldap.txt
echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt

net getdomainsid>> ./info.ldap.txt

echo "">> ./info.ldap.txt
echo "">> ./info.ldap.txt

more ./info.ldap.txt

