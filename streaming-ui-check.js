/***

Thanks to & modified from 
1. https://gist.githubusercontent.com/Hyseen/b06e911a41036ebc36acf04ddebe7b9a/raw/nf_check.js
2. https://github.com/AtlantisGawrGura/Quantumult-X-Scripts/blob/main/media.js
3. https://github.com/CoiaPrant/MediaUnlock_Test/blob/main/check.sh


For Quantumult-X 598+ ONLY!!
2022-02-22 - 14:20

[task_local]

event-interaction https://raw.githubusercontent.com/KOP-XIAO/QuantumultX/master/Scripts/streaming-ui-check.js, tag=流媒体-解锁查询, img-url=checkmark.seal.system, enabled=true



@XIAO_KOP

**/

const BASE_URL_NF = 'https://www.netflix.com/title/81280792';
const BASE_URL_YTB = "https://www.youtube.com/premium";
const BASE_URL_DISNEY = 'https://disneyplus.com';
const BASE_URL_DISNEY_LOCATION = 'https://disney.api.edge.bamgrid.com/graph/v1/device/graphql';
const BASE_URL_Dazn = "https://startup.core.indazn.com/misl/v5/Startup";
const policy_name = "Netflix" //填入你的 netflix 策略组名

const arrow = " ➟ "

const UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'

// 即将登陆
const STATUS_COMING = 2
// 支持解锁
const STATUS_AVAILABLE = 1
// 不支持解锁
const STATUS_NOT_AVAILABLE = 0
// 检测超时
const STATUS_TIMEOUT = -1
// 检测异常
const STATUS_ERROR = -2

var opts = {
  policy: $environment.params
};

var opts1 = {
  policy: $environment.params,
  redirection: false
};


