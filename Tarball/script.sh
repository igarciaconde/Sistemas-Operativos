#!/bin/bash

# -x mira si tiene permisos de ejecucion, -f que tiene datos y - e si existe

if [ -e mytar ] && [ -f mytar ] && [ -x mytar ]; then
	if [ -d tmp ]; then  #- d comprueba que exista el directorio temp en el directorio actiaul
	rm -r tmp
	fi
	
	#creamos el direcorio tmp y entramos en el 
	mkdir tmp 
	cd tmp
	
	
	#escribimos en unos ficheros
	echo "Hello World!">file1.txt
	head -n 10 </etc/passwd> file2.txt
	head -c 1024 </dev/urandom>file3.dat
	
	
	#ejecutamos mytar
	../mytar -cf mytarfiles.mtar file1.txt file2.txt file3.dat
	
	#creamos otro directorio 
	mkdir tmpextraccion
	#copiamos el mtar ahí
	cp mytarfiles.mtar tmpextraccion
	cd tmpextraccion
	
	#descomprimimos el archivo
	../../mytar -xf mytarfiles.mtar
	
	#comprobamos que sean los mismos archivos 
	if diff file1.txt ../file1.txt && diff file2.txt ../file2.txt &&  diff file3.dat ../file3.dat; 
	then
		cd ../../
		echo "Todo bien, todo correcto"
		exit 0
	else
		echo "Ficheros distintos"
		exit 1
	fi
else 
	echo "mytar no es fichero ejecutable"
	exit 1
fi 
