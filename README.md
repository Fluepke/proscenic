# Proscenic M7 Pro - reverse engineering

> This is a WIP

Firmware update was acquired by tcpdumping the robot's traffic.
You can find the latest firmware (as of 06.12.2020) in `./firmware.bin`.

[binwalk](https://github.com/ReFirmLabs/binwalk) is used for decompressiong the firmware: `binwalk -eM firmware.bin`.