var flags = new Map([[ "AC" , "🇦🇨" ] ,["AE","🇦🇪"], [ "AF" , "🇦🇫" ] , [ "AI" , "🇦🇮" ] , [ "AL" , "🇦🇱" ] , [ "AM" , "🇦🇲" ] , [ "AQ" , "🇦🇶" ] , [ "AR" , "🇦🇷" ] , [ "AS" , "🇦🇸" ] , [ "AT" , "🇦🇹" ] , [ "AU" , "🇦🇺" ] , [ "AW" , "🇦🇼" ] , [ "AX" , "🇦🇽" ] , [ "AZ" , "🇦🇿" ] , ["BA", "🇧🇦"], [ "BB" , "🇧🇧" ] , [ "BD" , "🇧🇩" ] , [ "BE" , "🇧🇪" ] , [ "BF" , "🇧🇫" ] , [ "BG" , "🇧🇬" ] , [ "BH" , "🇧🇭" ] , [ "BI" , "🇧🇮" ] , [ "BJ" , "🇧🇯" ] , [ "BM" , "🇧🇲" ] , [ "BN" , "🇧🇳" ] , [ "BO" , "🇧🇴" ] , [ "BR" , "🇧🇷" ] , [ "BS" , "🇧🇸" ] , [ "BT" , "🇧🇹" ] , [ "BV" , "🇧🇻" ] , [ "BW" , "🇧🇼" ] , [ "BY" , "🇧🇾" ] , [ "BZ" , "🇧🇿" ] , [ "CA" , "🇨🇦" ] , [ "CF" , "🇨🇫" ] , [ "CH" , "🇨🇭" ] , [ "CK" , "🇨🇰" ] , [ "CL" , "🇨🇱" ] , [ "CM" , "🇨🇲" ] , [ "CN" , "🇨🇳" ] , [ "CO" , "🇨🇴" ] , [ "CP" , "🇨🇵" ] , [ "CR" , "🇨🇷" ] , [ "CU" , "🇨🇺" ] , [ "CV" , "🇨🇻" ] , [ "CW" , "🇨🇼" ] , [ "CX" , "🇨🇽" ] , [ "CY" , "🇨🇾" ] , [ "CZ" , "🇨🇿" ] , [ "DE" , "🇩🇪" ] , [ "DG" , "🇩🇬" ] , [ "DJ" , "🇩🇯" ] , [ "DK" , "🇩🇰" ] , [ "DM" , "🇩🇲" ] , [ "DO" , "🇩🇴" ] , [ "DZ" , "🇩🇿" ] , [ "EA" , "🇪🇦" ] , [ "EC" , "🇪🇨" ] , [ "EE" , "🇪🇪" ] , [ "EG" , "🇪🇬" ] , [ "EH" , "🇪🇭" ] , [ "ER" , "🇪🇷" ] , [ "ES" , "🇪🇸" ] , [ "ET" , "🇪🇹" ] , [ "EU" , "🇪🇺" ] , [ "FI" , "🇫🇮" ] , [ "FJ" , "🇫🇯" ] , [ "FK" , "🇫🇰" ] , [ "FM" , "🇫🇲" ] , [ "FO" , "🇫🇴" ] , [ "FR" , "🇫🇷" ] , [ "GA" , "🇬🇦" ] , [ "GB" , "🇬🇧" ] , [ "HK" , "🇭🇰" ] ,["HU","🇭🇺"], [ "ID" , "🇮🇩" ] , [ "IE" , "🇮🇪" ] , [ "IL" , "🇮🇱" ] , [ "IM" , "🇮🇲" ] , [ "IN" , "🇮🇳" ] , [ "IS" , "🇮🇸" ] , [ "IT" , "🇮🇹" ] , [ "JP" , "🇯🇵" ] , [ "KR" , "🇰🇷" ] , [ "LU" , "🇱🇺" ] , [ "MD" , "🇲🇩" ] , [ "MO" , "🇲🇴" ] , [ "MX" , "🇲🇽" ] , [ "MY" , "🇲🇾" ] , [ "NG" , "🇳🇬" ] , [ "NL" , "🇳🇱" ] , [ "NZ" , "🇳🇿" ] , [ "PH" , "🇵🇭" ] , [ "RO" , "🇷🇴" ] , [ "RS" , "🇷🇸" ] , [ "RU" , "🇷🇺" ] , [ "RW" , "🇷🇼" ] , [ "SA" , "🇸🇦" ] , [ "SB" , "🇸🇧" ] , [ "SC" , "🇸🇨" ] , [ "SD" , "🇸🇩" ] , [ "SE" , "🇸🇪" ] , [ "SG" , "🇸🇬" ] , [ "TH" , "🇹🇭" ] , [ "TN" , "🇹🇳" ] , [ "TO" , "🇹🇴" ] , [ "TR" , "🇹🇷" ] , [ "TV" , "🇹🇻" ] , [ "TW" , "🇨🇳" ] , [ "UK" , "🇬🇧" ] , [ "UM" , "🇺🇲" ] , [ "US" , "🇺🇸" ] , [ "UY" , "🇺🇾" ] , [ "UZ" , "🇺🇿" ] , [ "VA" , "🇻🇦" ] , [ "VE" , "🇻🇪" ] , [ "VG" , "🇻🇬" ] , [ "VI" , "🇻🇮" ] , [ "VN" , "🇻🇳" ] , [ "ZA" , "🇿🇦"]])

let result = {
  "title": '    📺  流媒体解锁查询',
  "YouTube": '<b>YouTube: </b>检测失败，请重试 ❗️',
  "Netflix": '<b>Netflix: </b>检测失败，请重试 ❗️',
  "Dazn": "<b>Dazn: </b>检测失败，请重试 ❗️",
  "Disney": "<b>Disney: </b>检测失败，请重试 ❗️",
}
const message = {
  action: "get_policy_state",
  content: $environment.params
};

