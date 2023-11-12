/**
 * Thanks to & modified from 
 * https://raw.githubusercontent.com/KOP-XIAO/QuantumultX/master/Scripts/streaming-ui-check.js
 * 
 * 脚本功能：检查节点是否支持以下流媒体服务：NetFlix、Disney、YouTuBe、Dazn、Param
 * For Loon 373+ Only, 小于373版本会有bug
 * 更新于：2022-04-11
 * 脚本使用方式：将以下配置粘贴于Loon配置文件中的[Script]模块下，也可以进行UI添加脚本，添加后需开启Loon代理，在策略组或者所有节点页面，选择一个节点长按，出现菜单后进行测试
 * 
 * [Script]
 * generic script-path=https://raw.githubusercontent.com/Loon0x00/LoonScript/main/MediaCheck/check.js, tag=流媒体-解锁查询, img-url=checkmark.seal.system
 */

const NF_BASE_URL = "https://www.netflix.com/title/81280792";
const DISNEY_BASE_URL = 'https://www.disneyplus.com';
const DISNEY_LOCATION_BASE_URL = 'https://disney.api.edge.bamgrid.com/graph/v1/device/graphql';
const YTB_BASE_URL = "https://www.youtube.com/premium";
const Dazn_BASE_URL = "https://startup.core.indazn.com/misl/v5/Startup";

const UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'

var inputParams = $environment.params;
var nodeName = inputParams.node;

let flags = new Map([[ "AC" , "🇦🇨" ] ,["AE","🇦🇪"], [ "AF" , "🇦🇫" ] , [ "AI" , "🇦🇮" ] , [ "AL" , "🇦🇱" ] , [ "AM" , "🇦🇲" ] , [ "AQ" , "🇦🇶" ] , [ "AR" , "🇦🇷" ] , [ "AS" , "🇦🇸" ] , [ "AT" , "🇦🇹" ] , [ "AU" , "🇦🇺" ] , [ "AW" , "🇦🇼" ] , [ "AX" , "🇦🇽" ] , [ "AZ" , "🇦🇿" ] , ["BA", "🇧🇦"], [ "BB" , "🇧🇧" ] , [ "BD" , "🇧🇩" ] , [ "BE" , "🇧🇪" ] , [ "BF" , "🇧🇫" ] , [ "BG" , "🇧🇬" ] , [ "BH" , "🇧🇭" ] , [ "BI" , "🇧🇮" ] , [ "BJ" , "🇧🇯" ] , [ "BM" , "🇧🇲" ] , [ "BN" , "🇧🇳" ] , [ "BO" , "🇧🇴" ] , [ "BR" , "🇧🇷" ] , [ "BS" , "🇧🇸" ] , [ "BT" , "🇧🇹" ] , [ "BV" , "🇧🇻" ] , [ "BW" , "🇧🇼" ] , [ "BY" , "🇧🇾" ] , [ "BZ" , "🇧🇿" ] , [ "CA" , "🇨🇦" ] , [ "CF" , "🇨🇫" ] , [ "CH" , "🇨🇭" ] , [ "CK" , "🇨🇰" ] , [ "CL" , "🇨🇱" ] , [ "CM" , "🇨🇲" ] , [ "CN" , "🇨🇳" ] , [ "CO" , "🇨🇴" ] , [ "CP" , "🇨🇵" ] , [ "CR" , "🇨🇷" ] , [ "CU" , "🇨🇺" ] , [ "CV" , "🇨🇻" ] , [ "CW" , "🇨🇼" ] , [ "CX" , "🇨🇽" ] , [ "CY" , "🇨🇾" ] , [ "CZ" , "🇨🇿" ] , [ "DE" , "🇩🇪" ] , [ "DG" , "🇩🇬" ] , [ "DJ" , "🇩🇯" ] , [ "DK" , "🇩🇰" ] , [ "DM" , "🇩🇲" ] , [ "DO" , "🇩🇴" ] , [ "DZ" , "🇩🇿" ] , [ "EA" , "🇪🇦" ] , [ "EC" , "🇪🇨" ] , [ "EE" , "🇪🇪" ] , [ "EG" , "🇪🇬" ] , [ "EH" , "🇪🇭" ] , [ "ER" , "🇪🇷" ] , [ "ES" , "🇪🇸" ] , [ "ET" , "🇪🇹" ] , [ "EU" , "🇪🇺" ] , [ "FI" , "🇫🇮" ] , [ "FJ" , "🇫🇯" ] , [ "FK" , "🇫🇰" ] , [ "FM" , "🇫🇲" ] , [ "FO" , "🇫🇴" ] , [ "FR" , "🇫🇷" ] , [ "GA" , "🇬🇦" ] , [ "GB" , "🇬🇧" ] , [ "HK" , "🇭🇰" ] ,["HU","🇭🇺"], [ "ID" , "🇮🇩" ] , [ "IE" , "🇮🇪" ] , [ "IL" , "🇮🇱" ] , [ "IM" , "🇮🇲" ] , [ "IN" , "🇮🇳" ] , [ "IS" , "🇮🇸" ] , [ "IT" , "🇮🇹" ] , [ "JP" , "🇯🇵" ] , [ "KR" , "🇰🇷" ] , [ "LU" , "🇱🇺" ] , [ "MD" , "🇲🇩" ] , [ "MO" , "🇲🇴" ] , [ "MX" , "🇲🇽" ] , [ "MY" , "🇲🇾" ] , [ "NG" , "🇳🇬" ] , [ "NL" , "🇳🇱" ] , [ "NZ" , "🇳🇿" ] , [ "PH" , "🇵🇭" ] , [ "RO" , "🇷🇴" ] , [ "RS" , "🇷🇸" ] , [ "RU" , "🇷🇺" ] , [ "RW" , "🇷🇼" ] , [ "SA" , "🇸🇦" ] , [ "SB" , "🇸🇧" ] , [ "SC" , "🇸🇨" ] , [ "SD" , "🇸🇩" ] , [ "SE" , "🇸🇪" ] , [ "SG" , "🇸🇬" ] , [ "TH" , "🇹🇭" ] , [ "TN" , "🇹🇳" ] , [ "TO" , "🇹🇴" ] , [ "TR" , "🇹🇷" ] , [ "TV" , "🇹🇻" ] , [ "TW" , "🇨🇳" ] , [ "UK" , "🇬🇧" ] , [ "UM" , "🇺🇲" ] , [ "US" , "🇺🇸" ] , [ "UY" , "🇺🇾" ] , [ "UZ" , "🇺🇿" ] , [ "VA" , "🇻🇦" ] , [ "VE" , "🇻🇪" ] , [ "VG" , "🇻🇬" ] , [ "VI" , "🇻🇮" ] , [ "VN" , "🇻🇳" ] , [ "ZA" , "🇿🇦"]])

