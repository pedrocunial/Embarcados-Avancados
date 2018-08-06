#!/bin/sh -x

# Create DeviceTree Source
sopc2dts --input soc_system.sopcinfo\
 --output soc_system.dts --type dts\
 --board soc_system_board_info.xml\
 --board hps_common_board_info.xml\
 --bridge-removal all\
 --clocks

# Create DeviceTree Blob
sopc2dts --input soc_system.sopcinfo\
 --output soc_system.dtb --type dtb\
 --board soc_system_board_info.xml\
 --board hps_common_board_info.xml\
 --bridge-removal all\
 --clocks