;(async () => {
  testYTB()
  testDazn()
  let [{ region, status }] = await Promise.all([testDisneyPlus(),testNF()])
  //console.log(result["Netflix"])
  //console.log(`testDisneyPlus: region=${region}, status=${status}`)
  if (status==STATUS_COMING) {
    //console.log(1)
    result["Disney"] = "<b>Disney:</b> 即将登陆 ➟ "+'⟦'+flags.get(region.toUpperCase())+"⟧ ⚠️"
  } else if (status==STATUS_AVAILABLE){
    //console.log(2)
    result["Disney"] = "<b>Disney:</b> 支持 ➟ "+'⟦'+flags.get(region.toUpperCase())+"⟧ 🎉"
    //console.log(result["Disney"])
  } else if (status==STATUS_NOT_AVAILABLE) {
    //console.log(3)
    result["Disney"] = "<b>Disney:</b> 未支持 🚫 "
  } else if (status==STATUS_TIMEOUT) {
    result["Disney"] = "<b>Disney:</b> 检测超时 🚦 "
  }

  let content = "------------------------------"+"</br>"+([result["YouTube"],result["Netflix"],result["Disney"],result["Dazn"]]).join("</br></br>")
  content = content + "</br>------------------------------</br>"+"<font color=#CD5C5C >"+"<b>节点</b> ➟ " + $environment.params+ "</font>"
  content =`<p style="text-align: center; font-family: -apple-system; font-size: large; font-weight: thin">` + content + `</p>`
$configuration.sendMessage(message).then(resolve => {
    if (resolve.error) {
      console.log(resolve.error);
      $done()
    }
    if (resolve.ret) {
      let output=JSON.stringify(resolve.ret[message.content])? JSON.stringify(resolve.ret[message.content]).replace(/\"|\[|\]/g,"").replace(/\,/g," ➟ ") : $environment.params
      let content = "--------------------------------------</br>"+([result["Dazn"],result["Disney"],result["Netflix"],result["YouTube"]]).join("</br></br>")
      content = content + "</br>--------------------------------------</br>"+"<font color=#CD5C5C>"+"<b>节点</b> ➟ " + output+ "</font>"
      content =`<p style="text-align: center; font-family: -apple-system; font-size: large; font-weight: thin">` + content + `</p>`
      //$notify(typeof(output),output)
      console.log(output);
      $done({"title":result["title"],"htmlMessage":content})
      
    }
    //$done();|
  }, reject => {
    // Normally will never happen.
    $done();
  });  
  //$done({"title":result["title"],"htmlMessage":content})
})()
.finally(() => {
  
  $configuration.sendMessage(message).then(resolve => {
    if (resolve.error) {
      console.log(resolve.error);
      $done()
    }
    if (resolve.ret) {
      let output=JSON.stringify(resolve.ret[message.content])? JSON.stringify(resolve.ret[message.content]).replace(/\"|\[|\]/g,"").replace(/\,/g," ➟ ") : $environment.params
      let content = "--------------------------------------</br>"+([result["Dazn"],result["Disney"],result["Netflix"],result["YouTube"]]).join("</br></br>")
      content = content + "</br>--------------------------------------</br>"+"<font color=#CD5C5C>"+"<b>节点</b> ➟ " + output+ "</font>"
      content =`<p style="text-align: center; font-family: -apple-system; font-size: large; font-weight: thin">` + content + `</p>`
      //$notify(typeof(output),output)
      console.log(output);
      $done({"title":result["title"],"htmlMessage":content})
      
    }
    //$done();|
  }, reject => {
    // Normally will never happen.
    $done();
  }); 
  
    $done({"title":result["title"],"htmlMessage":`<p style="text-align: center; font-family: -apple-system; font-size: large; font-weight: thin">`+'----------------------</br></br>'+"🚥 检测异常"+'</br></br>----------------------</br>'+ output + `</p>`})
}
  );


async function testDisneyPlus() {
  try {
    let { region, cnbl } = await Promise.race([disneyHomePage(), timeout(7000)])
    console.log(`disney: region=${region}, cnbl=${cnbl}`)

    let { countryCode, inSupportedLocation } = await Promise.race([disneyLocation(), timeout(7000)])
    console.log(`bamgrid: countryCode=${countryCode}, inSupported=${inSupportedLocation}`)
    
    region = countryCode ?? region
    console.log( "Final region:"+region)
    // 即将登陆
    if (inSupportedLocation === false || inSupportedLocation === 'false') {
      return { region, status: STATUS_COMING }
    } else {
      // 支持解锁
      return { region, status: STATUS_AVAILABLE }
    }

  } catch (error) {
    console.log("error:"+error)

    // 不支持解锁
    if (error === 'Not Available') {
      console.log("Final:Not Available")
      return { status: STATUS_NOT_AVAILABLE }
    }

    // 检测超时
    if (error === 'Timeout') {
      return { status: STATUS_TIMEOUT }
    }

    return { status: STATUS_ERROR }
  }
}

function disneyLocation() {
  return new Promise((resolve, reject) => {
    let opts0 = {
      url: BASE_URL_DISNEY_LOCATION,
      method: "POST",
      opts: opts,
      headers: {
        'Accept-Language': 'en',
        "Authorization": 'ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84',
        'Content-Type': 'application/json',
        'User-Agent': UA,
      },
      body: JSON.stringify({
        query: 'mutation registerDevice($input: RegisterDeviceInput!) { registerDevice(registerDevice: $input) { grant { grantType assertion } } }',
        variables: {
          input: {
            applicationRuntime: 'chrome',
            attributes: {
              browserName: 'chrome',
              browserVersion: '108.0.0.0',
              manufacturer: 'microsoft',
              model: null,
              operatingSystem: 'windows',
              operatingSystemVersion: '10.0',
              osDeviceIds: [],
            },
            deviceFamily: 'browser',
            deviceLanguage: 'en',
            deviceProfile: 'windows',
          },
        },
      }),
    }
    
    $task.fetch(opts0).then(response => {
      let data = response.body
      console.log("bamgrid:"+response.statusCode)
      if (response.statusCode !== 200) {
        console.log('error:'+response.statusCode)
        reject('Not Available')
        return
      } else {let {
        inSupportedLocation,
        location: { countryCode },
      } = JSON.parse(data)?.extensions?.sdk?.session
        resolve({ inSupportedLocation, countryCode })
      }
    }, reason => {
      reject('Error')
      return
    })
  })
}

function disneyHomePage() {
  return new Promise((resolve, reject) => {
    let opts0 = {
      url: BASE_URL_DISNEY,
      opts: opts,
      headers: {
        'Accept-Language': 'en',
        'User-Agent': UA,
      },
    }
    $task.fetch(opts0).then(response => {
      let data = response.body
      console.log("disney:"+response.statusCode)
      if (data.indexOf('not available in your region') !== -1) {
        console.log("Disney:no")
        reject('Not Available')
        return
      } else if (response.statusCode == 200) {
        let match = data.match(/Region: ([A-Za-z]{2})[\s\S]*?CNBL: ([12])/)
        if (!match) {
          resolve({ region: '', cnbl: '' })
          return
        } else {
          let region = match[1]
          let cnbl = match[2]
          resolve({ region, cnbl })
        }
      } else {
        console.log("Disney:no")
        reject('Not Available')
        return
      }
    }, reason => {
      reject('Error')
      return
    })
  })
}

function timeout(delay = 5000) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      reject('Timeout')
    }, delay)
  })
}


