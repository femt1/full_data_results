#!/bin/bash

declare -a StringArray=(
 #"gen" 
"ott" "oap" "bal" )

eval $(minikube docker-env)

docker build -t jdk05-05-1-opt:v1 -f ott/Dockerfile .
docker build -t jdk05-05-1-gen:v1 -f gen/Dockerfile . 
docker build -t jdk05-05-1-oap:v1 -f oap/Dockerfile .
docker build -t jdk05-05-1-bal:v1 -f bal/Dockerfile .
read pod_name_file
read pod_name
#echo $pod_name
read container_1
read containerhh_2
no="No resources found."
for val in "${StringArray[@]}"
do
for i in {1..16}
do
	kubectl delete pods $pod_name

	#assume minikube is running and docker image has been built
	#echo $pod_name
	#kubectl create -f $pod_name_file
	kubectl create -f $val-$pod_name_file
	kubectl top pods $pod_name --containers &>> double-$pod_name-$val-top$i.txt
	echo "Created pod"
	sleep 10
	while true;
		do
			answer=$(kubectl get pods  --field-selector status.phase=Running)
			echo $answer
			kubectl top pods $pod_name --containers &>> double-$pod_name-$val-top$i.txt
			if [[ $no != *"$answer"* ]]; then
				break
			fi
		done
	echo "Running now"
	while true;
		do
			answer=$(kubectl get pods  --field-selector status.phase=Running)
			echo $answer 
			echo $answer &>> $pod_name-$i-$val-statuslogs.txt
			kubectl top pods $pod_name --containers &>> double-$pod_name-$val-top$i.txt
			if [[ $no == *"$answer"* ]]; then
				break
			fi
		done
	echo "Starting logs"
	kubectl logs $pod_name -c $container_1 >> double-$container_1-$i-$val-verbose.txt
	kubectl logs $pod_name -c $container_2 >> double-$container_2-$i-$val-verbose.txt

	kubectl top pods $pod_name --containers &>> double-$pod_name-$val-top$i.txt
		
done
mkdir jdk0.5-0.5-1-$val-files-double
#mkdir $val-files-single
mv double-$container_2-*-$val-verbose.txt jdk0.5-0.5-1-$val-files-double
mv double-$container_1-*-$val-verbose.txt jdk0.5-0.5-1-$val-files-double
mv double-$pod_name-$val-top* jdk0.5-0.5-1-$val-files-double
mv double-$pod_name-*-$val* jdk0.5-0.5-1-$val-files-double
mv $pod_name-$i-$val-statuslogs.txt jdk0.5-0.5-1-$val-files-double
done
