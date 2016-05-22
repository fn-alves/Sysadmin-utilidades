#!/bin/bash
# Criado em: Dom 31/Jan/2010 - 02:47hs
# Autor: Alessandro Reis - aletkdnit@yahoo.com.br
# Backup interativo com zenity
#Faz o backup de suas pastas de maneira fácil,colocando data zipando e empacotando.

#Janela de seleção do diretório que vai ser feito backup
 pasta=`zenity --file-selection --directory --title "Selecione o diretório para backup"`
  case $? in
     0) source $pasta;;
     1) zenity --warning --text "Nenhum diretório foi selecionado";;
    -1) zenity --warning --text "Nenhum diretório foi selecionado";;
  esac
 
#Janela de seleção do diretório que vai ser feito backup
 destino=`zenity --file-selection --directory --title "Selecione o destino do backup"`
   case $? in
      0) source $destino;;
      1) zenity --warning --text "Nenhum destino foi selecionado";;
     -1) zenity --warning --text "Nenhum destino foi selecionado";;
   esac



#Progresso da compactação
tar cvzf $destino/backup-`date +%Y%m%d`.tar.gz $pasta/* | zenity --progress --auto-close  --text "Fazendo Backup, aguarde..." --pulsate

#Janela de confirmação
zenity --title="Status" --info --text="Backup Terminado."
