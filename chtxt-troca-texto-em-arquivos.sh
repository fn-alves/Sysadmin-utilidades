#!/bin/bash
#chtxt
if [ -z $1 ]||[ -z $2 ];then
echo -e "\e[36;01m chtxt v0.0.1 by Anunakin\e[m"
echo "Uso: $ chtxt [expressao regular] [texto para substituir]"
exit
fi

SEARCH=$1
REPLACE=$2
FILES=`grep -Rc $SEARCH * | grep -v '0$' | cut -d ':' -f 1`

#FILES=$(ls -Rl|grep -v '^d')
for file in $FILES
do
echo -e "\e[32;01m * Processando arquivo $file ...\e[m"
sed -i -e "s/$SEARCH/$REPLACE/g" $file
done 
