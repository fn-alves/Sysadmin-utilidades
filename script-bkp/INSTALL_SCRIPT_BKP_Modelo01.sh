#!/bin/bash
# Autor Maicon Souza 
# 24-09-2012
# e-mail: maicon@itsouza.com


 # criar raiz e sub-diretorios

   raiz=MEU_BKP

   mkdir ./$raiz
   mkdir ./$raiz/config
   mkdir ./$raiz/log
   mkdir ./$raiz/tmp

 # criar os txt de configuracoes

   echo "BKP_SERVER_WEB" > ./$raiz/config/id_backup.txt
   echo "//192.168.1.130/d$/MEUS_BKPs" > ./$raiz/config/destino_bkp.txt
   echo "//192.168.1.109/c$/MSsql" > ./$raiz/config/origem_arquivos.txt

 # criar os scripts 

 # BKP FULL

echo '#!/bin/bash
# Autor Maicon Souza 
# script de backup
# data: 22-09-11

IFS=: # separadores

lendo_id_bkp(){
  while read linha; do
   id_bkp=$linha
  done < ./config/id_backup.txt
}

montar_unid(){
 chmod +x ./montar_unidades.sh
 ./montar_unidades.sh
}

desmontar_unid(){
 chmod +x ./desmontar_unidades.sh
 ./desmontar_unidades.sh
}

var_data_time(){

# data / hora
 DATA=`date +%x-%k%M%S`
# data / ano - criar diretorio
 DATADIR=`date +%x_%y`
# tempo de vida dos arquivos de bkp (em dias)
 TIME_BKCP=+15
# logs
 DATAIN=`date +%c`
 DATAFIN=`date +%c`
# diretorio de destino
 DSTDIR=/media/bkpDEST-$id_bkp/$id_bkp

}

selecao_dados() {

    var_data_time
#
    ls $DSTDIR > ./tmp/lista_dir_por_data.log

# criar o arquivo "full-data.tar" no destino
    criar_tar=(" ")
    cont01=0
  while read linha; do
     mkdir $DSTDIR/$DATADIR
     criar_tar[$cont01]=$DSTDIR/$DATADIR/full-$cont01-$DATA.tar.gz      
     let cont01++ 
  done < ./tmp/lista_dir_orig.log
}

bkp_full(){

   var_data_time

# compressao dos arquivos
   cont01=0
   while read linha; do
      sync
      local_orig=/media/bkpORIG-$id_bkp-$cont01
      tar -czvf ${criar_tar[$cont01]} $local_orig
      let cont01++
   done < ./tmp/lista_dir_orig.log

# logs
if [ $? -eq 0 ] ; then
   echo "Backup realizado com sucesso" >> ./log/backup_full.log
   echo "Criado pelo usuario: $USER" >> ./log/backup_full.log
   echo "INICIO: $DATAIN" >> ./log/backup_full.log
   echo "FIM: $DATAFIN" >> ./log/backup_full.log
   echo "-----------------------------------------" >> ./log/backup_full.log
else
   echo "ERRO! Backup Do Dia $DATAIN" >> ./log/backup_full.log
fi  
}

deletar_full(){
  
   var_data_time

# apagar arquivos antigos (com mais de 15 dias)
   while read linha; do 
      find $DSTDIR/$linha -name "f*" -ctime $TIME_BKCP -exec rm -f {} ";"
   done < ./tmp/lista_dir_por_data.log 

   if [ $? -eq 0 ] ; then
     echo "Arquivo de backup mais antigo eliminado com sucesso!"
   else
     echo "Erro durante a busca e destruição do backup antigo!"
   fi
}

    lendo_id_bkp
    montar_unid
    selecao_dados
    deletar_full
    bkp_full
    desmontar_unid            
 
exit 0' > ./$raiz/full_backup.sh 

 # BKP DIF

echo '#!/bin/bash
# Autor Maicon Souza 
# data: 22-09-11

IFS=: # separadores

lendo_id_bkp(){
  while read linha; do
   id_bkp=$linha
  done < ./config/id_backup.txt
}

compactar_bkp(){
# chama e roda o script de compactacao de backup
chmod +x ./compactar_backup.sh
./compactar_backup.sh
}

