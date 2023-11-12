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
   local result1=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81280792" 2>&1)
   local result2=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/70143836" 2>&1)
   if [[ "$result1" == "404" ]] && [[ "$result2" == "404" ]]; then
      echo -n -e "\r Netflix$useNICNF: Originals Only \n"
   elif [[ "$result1" == "403" ]] && [[ "$result2" == "403" ]]; then
      echo -n -e "\r Netflix$useNICNF: No \n"
   elif [[ "$result1" == "200" ]] || [[ "$result2" == "200" ]]; then
      local region1=`tr [:lower:] [:upper:] <<< $(curl $useNICNF --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1)` ;
      if [[ ! -n "$region1" ]];then
         region1="US";
      fi
      echo -n -e "\r Netflix$useNICNF: $region1 \n"
   elif  [[ "$result1" == "000" ]];then
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
      echo -n -e "\r Disney$useNICDS: $region2 Available Soon \n"
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
    local tmpresult=$(curl $useNICYB --user-agent "${UA_Browser}" --max-time 10 -sSL -H "Accept-Language: en" -b "YSC=ZyA1G52eg5M; VISITOR_PRIVACY_METADATA=CgJERRIA; CONSENT=PENDING+115; SOCS=CAISOAgDEitib3FfaWRlbnRpdHlmcm9udGVuZHVpc2VydmVyXzIwMjMwOTE3LjA5X3AwGgV6aC1DTiACGgYIgI-uqAY; GPS=1; VISITOR_INFO1_LIVE=H3oPP45EiqU; PREF=f4=4000000&tz=Asia.Shanghai" "https://www.youtube.com/premium" 2>&1)

    if [[ "$tmpresult" == "curl"* ]]; then
        echo -n -e "\r Google$useNICYB: Failed(Network Connection) \n"
        return
    fi

    local isCN=$(echo $tmpresult | grep 'www.google.cn')
    if [ -n "$isCN" ]; then
        echo -n -e "\r Google$useNICYB: No(CN) \n"
        return
    fi
    local isNotAvailable=$(echo $tmpresult | grep 'Premium is not available in your country')
    local region=$(echo $tmpresult | grep "countryCode" | sed 's/.*"countryCode"//' | cut -f2 -d'"')
    local isAvailable=$(echo $tmpresult | egrep '/month|/.month')

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
   local result2=$(curl $useNICAI -sI --max-time 10 "https://chat.openai.com/auth/login" | grep 'HTTP/2 200')
   local result3=$(curl $useNICAI -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://chat.openai.com/public-api/conversation_limit" 2>&1)
   local region=$(curl $useNICAI -sS https://chat.openai.com/cdn-cgi/trace | grep "loc=" | awk -F= '{print $2}')
   if [ -z "$result1" ] && [ -n "$result2" ] && [ "$result3" != "403" ]; then
      echo -n -e "\r OpenAI$useNICAI: $region \n"
   else
      echo -n -e "\r OpenAI$useNICAI: BLOCKED!"
   fi
}

function Loop() {
   local result1=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81280792" 2>&1)
   local result2=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/70143836" 2>&1)
   if ! ([[ "$result1" == "200" ]] || [[ "$result2" == "200" ]]); then
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
         local result3=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81280792" 2>&1)
         local result4=$(curl $useNICNF --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/70143836" 2>&1)
         if [[ "$result3" == "200" ]] || [[ "$result4" == "200" ]]; then   #netflix ok
            # Disney check
            local PreAssertion=$(curl $useNICDS --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://disney.api.edge.bamgrid.com/devices" -H "authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -H "content-type: application/json; charset=UTF-8" -d '{"deviceFamily":"browser","applicationRuntime":"chrome","deviceProfile":"windows","attributes":{}}' 2>&1)
            local assertion=$(echo $PreAssertion | python -m json.tool 2> /dev/null | grep assertion | cut -f4 -d'"')
            local PreDisneyCookie=$(curl $useNICDS -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '1p')
            local disneycookie=$(echo $PreDisneyCookie | sed "s/DISNEYASSERTION/${assertion}/g")
            local TokenContent=$(curl $useNICDS --user-agent "${UA_Browser}" -s --max-time 10 -X POST "https://disney.api.edge.bamgrid.com/token" -H "authorization: Bearer ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -d "$disneycookie")
            local isBanned=$(echo $TokenContent | python -m json.tool 2> /dev/null | grep 'forbidden-location')
            local is403=$(echo $TokenContent | grep '403 ERROR')
            
            if [ -n "$isBanned" ] || [ -n "$is403" ];then
               echo -n -e "\r Disney$useNICDS: 403-No \n"
               echo -n -e "\r 重新获取 \n"
            else
               #netflix country
               local region1=`tr [:lower:] [:upper:] <<< $(curl $useNICDS --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1)` ;
               if [[ ! -n "$region1" ]];then
                  region1="US";
               fi
               echo -n -e "\r 重新获取次数:${i} \n"
               echo -n -e "\r Netflix$useNICNF: $region1 \n"
               if [[ $(echo $DisneyCountryList | grep "${region1}") != "" ]];then
                  #Disney country
                  local fakecontent=$(curl $useNICDS -s --max-time 10 "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/cookies" | sed -n '8p')
                  local refreshToken=$(echo $TokenContent | python -m json.tool 2> /dev/null | grep 'refresh_token' | awk '{print $2}' | cut -f2 -d'"')
                  local disneycontent=$(echo $fakecontent | sed "s/ILOVEDISNEY/${refreshToken}/g")
                  local tmpresult=$(curl $useNICDS --user-agent "${UA_Browser}" -X POST -sSL --max-time 10 "https://disney.api.edge.bamgrid.com/graph/v1/device/graphql" -H "authorization: ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84" -d "$disneycontent" 2>&1)
                  local previewcheck=$(curl $useNICDS -s -o /dev/null -L --max-time 10 -w '%{url_effective}\n' "https://disneyplus.com" | grep preview)
                  local isUnabailable=$(echo $previewcheck | grep 'unavailable')	

                  local region2=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'countryCode' | cut -f4 -d'"')
                  local inSupportedLocation=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'inSupportedLocation' | awk '{print $2}' | cut -f1 -d',')
                  if [ -n "$region2" ] && [[ "$inSupportedLocation" == "true" ]];then
                     echo -n -e "\r Disney$useNICDS: $region2 \n"
                  elif [ -n "$region2" ] && [[ "$inSupportedLocation" == "false" ]] && [ -z "$isUnabailable" ];then
                     echo -n -e "\r Disney$useNICDS: $region2 Available Soon \n"
                  elif [ -n "$region2" ] && [ -n "$isUnabailable" ];then
                     echo -n -e "\r Disney$useNICDS: No \n"
                  elif [ -z "$region2" ];then
                     echo -n -e "\r Disney$useNICDS: No \n"
                  else
                     echo -n -e "\r Disney$useNICDS: Failed \n"
                  fi
               fi
               Test_Google
               Test_Openai
               break;
            fi
         elif [[ "$i" == 30 ]];then
            echo -n -e "\r 老子抓不到ip了,躺平吧 \n"
            break;
         fi
      done
   else
      #netflix country
      local region1=`tr [:lower:] [:upper:] <<< $(curl $useNICNF --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1)` ;
      if [[ ! -n "$region1" ]];then
         region1="US";
      fi
      echo -n -e "\r Netflix$useNICNF: $region1 \n"

      if [[ $(echo $DisneyCountryList | grep "${region1}") != "" ]];then
         #Disney country
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

         local region2=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'countryCode' | cut -f4 -d'"')
         local inSupportedLocation=$(echo $tmpresult | python -m json.tool 2> /dev/null | grep 'inSupportedLocation' | awk '{print $2}' | cut -f1 -d',')
         if [ -n "$region2" ] && [[ "$inSupportedLocation" == "true" ]];then
            echo -n -e "\r Disney$useNICDS: $region2 \n"
         elif [ -n "$region2" ] && [[ "$inSupportedLocation" == "false" ]] && [ -z "$isUnabailable" ];then
            echo -n -e "\r Disney$useNICDS: $region2 Available Soon \n"
         elif [ -n "$region2" ] && [ -n "$isUnabailable" ];then
            echo -n -e "\r Disney$useNICDS: No \n"
         elif [ -z "$region2" ];then
            echo -n -e "\r Disney$useNICDS: No \n"
         else
            echo -n -e "\r Disney$useNICDS: Failed \n"
         fi
      fi
      Test_Google
      Test_Openai
   fi
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
