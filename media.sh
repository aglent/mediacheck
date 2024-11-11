#!/bin/bash

UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36";
DisneyCountryList='HK TW US JP SG AU TR CA CO NZ KR GB DE BR SE'
netname=`ip a | grep  'WARP\|wgcf' | awk 'NR==1 {print $2}' | cut -d':' -f1`
if cat /etc/XrayR/config.yml | grep -q 'RouteConfigPath' && cat /etc/XrayR/route.json | grep -B 1 'geosite:netflix' | grep -q 'IPv6'; then
	useNICNF='-6'
elif cat /etc/XrayR/config.yml | grep -q 'RouteConfigPath' && cat /etc/XrayR/route.json | grep -B 1 'geosite:netflix' | grep -q 'IPv4'; then
	useNICNF='-4'
else
	useNICNF='-4'
fi
if cat /etc/XrayR/config.yml | grep -q 'RouteConfigPath' && cat /etc/XrayR/route.json | grep -B 1 'geosite:disney' | grep -q 'IPv6'; then
	useNICDS='-6'
elif cat /etc/XrayR/config.yml | grep -q 'RouteConfigPath' && cat /etc/XrayR/route.json | grep -B 1 'geosite:disney' | grep -q 'IPv4'; then
	useNICDS='-4'
else
	useNICDS='-4'
fi
if cat /etc/XrayR/config.yml | grep -q 'RouteConfigPath' && cat /etc/XrayR/route.json | grep -B 1 'geosite:google' | grep -q 'IPv6'; then
	useNICYB='-6'
elif cat /etc/XrayR/config.yml | grep -q 'RouteConfigPath' && cat /etc/XrayR/route.json | grep -B 1 'geosite:google' | grep -q 'IPv4'; then
	useNICYB='-4'
else
	useNICYB='-4'
fi
if cat /etc/XrayR/config.yml | grep -q 'RouteConfigPath' && cat /etc/XrayR/route.json | grep -B 1 'domain:openai.com' | grep -q 'IPv6'; then
	useNICAI='-6'
elif cat /etc/XrayR/config.yml | grep -q 'RouteConfigPath' && cat /etc/XrayR/route.json | grep -B 1 'domain:openai.com' | grep -q 'IPv4'; then
	useNICAI='-4'
else
	useNICAI='-4'
fi

function Test_Netflix() {
   local tmpresult1=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL  --max-time 10 "https://www.netflix.com/title/81280792" 2>&1)
   local tmpresult2=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL  --max-time 10 "https://www.netflix.com/title/70143836" 2>&1)
   local result1=$(echo $tmpresult1 | grep -oP '"isPlayable":\K(true|false)')
   local result2=$(echo $tmpresult2 | grep -oP '"isPlayable":\K(true|false)')
   if [[ "$result1" == "false" ]] && [[ "$result2" == "false" ]]; then
      echo -n -e "\r Netflix$useNICNF: Originals Only \n"
   elif [ -z "$result1" ] && [ -z "$result2" ]; then
      echo -n -e "\r Netflix$useNICNF: No \n"
   elif [[ "$result1" == "true" ]] || [[ "$result2" == "true" ]]; then
      local region1=$(echo $tmpresult1 | grep -oP '"requestCountry":{.*"id":"\K\w\w' | head -n 1)
      echo -n -e "\r Netflix$useNICNF: $region1 \n"
   else
      echo -n -e "\r Netflix$useNICNF: Failed (Network Connection) \n"
   fi
}

