#!/bin/bash
############################################################################
#    Fernax - Biblioteca de funcoes de apoio a shell script                #
#    libcsv 0.1 - Funcoes de manipulacao de arquivos CSV                   #
#    Copyright (C) 2010 Gabriel Fernandes                                  #
#    Autor: Gabriel Fernandes <gabriel@duel.com.br>                        #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################

csv_openfile () 
{
  CSV_FILENAME=$1
  CSV_TITLE=$2
  CSV_IFS=$3
  
  [ -z "$1" ] && exit 1
  [ -z "$2" ] && TITLE="FALSE"
  [ -z "$3" ] && CSV_IFS=";"
  
  if [ -e ${CSV_FILENAME} ] ; then
    export CSV_FILENAME=${CSV_FILENAME}
    export CSV_TITLE=${CSV_TITLE}
    export CSV_IFS=${CSV_IFS}
    echo ${CSV_FILENAME}
    return 0
  else 
    return 1
  fi
}

csv_createfile ()
{
  CSV_FILENAME=$1
  CSV_TITLE=$2
  CSV_IFS=$3
  
  [ -z "$1" ] && exit 1
  [ -z "$2" ] && TITLE="FALSE"
  [ -z "$3" ] && CSV_IFS=";"
  
  touch ${CSV_FILENAME}
  
  if [ -e ${CSV_FILENAME} ] ; then
    export CSV_FILENAME=${CSV_FILENAME}
    export CSV_TITLE=${CSV_TITLE}
    export CSV_IFS=${CSV_IFS}
    echo ${CSV_FILENAME}
    return 0
  else 
    return 1
  fi
}

csv_getnumrows () 
{
  CSV_NUM_ROWS=$(cat ${CSV_FILENAME} |  wc -l)
  if [ "${CSV_TITLE}" = "TRUE" ] ; then
    CSV_NUM_ROWS=$(let CSV_NUM_ROWS-=1)
  fi

  if [ "$?" = "0" ] ; then
    export CSV_NUM_ROWS=${CSV_NUM_ROWS}
    echo ${CSV_NUM_ROWS};
    return 0
  else
    return 1
  fi
}

csv_getnumfields () 
{

  [ -z "$CSV_FILENAME" ] && exit 1
  [ -z "$CSV_TITLE" ] && TITLE="FALSE"
  [ -z "$CSV_IFS" ] && CSV_IFS=";"

  CSV_FIRST_LINE=$(head -n1 ${CSV_FILENAME})
  echo ${CSV_FIRST_LINE} > /tmp/character_count.$$

  LENGHT=$(echo $CSV_FIRST_LINE | wc -c)
  let LENGHT-=1
 
  COUNTER=1
  CSV_NUM_FIELDS=0
  while [ ${COUNTER} -le ${LENGHT} ] ; do
    CSV_FIRST_LINE=$(cut -c${COUNTER} /tmp/character_count.$$)
    if [ "${CSV_FIRST_LINE}" == "${CSV_IFS}" ] ; then
      let CSV_NUM_FIELDS+=1
    fi
    let COUNTER+=1
  done

  if [ "$?" = "0" ] ; then
    export CSV_NUM_FIELDS=${CSV_NUM_FIELDS}
    echo ${CSV_NUM_FIELDS};
    return 0
  else
    return 1
  fi

}

csv_getfieldtitle () 
{
  CSV_FIELD=$1

  [ -z "$CSV_FILENAME" ] && exit 1
  [ -z "$CSV_TITLE" ] && TITLE="FALSE"
  [ -z "$CSV_IFS" ] && CSV_IFS=";"

  if [ "${CSV_TITLE}" = "TRUE" ] ; then
    
    CSV_FIRST_LINE=$(head -n1 ${CSV_FILENAME})
    NUM_FIELDS=$(csv_getnumfields)
    FIELDS=""
    if [ -z "$CSV_FIELD" ] ; then
      for COUNTER in $(seq ${NUM_FIELDS}); do 
        if [ "${FIELDS}" = "" ] ; then
          FIELDS=${COUNTER}
        else
          FIELDS="${FIELDS},${COUNTER}"
        fi
      done

    else
      FIELDS="${CSV_FIELD}"
      
    fi
      
    CSV_TITLE=$(echo ${CSV_FIRST_LINE} | cut -d "${CSV_IFS}" -f${FIELDS})

    if [ "$?" = "0" ] ; then
      export CSV_TITLE=${CSV_TITLE}
      echo ${CSV_TITLE}
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
  



}

