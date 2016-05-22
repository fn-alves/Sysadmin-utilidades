#
# Funcao para validacao de ip's (IPv4)
#
# Sandro Marcell <sandro_marcell@yahoo.com.br>
# Boa Vista, Roraima - 24/10/2009
#
# Esta funcao toma como base a 'RFC 1918' que especifica quais as faixas de
# ip's devem ser usadas numa rede privada. Segundo ela as faixas disponiveis
# para esse fim sao:
# -> 10.0.0.0 - 10.255.255.255
# -> 172.16.0.0 - 172.31.255.255
# -> 192.168.0.0 - 192.168.255.255
# Portanto esta funcao so validara ip's que estejam numa das faixas acima.
#
# Para utiliza-la basta passar como argumento o ip a ser validado e posteriormente
# checar o codigo de retorno da funcao, em que:
# 0 = ip valido
# 1 = ip invalido
#
# Obs.:
# - Funcao criada sob o zsh 4.3.9
# - Mais detalhes: 'man zsh' e 'http://tools.ietf.org/html/rfc1918'
# - Funcao passivel de melhorias! ;)
#
function ValidaIP {
   # Suporte 'built-in' a ER's! Coisas do zsh =)
   [[ $@ =~ "^[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" ]] || return 1
   
   typeset -a numero_ip
   typeset primeiro_octeto segundo_octeto terceiro_octeto quarto_octeto

   numero_ip=(${(s:.:)@})
   primeiro_octeto=$numero_ip[1]
   segundo_octeto=$numero_ip[2]
   terceiro_octeto=$numero_ip[3]
   quarto_octeto=$numero_ip[4]

   # Checa o 2o octeto especifico de cada faixa
   case $primeiro_octeto {
      (10)  [[ $segundo_octeto =~ "^0[0-9][0-9]?" ]] && return 1 # Invalida tipos '0x' ou '0xx'
            (( segundo_octeto >= 0 && segundo_octeto <= 255 )) || return 1 ;;
      (172) (( segundo_octeto >= 16 && segundo_octeto <= 31 )) || return 1 ;;
      (192) (( segundo_octeto == 168 )) || return 1 ;;
      (*) return 1
   }
   
   # Ja que o 3o e 4o octetos sao comuns as tres faixas
   [[ $terceiro_octeto =~ "^0[0-9][0-9]?" ]] || [[ $quarto_octeto =~ "^0[0-9][0-9]?" ]] && return 1
   (( terceiro_octeto >= 0 && terceiro_octeto <= 255 )) || return 1
   (( quarto_octeto >= 0 && quarto_octeto <= 255 )) || return 1

}