remove_arqs_tmp(){
rm -f ./tmp/compacta_bkp_dif.log
}

montar_unid(){
 chmod +x ./montar_unidades.sh
 ./montar_unidades.sh
}

var_data_time(){

# data / hora
 DATA=`date +%x-%k%M%S`
# data / ano - criar diretorio
 DATADIR=`date +%x_%y`
# -xx arquivos que tenham sido criados nos ultimos xx minutos (horas = 660 minutos)
 TIME_FIND=-660  
# log
 DATAIN=`date +%c`
# 
 DATAFIN=`date +%c`
# diretorio de destino do backup
 DSTDIR=/media/bkpDEST-$id_bkp/$id_bkp
}

selecao_dados() {

 var_data_time

# criar o arquivo "dif-data.tar" no diretorio de destino
    criar_tar=(" ")
    cont01=0
  while read linha; do
    mkdir $DSTDIR/$DATADIR
    echo "$DSTDIR/$DATADIR" >> ./tmp/compacta_bkp_dif.log
    criar_tar[$cont01]=$DSTDIR/$DATADIR/dif-$cont01-$DATA.tar
    let cont01++  
  done < ./tmp/lista_dir_orig.log
}

bkp_dif(){

  var_data_time

    cont01=0
  while read linha; do
    sync
    local_orig=/media/bkpORIG-$id_bkp-$cont01   
    find $local_orig -type f -cmin $TIME_FIND -exec tar -rvf ${criar_tar[$cont01]}  {} ";"
    let cont01++
  done < ./tmp/lista_dir_orig.log

if [ $? -eq 0 ] ; then
    echo "Backup realizado com sucesso" >> ./log/backup_diferencial.log
    echo "Criado pelo usuario: $USER" >> ./log/backup_diferencial.log
    echo "INICIO: $DATAIN" >> ./log/backup_diferencial.log
    echo "FIM: $DATAFIN" >> ./log/backup_diferencial.log
    echo "------------------------------------------------" >> ./log/backup_diferencial.log
    echo " "
else
   echo "ERRO! Backup Diferencial $DATAIN" >> ./log/backup_diferencial.log
fi  
}

  remove_arqs_tmp
  lendo_id_bkp
  montar_unid  
  receb_origem
  selecao_dados
  bkp_dif
  compactar_bkp
 
exit 0' > ./$raiz/backup_diferencial.sh

 # COMPACTADOR

echo '#!/bin/bash
# Autor Maicon Souza 
# data: 22-09-11

lendo_id_bkp(){
  while read linha; do
   id_bkp=$linha
  done < ./config/id_backup.txt
}

desmontar_unid(){
 chmod +x ./desmontar_unidades.sh
 ./desmontar_unidades.sh
}

var_data_time(){

# dias em que permanecera o backup diferencial armazenado
 TIME_DEL=+30
# 
 DATAIN=`date +%c`
#
 DATAFIN=`date +%c`
# diretorio de destino
 DSTDIR=/media/bkpDEST-$id_bkp/$id_bkp

}