let result = {
    "title": '    📺  流媒体解锁查询',
    "YouTube": '<b>YouTube: </b>检测失败，请重试 ❗️',
    "Netflix": '<b>Netflix: </b>检测失败，请重试 ❗️',
    "Dazn": "<b>Dazn: </b>检测失败，请重试 ❗️",
    "Disney": "<b>Disney: </b>检测失败，请重试 ❗️",
}

let arrow = " ➟ "

Promise.all([testYTB(),testDisney(),testNF(),testDazn()]).then(value => {
    let content = "</br>"+([result["Dazn"],result["Disney"],result["Netflix"],result["YouTube"]]).join("</br></br>")
    content = content + "</br></br>"+"<font color=#CD5C5C>"+"<b>节点</b> ➟ " + nodeName+ "</font>"
    content =`<p style="text-align: center; font-family: -apple-system; font-size: large; font-weight: thin">` + content + `</p>`
    //console.log(content);
    $done({"title":result["title"],"htmlMessage":content})
}).catch (values => {
    //console.log("reject:" + values);
    let content = "</br>"+([result["Dazn"],result["Disney"],result["Netflix"],result["YouTube"]]).join("</br></br>")
    content = content + "</br></br>"+"<font color=#CD5C5C>"+"<b>节点</b> ➟ " + nodeName+ "</font>"
    content =`<p style="text-align: center; font-family: -apple-system; font-size: large; font-weight: thin">` + content + `</p>`
    $done({"title":result["title"],"htmlMessage":content})
})



