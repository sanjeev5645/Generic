#!/bin/bash


############### provide input csv file and platform IP as part of argument to script( $./uani2.sh uani.txt 10.79.199.205 ) ## #########
file="${1}"
p_ip="${2}"
###################

#echo "${p_ip}"

IFS=$'\n'


################## GENERATE AN AUTH KEY FOR EACH ITERATION OF SCRIPT ######################
auth=`curl -k  --header "Content-Type: application/json" --request POST --data '{"username": "admin@local","password": "admin","domain": {"domain_type":"LOCAL","value":""}}' "https://"${p_ip}"/api/ni/auth/token"`

auth_key1=`echo $auth | awk -F ',' '{print $1}' | awk -F ':' '{print $2}'`
auth_key=`echo $auth_key1| sed 's/"//'| sed 's/"//'`

#echo "AUTH KEY"
#echo "${auth_key}"
#########################################


############## FUNCTION USED FOR GENERATING DATA FIELD FOR POST API CALL INSIDE FOR LOOP ##############
generate_post_data()
{
  cat <<EOF
{"ip": "$ip","proxy_id": "$proxy_id","nickname": "$ip","enabled": true, "notes": "Located in DC1"}
EOF
}
####################################


############# LOOPs through each line in the input csv file. Reads the switch IP, username,password and proxy(collector) ID ##########
## Execute the python script which creates a config file in location  /tmp/uani/<switch_ip> , further a zip file is created as well ##  
#### Executes a POST CALL to create a Generic Switch and Executes a PUT call to update the Generic Switch with Configuration file  ####

for line in $(cat "${file}")
do
	#echo ${line}
	IFS=','
	read ip username password proxy_id <<< ${line}
	#echo $ip
	#echo $username
	#echo $password
	#echo $proxy_id
	python3 main.py -d alcatel1 -m n5k -s LINUX -i $ip -u $username -p $password -o alcatel1.zip
	
		
	zip -r /tmp/uani/$ip/yo.zip  /tmp/uani/$ip/*

	SW_PUSH=`curl -k -g  --header "Content-Type: application/json" --header  "Authorization: NetworkInsight $auth_key" --request POST --data "$(generate_post_data)" "https://"${p_ip}"/api/ni/data-sources/generic-switches"`
	
	switch_id=`echo "${SW_PUSH}"| awk -F ',' '{print $1}' | awk -F '"' '{print $4}'`

	SW_PUT=`curl -k -g  -X PUT --header 'Content-Type: multipart/form-data'  --header 'Accept: application/json' --header "Authorization: NetworkInsight $auth_key" --form "file=@\"/tmp/uani/$ip/yo.zip\""  "https://$p_ip/api/ni/data-sources/generic-switches/$switch_id/data"`

	echo $SW_PUT

	echo "****"
done