compactar(){

  var_data_time

  while read linha; do
    gzip -9 $linha/*.tar
  done < ./tmp/compacta_bkp_dif.log 

  echo "INICIO: $DATAIN" >> ./log/backup_compactacao.log
  echo "FIM: $DATAFIN" >> ./log/backup_compactacao.log
  echo "Realizado pelo usuario: $USER" >> ./log/backup_compactacao.log
  echo "-----------------------------------" >> ./log/backup_compactacao.log
}

deletar_dif(){
 var_data_time

# lista diretorios do destino
  ls $DSTDIR > ./tmp/lista_dir_por_data.log

# apagando arquivos mais antigos (com mais de 30 dias)
 
  while read linha; do
     find $DSTDIR/$linha -name "dif*" -ctime $TIME_DEL -exec rm -f {} ";"
  done < ./tmp/lista_dir_por_data.log 

  if [ $? -eq 0 ] ; then
     echo "Arquivo de backup mais antigo eliminado com sucesso!"
  else
      echo "Erro durante a busca e destruicao do backup antigo!"
  fi
}


 lendo_id_bkp
 compactar
 deletar_dif
 desmontar_unid

exit 0' > ./$raiz/compactar_backup.sh

 # MONTAR UNID

echo '#!/bin/bash
# Autor Maicon Souza 
# script de backup
# data: 22-09-11

IFS=: # separadores

user_senha(){

 # user do dominio com permissoes de administracao

 user_domin=XXX@meudominio.local
 senha_domin=XXX

}

lendo_id_bkp(){
  while read linha; do
    id_bkp=$linha
  done < ./config/id_backup.txt
}

montar_origem_lista(){

# montar origem dos arquivos, para a listagem  

   cont01=0
  while read linha; do
    local_origem=$linha
    mkdir /media/lista-ORIG-$id_bkp
    smbmount $local_origem /media/lista-ORIG-$id_bkp -o username=$user_domin,password=$senha_domin,iocharset=iso8859-1,iocharset=utf8 0 0
    let cont01++ 
  done < ./config/origem_arquivos.txt
    
 # lista os diretorios
    ls /media/lista-ORIG-$id_bkp > ./tmp/lista_dir_orig.log
    umount /media/lista-ORIG-$id_bkp # desmonta apos a listagem
}

montar_origem(){

 montar_origem_lista
 
# montar origem dos arquivos  
  cont01=0

  while read linha; do
   mkdir /media/bkpORIG-$id_bkp-$cont01
   local=$local_origem # essa var devera ter apenas um endereco 
   dir=$linha
   smbmount $local/$dir /media/bkpORIG-$id_bkp-$cont01 -o username=$user_domin,password=$senha_domin,iocharset=iso8859-1,iocharset=utf8 0 0
   let cont01++
  done < ./tmp/lista_dir_orig.log
}

montar_destino(){

 # montar destino dos arquivos  
   cont01=0
  while read linha; do
   local=$linha
   mkdir /media/bkpDEST-$id_bkp
   smbmount $local /media/bkpDEST-$id_bkp -o username=$user_domin,password=$senha_domin,iocharset=iso8859-1,iocharset=utf8 0 0
   mkdir /media/bkpDEST-$id_bkp/$id_bkp
   let cont01++ 
  done < ./config/destino_bkp.txt
}

  user_senha
  lendo_id_bkp
  montar_origem
  montar_destino

exit 0' > ./$raiz/montar_unidades.sh

 # DESMONTAR UNID

echo '#!/bin/bash
# Autor Maicon Souza 
# data: 22-09-11

lendo_id_bkp(){
  while read linha; do
    id_bkp=$linha
  done < ./config/id_backup.txt
}

desmontar(){
 
  cont01=0

 while [ $cont01 -ne 150 ] ; do  

###
    umount /media/bkpDEST-$id_bkp
###
    umount /media/bkpORIG-$id_bkp-$cont01
###
    umount /media/lista-ORIG-$id_bkp
###
    echo "<--------------------------------------->"

###
    umount /media/bkpDEST-$id_bkp
###
    umount /media/bkpORIG-$id_bkp-$cont01
###
    umount /media/lista-ORIG-$id_bkp
###
    echo "<--------------------------------------->"

    let cont01++
 done
}

lendo_id_bkp
desmontar

exit 0' > ./$raiz/desmontar_unidades.sh

# Criar READ TXT

echo ">>> CONFIGURAÇÕES DO SCRIPT <<<

*** Configure os seguintes arquivos:

- Informe a origem dos arquivos, apenas um diretório : //192.168.8.100/d$/Meus Docs.
./$raiz/config/origem_arquivos.txt

- Informe um diretório de destino, para os bkps, apenas um diretório : //192.168.8.90/e$/Meus_BKPs.
./$raiz/config/destino_bkp.txt

- Informe uma ID para o bkp, para diferenciar dos demais.
./$raiz/config/id_backup.txt

- Informe um 'user' e 'senha', com permissão de administração no dominio.
./$raiz/montar_unidades.sh

>>> IMPORTANTE <<<

*** Esse script é destinado para unidades grandes, pois o mesmo listará todos os sub-diretórios e criará um '.tar' para cada sub-diretório.



Maicon Souza
24-09-12
maicon@itsouza.com" > ./$raiz/READ.txt

gedit ./$raiz/READ.txt

exit 0
