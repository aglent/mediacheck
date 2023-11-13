#!/bin/bash
###
 # @Author: Vincent Young
 # @Date: 2023-02-09 17:39:59
 # @LastEditors: Vincent Young
 # @LastEditTime: 2023-02-15 20:54:40
 # @FilePath: /OpenAI-Checker/openai.sh
 # @Telegram: https://t.me/missuo
 # 
 # Copyright © 2023 by Vincent, All Rights Reserved. 
### 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'
BLUE="\033[36m"

echo -e ""
echo -e "${BLUE}OpenAI Access Checker.${PLAIN}"
echo "-------------------------------------"
echo -e "[IPv4]"
check4=`ping 1.1.1.1 -c 1 2>&1`;
if [[ "$check4" != *"received"* ]] && [[ "$check4" != *"transmitted"* ]];then
   echo -e "\033[34mIPv4 is not supported on the current host. Skip...\033[0m";
else
   # local_ipv4=$(curl -4 -s --max-time 10 api64.ipify.org)
   local_ipv4=$(curl -4 -sS https://chat.openai.com/cdn-cgi/trace | grep "ip=" | awk -F= '{print $2}')
   local_isp4=$(curl -s -4 --max-time 10  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36" "https://api.ip.sb/geoip/${local_ipv4}" | grep organization | cut -f4 -d '"')
   #local_asn4=$(curl -s -4 --max-time 10  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36" "https://api.ip.sb/geoip/${local_ipv4}" | grep asn | cut -f8 -d ',' | cut -f2 -d ':')
   echo -e "${BLUE}Your IPv4: ${local_ipv4} - ${local_isp4}${PLAIN}"
   local_result1=$(curl -4 -sS --max-time 10 "https://chat.openai.com/auth/login" | egrep 'you have been blocked|If you are using a VPN')
   # local result2=$(curl -4 -sI --max-time 10 "https://chat.openai.com" | grep 'permissions-policy')
   # local_result2=$(curl -4 -sI --max-time 10 "https://chat.openai.com/auth/login" | grep 'HTTP/2 200')
   local_result3=$(curl -4 -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://chat.openai.com/public-api/conversation_limit" 2>&1)
   local_region=$(curl -4 -sS https://chat.openai.com/cdn-cgi/trace | grep "loc=" | awk -F= '{print $2}')
   # if [ -z "$local_result1" ] && [ -n "$local_result2" ] && [ "$local_result3" != "403" ]; then
   if [ -z "$local_result1" ] && [ "$local_result3" != "403" ]; then
      echo -e "${GREEN}Your IP supports access to OpenAI. Region: ${local_region}${PLAIN}" 
   else
      echo -e "${RED}Your IP is BLOCKED!${PLAIN}"
   fi
fi
echo "-------------------------------------"
echo -e "[IPv6]"
check6=`ping6 240c::6666 -c 1 2>&1`;
if [[ "$check6" != *"received"* ]] && [[ "$check6" != *"transmitted"* ]];then
   echo -e "\033[34mIPv6 is not supported on the current host. Skip...\033[0m";    
else
   # local_ipv6=$(curl -6 -s --max-time 20 api64.ipify.org)
   local_ipv6=$(curl -6 -sS https://chat.openai.com/cdn-cgi/trace | grep "ip=" | awk -F= '{print $2}')
   local_isp6=$(curl -s -6 --max-time 10 --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36" "https://api.ip.sb/geoip/${local_ipv6}" | grep organization | cut -f4 -d '"')
   #local_asn6=$(curl -s -6 --max-time 10  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36" "https://api.ip.sb/geoip/${local_ipv6}" | grep asn | cut -f8 -d ',' | cut -f2 -d ':')
   echo -e "${BLUE}Your IPv6: ${local_ipv6} - ${local_isp6}${PLAIN}"
   local_result1=$(curl -6 -sS --max-time 10 "https://chat.openai.com/auth/login" | egrep 'you have been blocked|If you are using a VPN')
   # local_result2=$(curl -6 -sI --max-time 10 "https://chat.openai.com/auth/login" | grep 'HTTP/2 200')
   local_result3=$(curl -6 -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://chat.openai.com/public-api/conversation_limit" 2>&1)
   local_region=$(curl -6 -sS https://chat.openai.com/cdn-cgi/trace | grep "loc=" | awk -F= '{print $2}')
   # if [ -z "$local_result1" ] && [ -n "$local_result2" ] && [ "$local_result3" != "403" ]; then
   if [ -z "$local_result1" ] && [ "$local_result3" != "403" ]; then
      echo -e "${GREEN}Your IP supports access to OpenAI. Region: ${local_region}${PLAIN}" 
   else
      echo -e "${RED}Your IP is BLOCKED!${PLAIN}"
   fi
fi
echo "-------------------------------------"