function testNF() {
  return new Promise((resolve, reject) =>{
    let option = {
      url: BASE_URL_NF,
      opts: opts,
      timeout: 5200,
      headers: {
        'Accept-Language': 'en',
        'User-Agent': UA
      },
    }
    $task.fetch(option).then(response => {
      console.log("nf:"+response.statusCode)
      if (response.statusCode === 404) {
        result["Netflix"] = "<b>Netflix: </b>仅支持自制剧 ⚠️"
        console.log("nf:only homemade")
        resolve('Not Found')
        return 
      } else if (response.statusCode === 403) {
        result["Netflix"] = "<b>Netflix: </b>未支持 🚫"
        console.log("nf:no")
        resolve('Not Available')
        return
      } else if (response.statusCode === 200) {
        let url = response.headers['X-Originating-URL']
        let region = url.split('/')[3]
        region = region.split('-')[0]
        if (region == 'title') {
          region = 'us'
        }
        console.log("nf:"+region)
        result["Netflix"] = "<b>Netflix: </b>支持"+arrow+ "⟦"+flags.get(region.toUpperCase())+"⟧ 🎉"
        resolve("nf:"+result["Netflix"])
        return 
      }
    }, reason => {
      result["Netflix"] = "<b>Netflix: </b>检测超时 🚦"
      console.log(result["Netflix"])
      resolve("timeout")
    }
    )
  }
  )
}

