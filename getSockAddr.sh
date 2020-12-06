#!/bin/bash

ARGC=$#
if [ $ARGC -ne 2 ]; then
    echo "Usage $0 username password"
    exit 2
fi

LOGINUSER=$1
PASSWORD=$2

TOKEN=$(curl --silent -k -X POST -H "os: i" -H "Content-Type: application/json" -d "{\"state\":\"欧洲\",\"countryCode\":\"49\",\"appVer\":\"1.7.8\",\"type\":\"2\",\"os\":\"IOS\",\"password\":\"$(echo -n $PASSWORD | md5sum)\",\"registrationId\":\"13165ffa4eb156ac484\",\"language\":\"EN\",\"username\":\"$LOGINUSER\",\"pwd\":\"$PASSWORD\"}" "https://mobile.proscenic.com.de/user/login" | jq --raw-output ".data.token")

SN=$(curl --silent "https://mobile.proscenic.com.de/user/getEquips/$LOGINUSER"  -d "username=$LOGINUSER" | jq --raw-output ".data.content[].sn")


# Is this required?
# curl --silent -H "token: $TOKEN" -d "username=$LOGINUSER&pathId=(null)" "https://mobile.proscenic.com.de/app/cleanRobot/21011/$SN/0"

SOCKADDR=$(curl --silent -H "Content-Type: application/x-www-form-urlencoded" -H "token: $TOKEN" -d "username=$LOGINUSER&sn=$SN" "https://mobile.proscenic.com.de/appInit/getSockAddr" | jq --raw-output '.data.addr_list[] | [ .ip, .port ] | join(":")')


echo "Serialnumber: $SN"
echo "Token: $TOKEN"
echo "Gateway: $SOCKADDR"