csv_addfield ()
{
  NUM_FIELD=$1
  [ -z "$1" ] && NUM_FIELD=$(csv_getnumfields) 
}

#csv_delfield ()
#{

#}

csv_addrow () 
{
  [ -z "$1" ] && exit 1
  [ -z "$CSV_FILENAME" ] && exit 1
  [ -z "$CSV_TITLE" ] && TITLE="FALSE"
  [ -z "$CSV_IFS" ] && CSV_IFS=";"

  CSV_ROW=""
  
  while [ "$1" != "" ]; do
    if [ ${CSV_ROW} = "" ] ; then
      CSV_ROW="${1}${CSV_IFS}"
    else
      CSV_ROW="${CSV_ROW}${1}${CSV_IFS}"
    fi
    shift
  done
  
  echo "${CSV_ROW}" >> "${CSV_FILENAME}"
  
  return $?

}

csv_delrow () 
{

  # params: chave1 chave2
  # problema: chaves sempre em primeiro no arquivo

  [ -z "$1" ] && exit 1
  [ -z "$CSV_FILENAME" ] && exit 1
  [ -z "$CSV_TITLE" ] && TITLE="FALSE"
  [ -z "$CSV_IFS" ] && CSV_IFS=";"

  CSV_ROW_KEYS=""
  
  while [ "$1" != "" ]; do
    if [ ${CSV_ROW_KEYS} = "" ] ; then
      CSV_ROW_KEYS="${1}${CSV_IFS}"
    else
      CSV_ROW_KEYS="${CSV_ROW_KEYS}${1}${CSV_IFS}"
    fi
    shift
  done
  
  CSV_ID_ROW_DELETE=$(grep -n "^${CSV_ROW_KEYS}" "${CSV_FILENAME}" | cut -d : -f 1)

  sed -i~ ${CSV_ID_ROW_DELETE}d "${CSV_FILENAME}"

  return $?

}

csv_updaterow () 
{
  # params: chave1 chave2 ... SET 5 novoValor
  # problema: chaves sempre em primeiro no arquivo

  [ -z "$1" ] && exit 1
  [ -z "$CSV_FILENAME" ] && exit 1
  [ -z "$CSV_TITLE" ] && TITLE="FALSE"
  [ -z "$CSV_IFS" ] && CSV_IFS=";"

  CSV_ROW_KEYS=""
  
  while [ "$1" != "SET" ]; do
    if [ "${CSV_ROW_KEYS}" = "" ] ; then
      CSV_ROW_KEYS="${1}${CSV_IFS}"
    else
      CSV_ROW_KEYS="${CSV_ROW_KEYS}${1}${CSV_IFS}"
    fi
    shift
  done

  CSV_ID_FIELD_UPDATE="$2"
  CSV_VAL_FIELD_UPDATE="$3"

  CSV_ID_ROW_FOR_UPDATE=$(grep -n "^${CSV_ROW_KEYS}" "${CSV_FILENAME}" | cut -d : -f 1)
  CSV_ROW_FOR_UPDATE=$(grep "^${CSV_ROW_KEYS}" "${CSV_FILENAME}")

  CSV_NUM_FIELDS=$(csv_getnumfields)
  
  CSV_ROW_UPDATED=""

  for ((I=1;I<=${CSV_NUM_FIELDS};I++)) ; do
    if [ "${CSV_ID_FIELD_UPDATE}" != "${I}" ] ; then
      CSV_ROW_FIELD_TEMP=$(echo "${CSV_ROW_FOR_UPDATE}" | cut -d "${CSV_IFS}" -f ${I})
      
      if [ "${CSV_ROW_UPDATED}" = "" ] ; then
        CSV_ROW_UPDATED="${CSV_ROW_FIELD_TEMP}${CSV_IFS}"
      else
        CSV_ROW_UPDATED="${CSV_ROW_UPDATED}${CSV_ROW_FIELD_TEMP}${CSV_IFS}"
      fi
      
    else  
      CSV_ROW_UPDATED="${CSV_ROW_UPDATED}${CSV_VAL_FIELD_UPDATE}${CSV_IFS}"
    fi
  done; 

  sed -i ${CSV_ID_ROW_FOR_UPDATE}d "${CSV_FILENAME}"

  echo "${CSV_ROW_UPDATED}" >> "${CSV_FILENAME}"

  return $?

}

#csv_sortby () 
#{
#}

#csv_locate () 
#{
#}


