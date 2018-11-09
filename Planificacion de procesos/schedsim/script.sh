#!/bin/bash
#pedir fichero y leerla en la variable fichero -f comprueba si el fichero existe
while true
do
	echo 'Que fichero de ejemplo desea simular:'
	read fichero
	if [ -f ./examples/$fichero ]
	then
	   echo "El fichero $fichero existe."
	   break
	else
	   echo "El fichero $fichero no existe."
	fi
done


#pedir cpus y leerla en la variable cpus -le comprueba numero menor o igual
while true
do
	echo 'Numero maximo de CPUs:'
	read cpus
	if [ $cpus -le 8 ]
	then
		echo "Numero cpus correcto $cpus"
		break
	else
		echo "Numero cpus No correcto $cpus"
	fi
done

#crear el directorio de resultados
rm -rf resultados
mkdir resultados


## declara  el array de planificadores
declare -a arr=("RR" "SJF" "FCFS" "PRIO")

## iterar array
for planificador in "${arr[@]}"
do
   echo "$planificador"
	for (( numcpus=1; numcpus <= $cpus; ++numcpus ))
	do
	    echo "$numcpus"
	    ./schedsim -i examples/$fichero -s $planificador -n $numcpus
		for (( i=0; i < $numcpus; ++i ))
		do
		    mv CPU_$i.log ./resultados/$planificador-CPU-$i.log
		done
		cd ../gantt-gplot
		for (( i=0; i < $numcpus; ++i ))
		do
			./generate_gantt_chart ../schedsim/resultados/$planificador-CPU-$i.log
		done
		cd ../schedsim
	done
done



