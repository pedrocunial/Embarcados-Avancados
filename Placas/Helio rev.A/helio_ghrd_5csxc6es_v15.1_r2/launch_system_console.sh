#!/bin/sh
echo Configure FPGA Before launch System Console
nios2-configure-sof output_files/soc_system.sof -d 2
echo 
echo Launch System Console
system-console --rc_script=system_console.tcl