function Test_Disney() {
   if ! command -v python &> /dev/null; then
      ln -s /usr/bin/python3 /usr/bin/python
   fi
   local PreAssertion=$(curl $useNICDS --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://disney.api.edge.bamgrid.com/devices" -H "authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -H "content-type: application/json; charset=UTF-8" -d '{"deviceFamily":"browser","applicationRuntime":"chrome","deviceProfile":"windows","attributes":{}}' 2>&1)
   local assertion=$(echo $PreAssertion | python -m json.tool 2> /dev/null | grep assertion | cut -f4 -d'"')
   local PreDisneyCookie=$(curl $useNICDS -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '1p')
   local disneycookie=$(echo $PreDisneyCookie | sed "s/DISNEYASSERTION/${assertion}/g")
   local TokenContent=$(curl $useNICDS --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://disney.api.edge.bamgrid.com/token" -H "authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -d "$disneycookie")
   local isBanned=$(echo $TokenContent | python -m json.tool 2> /dev/null | grep 'forbidden-location')
   local is403=$(echo $TokenContent | grep '403 ERROR')

   if [ -n "$isBanned" ] || [ -n "$is403" ];then
      echo -n -e "\r Disney$useNICDS: 403-No \n"
      return;
   fi

   local fakecontent=$(curl $useNICDS -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '8p')
   local refreshToken=$(echo $TokenContent | python -m json.tool 2> /dev/null | grep 'refresh_token' | awk '{print $2}' | cut -f2 -d'"')
   local disneycontent=$(echo $fakecontent | sed "s/ILOVEDISNEY/${refreshToken}/g")
   local tmpresult=$(curl $useNICDS --user-agent "${UA_Browser}" -X POST -sSL --max-time 10 "https://disney.api.edge.bamgrid.com/graph/v1/device/graphql" -H "authorization: ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -d "$disneycontent" 2>&1)
   local previewcheck=$(curl $useNICDS -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://disneyplus.com" | grep preview)
   local isUnabailable=$(echo $previewcheck | grep 'unavailable')	

   if [[ "$tmpresult" == "curl"* ]];then
      echo -n -e "\r Disney$useNICDS: Failed (Network Connection) \n"
      return;
   fi

   local region2=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'countryCode' | cut -f4 -d'"')
   local inSupportedLocation=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'inSupportedLocation' | awk '{print $2}' | cut -f1 -d',')
   if [ -n "$region2" ] && [[ "$inSupportedLocation" == "true" ]];then
      echo -n -e "\r Disney$useNICDS: $region2 \n"
      return;
   elif [ -n "$region2" ] && [[ "$inSupportedLocation" == "false" ]] && [ -z "$isUnabailable" ];then
      echo -n -e "\r Disney$useNICDS: $region2 Soon \n"
      return;
   elif [ -n "$region2" ] && [ -n "$isUnabailable" ];then
      echo -n -e "\r Disney$useNICDS: No \n"
      return;
   elif [ -z "$region2" ];then
      echo -n -e "\r Disney$useNICDS: No \n"
      return;
   else
      echo -n -e "\r Disney$useNICDS: Failed \n"
      return;
   fi
}

function Test_Google() {
   local GG_result=$(curl $useNICYB --user-agent "${UA_Browser}" --max-time 10 -sSL -H "Accept-Language: en" -b "YSC=ZyA1G52eg5M; VISITOR_PRIVACY_METADATA=CgJERRIA; CONSENT=PENDING+115; SOCS=CAISOAgDEitib3FfaWRlbnRpdHlmcm9udGVuZHVpc2VydmVyXzIwMjMwOTE3LjA5X3AwGgV6aC1DTiACGgYIgI-uqAY; GPS=1; VISITOR_INFO1_LIVE=H3oPP45EiqU; PREF=f4=4000000&tz=Asia.Shanghai" "https://www.youtube.com/premium" 2>&1)
   if [[ "$GG_result" == "curl"* ]]; then
      echo -n -e "\r Google$useNICYB: Failed(Network Connection) \n"
      return
   fi
   local isCN=$(echo $GG_result | grep 'www.google.cn')
   if [ -n "$isCN" ]; then
      echo -n -e "\r Google$useNICYB: No(CN) \n"
      return
   fi
   local isNotAvailable=$(echo $GG_result | grep 'Premium is not available in your country')
   local region=$(echo $GG_result | grep "countryCode" | sed 's/.*"countryCode"//' | cut -f2 -d'"')
   local isAvailable=$(echo $GG_result | egrep '/month|/.month')
   if [ -n "$isNotAvailable" ]; then
      echo -n -e "\r Google$useNICYB: No($region) \n"
      return
   elif [ -n "$isAvailable" ] && [ -n "$region" ]; then
      echo -n -e "\r Google$useNICYB: $region \n"
      return
   elif [ -z "$region" ] && [ -n "$isAvailable" ]; then
      echo -n -e "\r Google$useNICYB: US \n"
      return
   else
      echo -n -e "\r Google$useNICYB: Failed \n"
   fi
}

function Test_Openai() {
   local result1=$(curl $useNICAI -sS --max-time 10 "https://chat.openai.com/auth/login" | egrep 'you have been blocked|If you are using a VPN')
   # local result2=$(curl $useNICAI -sI --max-time 10 "https://chat.openai.com/auth/login" | grep 'HTTP/2 200')
   local result3=$(curl $useNICAI -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://chat.openai.com/public-api/conversation_limit" 2>&1)
   local region=$(curl $useNICAI -sS https://chat.openai.com/cdn-cgi/trace | grep "loc=" | awk -F= '{print $2}')
   # if [ -z "$result1" ] && [ -n "$result2" ] && [ "$result3" != "403" ]; then
   if [ -z "$result1" ] ; then
      echo -n -e "\r OpenAI$useNICAI: $region \n"
   else
      echo -n -e "\r OpenAI$useNICAI: BLOCKED!"
   fi
}

function Loop() {
   #Test_Netflix
   local tmpresult1=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL  --max-time 10 "https://www.netflix.com/title/81280792" 2>&1)
   local tmpresult2=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL  --max-time 10 "https://www.netflix.com/title/70143836" 2>&1)
   local result1=$(echo $tmpresult1 | grep -oP '"isPlayable":\K(true|false)')
   local result2=$(echo $tmpresult2 | grep -oP '"isPlayable":\K(true|false)')
   if ! ([[ "$result1" == "true" ]] || [[ "$result2" == "true" ]]); then
      echo -n -e "\r Netflix$useNICNF失效.更新中 \n"
      for ((i=1; i<=30;i++))
      do
			if [[ ${netname} == "wgcf" ]]; then
				systemctl restart wg-quick@wgcf
				sleep 2
			elif [[ ${netname} == "WARP" ]]; then
				systemctl restart warp-go
				sleep 2
			elif [[ ${netname} == "CloudflareWARP" ]]; then
				systemctl restart warp-svc
				sleep 2
			fi
         #netflix check
         local tmpresult3=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL  --max-time 10 "https://www.netflix.com/title/81280792" 2>&1)
         local tmpresult4=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL  --max-time 10 "https://www.netflix.com/title/70143836" 2>&1)
         local result3=$(echo $tmpresult1 | grep -oP '"isPlayable":\K(true|false)')
         local result4=$(echo $tmpresult2 | grep -oP '"isPlayable":\K(true|false)')
         if [[ "$result3" == "true" ]] || [[ "$result4" == "true" ]]; then   #netflix ok
            #netflix country
            local region1=$(echo $tmpresult1 | grep -oP '"requestCountry":{.*"id":"\K\w\w' | head -n 1)
            echo -n -e "\r 重新获取次数:${i} \n"
            echo -n -e "\r Netflix$useNICNF: $region1 \n"
            break;
         elif [[ "$i" == 30 ]];then
            echo -n -e "\r 老子抓不到ip了,躺平吧 \n"
            break;
         fi
      done
   else
      #netflix country
      local region1=$(echo $tmpresult1 | grep -oP '"requestCountry":{.*"id":"\K\w\w' | head -n 1)
      echo -n -e "\r Netflix$useNICNF: $region1 \n"
   fi

   #Test_Disney
   Test_Disney

   #Test_Google
   local GG_result1=$(curl $useNICYB --user-agent "${UA_Browser}" --max-time 10 -sSL -H "Accept-Language: en" -b "YSC=ZyA1G52eg5M; VISITOR_PRIVACY_METADATA=CgJERRIA; CONSENT=PENDING+115; SOCS=CAISOAgDEitib3FfaWRlbnRpdHlmcm9udGVuZHVpc2VydmVyXzIwMjMwOTE3LjA5X3AwGgV6aC1DTiACGgYIgI-uqAY; GPS=1; VISITOR_INFO1_LIVE=H3oPP45EiqU; PREF=f4=4000000&tz=Asia.Shanghai" "https://www.youtube.com/premium" 2>&1)
   if [[ "$GG_result1" == "curl"* ]]; then
      echo -n -e "\r Google$useNICYB.更新中 \n"
      for ((i=1; i<=30;i++))
      do
			if [[ ${netname} == "wgcf" ]]; then
				systemctl restart wg-quick@wgcf
				sleep 2
			elif [[ ${netname} == "WARP" ]]; then
				systemctl restart warp-go
				sleep 2
			elif [[ ${netname} == "CloudflareWARP" ]]; then
				systemctl restart warp-svc
				sleep 2
			fi
         #google check
         local GG_result2=$(curl $useNICYB --user-agent "${UA_Browser}" --max-time 10 -sSL -H "Accept-Language: en" -b "YSC=ZyA1G52eg5M; VISITOR_PRIVACY_METADATA=CgJERRIA; CONSENT=PENDING+115; SOCS=CAISOAgDEitib3FfaWRlbnRpdHlmcm9udGVuZHVpc2VydmVyXzIwMjMwOTE3LjA5X3AwGgV6aC1DTiACGgYIgI-uqAY; GPS=1; VISITOR_INFO1_LIVE=H3oPP45EiqU; PREF=f4=4000000&tz=Asia.Shanghai" "https://www.youtube.com/premium" 2>&1)
         if [[ "$GG_result2" != "curl"* ]]; then   #google ok
            #google country
            local isCN=$(echo $GG_result1 | grep 'www.google.cn')
            local region=$(echo $GG_result2 | grep "countryCode" | sed 's/.*"countryCode"//' | cut -f2 -d'"')
            local isAvailable=$(echo $GG_result2 | egrep '/month|/.month')
            if [ -n "$isCN" ]; then
               echo -n -e "\r 重新获取次数:${i} \n"
               echo -n -e "\r Google$useNICYB: No(CN) \n"
               break;
            elif [ -n "$isAvailable" ] && [ -n "$region" ]; then
               echo -n -e "\r 重新获取次数:${i} \n"
               echo -n -e "\r Google$useNICYB: $region \n"
               break;
            elif [ -z "$region" ] && [ -n "$isAvailable" ]; then
               echo -n -e "\r 重新获取次数:${i} \n"
               echo -n -e "\r Google$useNICYB: US \n"
               break;
            fi
         elif [[ "$i" == 30 ]];then
            echo -n -e "\r 老子抓不到ip了,躺平吧 \n"
            break;
         fi
      done
   else
      local isCN=$(echo $GG_result1 | grep 'www.google.cn')
      if [ -n "$isCN" ]; then
         echo -n -e "\r Google$useNICYB: No(CN) \n"
      fi
      local isNotAvailable=$(echo $GG_result1 | grep 'Premium is not available in your country')
      local region=$(echo $GG_result1 | grep "countryCode" | sed 's/.*"countryCode"//' | cut -f2 -d'"')
      local isAvailable=$(echo $GG_result1 | egrep '/month|/.month')
      if [ -n "$isNotAvailable" ]; then
         echo -n -e "\r Google$useNICYB: No($region) \n"
      elif [ -n "$isAvailable" ] && [ -n "$region" ]; then
         echo -n -e "\r Google$useNICYB: $region \n"
      elif [ -z "$region" ] && [ -n "$isAvailable" ]; then
         echo -n -e "\r Google$useNICYB: US \n"
      else
         echo -n -e "\r Google$useNICYB: Failed \n"
      fi
   fi

   #Test_Openai
   Test_Openai
}


if [ "$1" = "nf" ];then
   Test_Netflix
elif [ "$1" = "disney" ];then
   Test_Disney
elif [ "$1" = "google" ];then
   Test_Google
elif [ "$1" = "openai" ];then
   Test_Openai
elif [ "$1" = "loop" ];then
   Loop
else
   Test_Netflix
   Test_Disney
   Test_Google
   Test_Openai
fi
