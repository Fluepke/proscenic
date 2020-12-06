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
USERNAME=iot@example.com
PASSWORD=very-secure
curl -v -k -X POST -H "os: i" -H "Content-Type: application/json" -H "c: 338" -H "lan: en" -H "Host: mobile.proscenic.com.de:443" -H "User-Agent: ProscenicHome/1.7.8 (iPhone; iOS 14.2.1; Scale/3.00)" -H "v: 1.7.8" -d "{\"state\":\"欧洲\",\"countryCode\":\"49\",\"appVer\":\"1.7.8\",\"type\":\"2\",\"os\":\"IOS\",\"password\":\"$(echo -n $PASSWORD | md5sum)\",\"registrationId\":\"13165ffa4eb156ac484\",\"language\":\"EN\",\"username\":\"$USERNAME\",\"pwd\":\"$PASSWORD\"}" "https://mobile.proscenic.com.de/user/login"
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
> **Finding #1**: No login (only username) required
```bash
curl "https://mobile.proscenic.com.de/user/getEquips/$USERNAME"  -d "username=$USERNAME"
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

