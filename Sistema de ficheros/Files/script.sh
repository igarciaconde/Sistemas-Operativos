#!/bin/bash

MPOINT="./mount-point"
VIRTUALDISK="./virtual-disk"
TEMPD="./temp"
COPIA_FICHERO="./mount-point/fuseLib.c"
COPIA_FICHERO2="./mount-point/myFS.h"
COPIA_FICHERO3="./mount-point/nuevoFichero.txt"
FICHERO_ORIGINAL1="./src/fuseLib.c"
FICHERO_ORIGINAL2="./src/myFS.h"
FICHERO="nuevoFich.txt"
BLOCK_SIZE=4096
ESTADO="./my-fsck"


#Apartado a)
rm -R -f temp
mkdir temp

echo "Copiando los archivos en nuestro SF y en /temp"
cp $FICHERO_ORIGINAL1 $MPOINT/
cp $FICHERO_ORIGINAL1 $TEMPD/
cp $FICHERO_ORIGINAL2 $MPOINT/
cp $FICHERO_ORIGINAL2 $TEMPD/

read -p "Pulsa enter para seguir. Apartado b)"

#Apartado b)
echo "Mostrando disco virtual"
$ESTADO $VIRTUALDISK
DIFF1=$(diff $FICHERO_ORIGINAL1 $COPIA_FICHERO)

if [ DIFF1 = "" ]; then
	echo "$FICHERO_ORIGINAL1 y $COPIA_FICHERO son iguales" 
else
	echo "$FICHERO_ORIGINAL1 y $COPIA_FICHERO son distintos" 
fi;

DIFF2=$(diff $FICHERO_ORIGINAL2 $COPIA_FICHERO2)
if [ DIFF2 = "" ]; then
	echo "$FICHERO_ORIGINAL2 y $COPIA_FICHERO2 son iguales" 
else
	echo "$FICHERO_ORIGINAL2 y $COPIA_FICHERO2 son distintos" 
fi;

#CON esto averiguamos el tamaño de bloque del archivo
SIZE_FICHERO_ORIGINAL1=$(stat -c%s "$FICHERO_ORIGINAL1")

NEW_SIZE1=`expr $SIZE_FICHERO_ORIGINAL1 - $BLOCK_SIZE`

echo "Nuevo tamaño: $NEW_SIZE1"

echo "Truncando el primer fichero en el archivo temporal"
truncate --size=$NEW_SIZE1 ./temp/fuseLib.c

echo "Truncando el primer fichero en nuestro archivo SF"
truncate --size=$NEW_SIZE1 $COPIA_FICHERO

read -p "Pulsa enter para seguir. Apartado c)"

#Apartado c)
echo "Mostrando disco virtual"
$ESTADO $VIRTUALDISK

DIFF1=$(diff "$FICHERO_ORIGINAL1" "$COPIA_FICHERO")
if [ DIFF1 = "" ]; 
then
	echo "$FICHERO_ORIGINAL1 y $COPIA_FICHERO son iguales despues de truncarlos" 
else
	echo "$FICHERO_ORIGINAL1 y $COPIA_FICHERO son distintos despues de truncarlos" 
fi;

read -p "Pulsa enter para seguir. Apartado d)"

#Apartado d)
echo "fichero de pruebax64 "> $FICHERO
cp $FICHERO $MPOINT
echo "nuevo fichero creado $FICHERO"

read -p "Pulsa enter para seguir. Apartado e)"

#Apartado e)
echo "Mostrando disco virtual"
$ESTADO $VIRTUALDISK

DIFF3=$(diff "$FICHERO" "$COPIA_FICHERO3")
if [ DIFF3 = "" ]; 
then
	echo "$FICHERO y $COPIA_FICHERO3 son iguales." 
else
	echo "$FICHERO y $COPIA_FICHERO3 son diferentes. "
fi;
read -p "Pulsa enter para seguir. Apartado f)"

#Apartado f)
#CON esto averiguamos el tamaño de bloque del archivo
SIZE_FICHERO_ORIGINAL2=$(stat -c%s "$FICHERO_ORIGINAL2")

NEW_SIZE2=`expr $SIZE_FICHERO_ORIGINAL2 + $BLOCK_SIZE`
echo "Nuevo tamaño: $NEW_SIZE2"

echo "Truncando el segundo fichero en el archivo temporal"
truncate --size=$NEW_SIZE2 ./temp/myFS.h

echo "Truncando el segundo fichero en nuestro archivo SF"
truncate --size=$NEW_SIZE2 $COPIA_FICHERO2

read -p "Pulsa enter para seguir. Apartado g)"

echo "Mostrando disco virtual"
$ESTADO $VIRTUALDISK

DIFF2=$(diff "$FICHERO_ORIGINAL2" "$COPIA_FICHERO2")
if [ DIFF2 = "" ]; 
then
	echo "$FICHERO_ORIGINAL2 y $COPIA_FICHERO2 son iguales despues de truncarlos" 
else
	echo "$FICHERO_ORIGINAL2 y $COPIA_FICHERO2 son distintos despues de truncarlos" 
fi;
read -p "Todo bien, todo correcto. Pulsa enter"
