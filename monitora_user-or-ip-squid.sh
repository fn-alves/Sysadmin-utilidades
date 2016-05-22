#!/usr/bin/perl

#=========================================================================================
# Script para monitoramento de sistemas
# Desenvolvido por Alexandre Pedroso
# http://www.aplinux.com.br - aplinux@ig.com.br
#=========================================================================================

system("rm -rf /root/monitor.txt");
system("echo '============================================================' > /root/monitor.txt");
system("echo 'VERIFICAÇO DOS SISTEMAS DA EMPRESA' >> /root/monitor.txt");
system("echo '============================================================' >> /root/monitor.txt");
system("echo -n 'SERVIDOR LINUX xxx.xxx.xxx.x - ' >> /root/monitor.txt ; date >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo 'SERVIÇS ATIVOS:' >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo -n '1) ' >> /root/monitor.txt ; /etc/init.d/sendmail status >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo -n '2) ' >> /root/monitor.txt ; /etc/init.d/named status >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo -n '3) ' >> /root/monitor.txt ; /etc/init.d/radiusd status >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo -n '4) ' >> /root/monitor.txt ; /etc/init.d/httpd status >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo 'FILA DE E-MAIL:' >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo -n 'Mensagens na fila: ' >> /root/monitor.txt ; mailq | wc -l >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo 'TESTE DE PING: ' >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo '1) Roteador Link - xxx.xxx.xxx.x' >> /root/monitor.txt");
system("ping -c 5 xxx.xxx.xxx.x >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo '2) Roteador Cisco - xxx.xxx.xxx.x' >> /root/monitor.txt");
system("ping -c 5 xxx.xxx.xxx.x >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo '3) Servidor Windows 2000 - xxx.xxx.xxx.x' >> /root/monitor.txt");
system("ping -c 5 xxx.xxx.xxx.x >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo '4) Servidor Linux - xxx.xxx.xxx.x' >> /root/monitor.txt");
system("ping -c 5 xxx.xxx.xxx.x >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo '5) Servidor Externo - xxx.xxx.xxx.x' >> /root/monitor.txt");
system("ping -c 5 xxx.xxx.xxx.x >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo '6) UOL - HOST REMOTO' >> /root/monitor.txt");
system("ping -c 5 www.uol.com.br >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo 'USUÁIOS CONECTADOS:' >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo -n 'Total de usuáos conectados: ' >> /root/monitor.txt ; radwho | wc -l >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("radwho >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo 'INFORMAÇES DO HD:' >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("df -h >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo 'INFORMAÇES DE MEMÓIA:' >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("free >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo '20 ÚTIMAS LINHAS DO LOG DO MAIL SERVER:' >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
il -20 /var/log/maillog >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo '20 ÚTIMAS LINHAS DO LOG DO RADIUS SERVER:' >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
il -20 /var/log/radius.log >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo '20 ÚTIMAS LINHAS DO LOG DO SISTEMA:' >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
il -20 /var/log/messages >> /root/monitor.txt");
system("echo >> /root/monitor.txt");
system("echo '============================================================' >> /root/monitor.txt");
system("echo 'TESTES REALIZADOS COM SUCESSO....' >> /root/monitor.txt");
system("echo '============================================================' >> /root/monitor.txt");
$ncon==0;
open (arq, "/root/monitor.txt");
@body= < arq >;
close (arq);
foreach $item (@body) {
$ncon=$ncon+1;
}
$ncon=$ncon-1;
if ($ncon > 5) {
open(MAIL,"|/usr/sbin/sendmail -t");
print MAIL "To: seuemail\@seudominio.com.br\n";
print MAIL "cc: seuemail\@seudominio.com.br\n";
print MAIL "From: root\@seudominio.com.br\n";
print MAIL "Subject: Monitoramento dos Sistemas\n\n";
print MAIL "-" x 75 . "\n\n";
foreach $item (@body) {
print MAIL $item;
}
print MAIL "-" x 75 . "\n\n";
close(MAIL);
}

