#! /bin/bash
#==========================================================
if [ "$1" = "lib" ]; then
VAR1=`cat /etc/squid/listas/block_unblock_lab.txt | grep "$2" | wc -m`
if [ "$VAR1" = 14 ]; then
sed -s "s|#192\.168\.1\.$2|192\.168\.1\.$2|g" /etc/squid/listas/block_unblock_lab.txt > /etc/squid/listas/block_transicao.txt
cp -p /etc/squid/listas/block_transicao.txt /etc/squid/listas/block_unblock_lab.txt
echo ""
echo "###############################"
echo "### Máquina $2 LIBERADA ###"
echo "###############################"
echo ""
sh /etc/init.d/squid reload > /dev/null
echo "###############################"
echo "### Atualizando squid ###"
echo "###############################"
echo ""
else
echo "Máquina já liberada"
fi
else
if [ "$1" = "bloq" ]; then
VAR1=`cat /etc/squid/listas/block_unblock_lab.txt | grep "$2" | wc -m`
if [ "$VAR1" = 13 ]; then
sed -s "s|192\.168\.1\.$2|#192\.168\.1\.$2|g" /etc/squid/listas/block_unblock_lab.txt > /etc/squid/listas/block_transicao.txt
cp -p /etc/squid/listas/block_transicao.txt /etc/squid/listas/block_unblock_lab.txt
echo ""
echo "###############################"
echo "### Máquina $2 BLOQUEADA ###"
echo "###############################"
echo ""
sh /etc/init.d/squid reload > /dev/null
echo "###############################"
echo "### Atualizando squid ###"
echo "###############################"
echo ""
else
echo "Máquina já bloqueada"
fi
else
echo "Parâmetro inválido, utilize liberar ou bloquear"
fi
fi
#==========================================================