function testYTB() { 
    let option = {
      url: BASE_URL_YTB,
      opts: opts,
      timeout: 3000,
      headers: {
        'cookie': "CONSENT=YES+cb.20220807-18-p0.en+FX+402",
        'Accept-Language': 'en',
        'User-Agent': UA
      },
    }
    $task.fetch(option).then(response=> {
      let data = response.body
      console.log("ytb:"+response.statusCode)
      if (response.statusCode !== 200) {
        result["YouTube"] = "<b>YouTube: </b>检测失败 ❗️"
        console.log("ytb:error")
      } else if (data.indexOf('Premium is not available in your country') !== -1) {
        console.log("ytb:no")
        result["YouTube"] = "<b>YouTube: </b>未支持 🚫"
      } else if (data.indexOf('Premium is not available in your country') == -1) {
        let region = ''
        let re = new RegExp('"GL":"(.*?)"', 'gm')
        let ret = re.exec(data)
        if (ret != null && ret.length === 2) {
          region = ret[1]
        } else if (data.indexOf('www.google.cn') !== -1) {
          region = 'CN'
        } else {
          region = 'US'
        }
        result["YouTube"] = "<b>YouTube: </b>支持 "+arrow+ "⟦"+flags.get(region.toUpperCase())+"⟧ 🎉"
        console.log("ytb:"+region)
      }
    }, reason => {
      result["YouTube"] = "<b>YouTube: </b>检测超时 🚦"
    })
}

function testDazn() { 
  
  const extra =`{
    "LandingPageKey":"generic",
    "Platform":"web",
    "PlatformAttributes":{},
    "Manufacturer":"",
    "PromoCode":"",
    "Version":"2"
  }`
  let option = {
    url: BASE_URL_Dazn,
    method: "POST",
    opts: opts,
    timeout: 3000,
    headers: {
      'Accept-Language': 'en',
      'User-Agent': UA,
      "Content-Type": "application/json"
    },
    body: extra
  }

  $task.fetch(option).then(response=> {
    let data = response.body
    let header = JSON.stringify(response.headers)
    console.log("Dazn:"+response.statusCode)
    if (response.statusCode !== 200) {
      result["Dazn"] = "<b>Dazn: </b>检测失败 ❗️"
    } else if (response.statusCode == 200) {
      let region = ''
      let re = new RegExp('"GeolocatedCountry":"(.*?)"', 'gm')
      let ret = re.exec(data)
      if (ret != null && ret.length === 2) {
        region = ret[1]
        console.log("Dazn:"+region)
        result["Dazn"] = "<b>Dazn: </b>支持 "+arrow+ "⟦"+flags.get(region.toUpperCase())+"⟧ 🎉"
      } else {
        console.log("Dazn:no")
        result["Dazn"] = "<b>Dazn: </b>未支持 🚫"
      }
    }
  }, reason => {
    result["Dazn"] = "<b>Dazn: </b>检测超时 🚦"
  })
}

