#!/bin/bash

RED='\e[1m\e[31m'
BLACK='\e[0m'
GREEN='\e[1m\e[32m'
BLUE='\e[1m\e[34m'

#clear

#Ayuda
if [ $1 = "-h" ] || [ $# -ne 2 ] || [ ! -d $1 ] || [ ! -d $2 ]; then
  echo -e "${RED}Uso:${BLACK}"
  echo -e "${RED}$0 'Ruta_ficheros_fuente_originales_Mytar' 'Ruta_mi_solucion_Mytar'${BLACK}"
  exit 0
fi 

#Directorio temporal de test
tmpdir=$( mktemp -d -p ./ check_XXX)
echo -e "${BLUE}Creando directorio temporal: $tmpdir${BLACK}"

echo -e "${BLUE}Copiamos ficheros fuente originales (mytar.c/h y Makefile)...${BLACK}"
if ! cp $1/mytar.? $1/Makefile $tmpdir; then
  echo -e "${RED}Error al copiar los ficheros fuente originales${BLACK}"
  exit -1
fi 


echo -e "${BLUE}Copiamos ficheros fuente de la solución (mytar_routines.c, Leeme.txt y script.sh) ...${BLACK}"

if ! cp $2/mytar_routines.c $2/Leeme.txt $2/script.sh $tmpdir; then
  echo -e "${RED}Error al copiar los ficheros fuente de la solución${BLACK}"
  exit -1
fi 

cd $tmpdir

echo -e "${BLUE}Comprobando formato...${BLACK}"
unsigned=$( grep unsigned mytar_routines.c  | wc -l )
static=$( grep static mytar_routines.c  | wc -l )

if [ $unsigned -lt 2 ] || [ $static -lt 3 ]; then
  echo -e "${RED}Error en el formato de los ficheros fuentes, deben de respetar los prototipos originales${BLACK}"
  exit -1
else
  echo -e "${GREEN}Formato Ok!${BLACK}"
fi 



echo -e "${BLUE}Leeme.txt:${BLACK}"
echo -e "${BLUE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${BLACK}"
cat Leeme.txt
echo -e "${BLUE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${BLACK}"

make clean > /dev/null 2>&1

if ! make > /dev/null 2>&1; then
  echo -e "${RED}El proyecto no compila${BLACK}"
  exit 1
fi

echo -e "${BLUE}Test de uso${BLACK}"

echo "./mytar -cf Leeme.mtar Leeme.txt"
if ! ./mytar -cf Leeme.mtar Leeme.txt; then
  echo -e "${RED}Error ejecutando mytar ${BLACK}"
  cd ..
  exit 1
fi

cd ..

echo -e "${GREEN}Test mínimo Ok, la prácita puede ser presentada, puede borrar el directorio temporal con${BLACK}"
echo "rm -r $tmpdir"

exit 0
