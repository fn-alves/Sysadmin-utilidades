#---------------------------------------------------------------
#                     MONITOR DE RECURSOS
#---------------------------------------------------------------

cron="S"     # Se for utilizar a crontab mudar para "S" assim o script
             # será executado apenas uma vez e a crontab fará o novo
             # start, quando necessário.

delay="300"  # Se for deixar o script executando pelo loop interno
             # indicar aqui o número de segundos entre as verificações.
             # ex: "300" que correponde a 5 minutos.

ve_filesystem ()
{
df -h | grep -v ^Filesystem | while read line
do
percent=`echo $line | awk '{ print $5 }' | sed 's/%//g'`
if [ "$percent" -gt "70" ]; then 
echo "`date +"%Y-%m-%d %H:%M:%S"` - TIPO: FILESYSTEM - $percent % de Ulilizazao do Filesystem `echo $line | awk '{ print $1 }'`" >> centraldealertas.txt
fi
done
}

ve_memoria ()
{
percent=`free -m | awk '/^Mem/{ print $3,"*100","/",$2}' | sed 's/ //g' | bc`
if [ "$percent" -gt "70" ]; then 
echo "`date +"%Y-%m-%d %H:%M:%S"` - TIPO: MEMORIA    - $percent % da Memoria utilizada" >> centraldealertas.txt
fi
}

ve_cpu ()
{
percent=`vmstat 1 2 | sed 1,3d | awk '{ print $('$locale') }'`
if [ "$percent" -lt "30" ]; then 
echo "`date +"%Y-%m-%d %H:%M:%S"` - TIPO: CPU LOAD   - `expr 100 - $percent` % de CPU Utilizada" >>  centraldealertas.txt
fi
}


start ()
{
ve_filesystem
ve_memoria
ve_cpu
case "$cron" in
"N" | "n" ) 
sleep "$delay"
start
;;
esac
}

ve_vmstat ()
{
cvstat=`vmstat | sed -e 1,1d -e 3,3d | sed 's/id.*//g' | wc -w`
locale=`expr $cvstat + 1`
}

ve_vmstat
start 