#!/bin/zsh -f
# 
# Exemplo bem simples de uso do modulo 'curses' do zsh para "desenho
# de janelas" em interfaces CLI.
#
# Autor: Sandro Marcell
# Email: smarcell@myopera.com
# Blog: http://www.my.opera.com/smarcell/blog
#
# Uso: ./nome_script 'string'
#
# Mais detelhes:
# man zshmodules
# info zsh
#
zmodload zsh/curses

function mostraMensagem {          
	local string="$1"
	
	[ -z "$string" ] && string='Hello World! =)'
	      
	zcurses init
        zcurses addwin main $(($LINES - 19)) $(($COLUMNS - 2)) $(($LINES - 15)) 1 
        zcurses border main
        zcurses attr main red/black bold        
        zcurses move main 2 $((($COLUMNS - $#string - 2) / 2))
        zcurses string main "$string"        
        zcurses refresh main
	sleep 3	
	zcurses delwin main
	zcurses end

	return 0
}

mostraMensagem "$1" 