function testDisney() {
    return new Promise((resolve, reject) => {
        let params = {
            url: DISNEY_LOCATION_BASE_URL,
            node: nodeName,
            timeout: 5000,
            headers: {
                'Accept-Language': 'en',
                "Authorization": 'ZGlzbmV5JmJyb3dzZXImMS4wLjA.Cu56AgSfBTDag5NiRA81oLHkDZfu5L3CKadnefEAY84',
                'Content-Type': 'application/json',
                'User-Agent': 'UA'
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
        $httpClient.post(params, (errormsg,response,data) => {
            if (errormsg) {
                resolve("disney request failed:" + errormsg);
                return;
            }
            if (response.status == 200) {
                console.log("disney request result:" + response.status);
                let resData = JSON.parse(data);
                if (resData?.extensions?.sdk?.session != null) {
                    let {
                        inSupportedLocation,
                        location: { countryCode },
                    } = resData?.extensions?.sdk?.session
                    if (inSupportedLocation == false) {
                        result["Disney"] = "<b>Disney:</b> 即将登陆 ➟ "+'⟦'+flags.get(countryCode.toUpperCase())+"⟧ ⚠️"
                        resolve();
                    } else {
                        result["Disney"] = "<b>Disney:</b> 支持 ➟ "+'⟦'+flags.get(countryCode.toUpperCase())+"⟧ 🎉"
                        resolve({ inSupportedLocation, countryCode });
                    }
                } else {
                    result["Disney"] = "<b>Disney:</b> 未支持 🚫 ";
                    resolve();
                }
            } else {
                result["Discovery"] = "<b>Disney:</b>检测失败 ❗️";
                resolve();
            }
        })
    })
}


function testNF() {
    return new Promise((resolve, reject) => {
        let params = {
            url: NF_BASE_URL,
            node: nodeName,
            timeout: 5200,
            headers: {
                'Accept-Language': 'en',
                'User-Agent': UA
            }
        }
        $httpClient.get(params, (errormsg,response,data) => {
            if (errormsg) {
                console.log("NF failed:" + errormsg);
                resolve(errormsg);
                return;
            }
            console.log("nf:"+response.status)
            if (response.status == 404) {
                console.log("nf:only homemade")
                result["Netflix"] = "<b>Netflix: </b>仅支持自制剧 ⚠️"
                resolve("404 Not Found");
            } else if (response.status == 403) {
                console.log("nf:no")
                result["Netflix"] = "<b>Netflix: </b>未支持 🚫"
                resolve("403 Not Available");
            } else if (response.status == 200) {
                let ourl = response.headers['X-Originating-URL']
                if (ourl == undefined) {
                    ourl = response.headers['X-Originating-Url']
                }
                //console.log("X-Originating-URL:" + ourl)
                let region = ourl.split('/')[3]
                region = region.split('-')[0];
                if (region == 'title') {
                    region = 'us'
                }
                console.log("nf:"+region)
                result["Netflix"] = "<b>Netflix: </b>支持"+arrow+ "⟦"+flags.get(region.toUpperCase())+"⟧ 🎉"
                resolve(region);
            } else {
                result["Netflix"] = "<b>Netflix: </b>检测失败 ❗️";
                resolve(response.status)
            }
        })
    })
}

function testYTB() {
    return new Promise((resolve, reject) => {
        let params = {
            url: YTB_BASE_URL,
            node: nodeName,
            timeout: 4000,
            headers: {
                'cookie': "CONSENT=YES+cb.20220807-18-p0.en+FX+402",
                'Accept-Language': 'en',
                'User-Agent': UA
            }
        }
        $httpClient.get(params, (errormsg,response,data) => {
            if (errormsg) {
                console.log("YTB request failed:" + errormsg);
                resolve(errormsg);
                return;
            }
            console.log("ytb:"+response.status)
            if (response.status !== 200) {
                console.log("ytb:error")
                result["YouTube"] = "<b>YouTube: </b>检测失败 ❗️";
                resolve(response.status);
            } else if (data.indexOf('Premium is not available in your country') !== -1) {
                console.log("ytb:no")
                result["YouTube"] = "<b>YouTube: </b>未支持 🚫"
                resolve("YTB test failed");
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
                console.log("ytb:"+region)
                result["YouTube"] = "<b>YouTube: </b>支持 "+arrow+ "⟦"+flags.get(region.toUpperCase())+"⟧ 🎉"
                resolve(region);
            }
        })
    })
}

function testDazn() {
    return new Promise((resolve, reject) => {
        const extra =`{
            "LandingPageKey":"generic",
            "Platform":"web",
            "PlatformAttributes":{},
            "Manufacturer":"",
            "PromoCode":"",
            "Version":"2"
          }`;
        let params = {
            url: Dazn_BASE_URL,
            node: nodeName,
            timeout: 4000,
            headers: {
                'Accept-Language': 'en',
                'User-Agent': UA,
                "Content-Type": "application/json"
            },
            body: extra
        };
        $httpClient.post(params, (errormsg,response,data) => {
            if (errormsg) {
                console.log("Dazn request error:" + errormsg);
                resolve(errormsg);
                return;
            }
            console.log("Dazn:"+response.status)
            if (response.status == 200) {
                let region = ''
                let re = new RegExp('"GeolocatedCountry":"(.*?)"', 'gm');
                let ret = re.exec(data)
                if (ret != null && ret.length === 2) {
                    region = ret[1];
                    console.log("Dazn:"+region)
                    result["Dazn"] = "<b>Dazn: </b>支持 "+arrow+ "⟦"+flags.get(region.toUpperCase())+"⟧ 🎉";
                } else {
                    console.log("Dazn:no")
                    result["Dazn"] = "<b>Dazn: </b>未支持 🚫";
                }
                resolve(region);
            } else {
                result["Dazn"] = "<b>Dazn: </b>检测失败 ❗️";
                resolve(response.status);
            }
        })
    })
}
