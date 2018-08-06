#******************************************************************************
#                                                                             *
#                  Copyright (C) 2013 Altera Corporation                      *
#                                                                             *
# ALTERA, ARRIA, CYCLONE, HARDCOPY, MAX, MEGACORE, NIOS, QUARTUS & STRATIX    *
# are Reg. U.S. Pat. & Tm. Off. and Altera marks in and outside the U.S.      *
#                                                                             *
# All information provided herein is provided on an "as is" basis,            *
# without warranty of any kind.                                               *
#                                                                             *
# File Name: SoC_Labs_System_Console.tcl                                      *
#                                                                             *
# File Function: This Script will set up a System Console Dashboard           *
#	    That enables the user to easily manipulate LEDs and read switches      *
#                                                                             *
#******************************************************************************


# ******************************************************************************
# This Procedure toggles the LED when you push the button on the dashboard

proc toggle_led { dash_path led } {
 
	set master_path [lindex [get_service_paths master] 1]
	open_service master $master_path
	
	set led_read [master_read_8 $master_path 0x10040	1] 
	
	if {$led == 0 } {
	  set led_set [expr 1 ^ $led_read] }
	
	if {$led == 1 } {
	  set led_set [expr 2 ^ $led_read] }

	if {$led == 2 } {
	  set led_set [expr 4 ^ $led_read] }
	
	if {$led == 3 }  {
	  set led_set [expr 8 ^ $led_read] }
	
  	master_write_8 $master_path 0x10040 $led_set
	
	set led_read [master_read_8 $master_path 0x10040	1] 
	
	if { [expr {$led_read & 1}] == 1 } {
      dashboard_set_property $dash_path LED0_led color red 
		}

	if { [expr {$led_read & 1}] == 0 } {
      dashboard_set_property $dash_path LED0_led color green 
		}

	if { [expr {$led_read & 2}] == 2 } {
      dashboard_set_property $dash_path LED1_led color red 
		}
	

	if { [expr {$led_read & 2}] == 0 } {
      dashboard_set_property $dash_path LED1_led color green 
		}

	if { [expr {$led_read & 4}] == 4 } {
      dashboard_set_property $dash_path LED2_led color red 
		}

	if { [expr {$led_read & 4}] == 0 } {
      dashboard_set_property $dash_path LED2_led color green 
		}

	if { [expr {$led_read & 8}] == 8 } {
      dashboard_set_property $dash_path LED3_led color red 
		}
	
	if { [expr {$led_read & 8}] == 0 } {
      dashboard_set_property $dash_path LED3_led color green 
		}
		
	close_service master $master_path

}

	
# ******************************************************************************
# Everything Below This Line are used the Generate the Dashboard GUI

#set master_path [lindex [get_service_paths master] 1]
#open_service master $master_path

#
# Create Dashboard
set dash_path [add_service dashboard sys_dash "Helio GHRD Dashboard" "Tools/Helio GHRD Dashboard"]
dashboard_set_property $dash_path self visible true

##Setup Group to Organize everything
dashboard_add $dash_path all group self
dashboard_set_property $dash_path all title "Helio GHRD Board Test"
dashboard_set_property $dash_path all itemsPerRow 1
##
#Buttons Groups
dashboard_add $dash_path buttons group all
dashboard_set_property $dash_path buttons title "LED Toggle"
dashboard_set_property $dash_path buttons itemsPerRow 4

dashboard_add $dash_path LED0_led led buttons
dashboard_set_property $dash_path LED0_led text " "
dashboard_set_property $dash_path LED0_led color green

dashboard_add $dash_path LED1_led led buttons
dashboard_set_property $dash_path LED1_led text " "
dashboard_set_property $dash_path LED1_led color green

dashboard_add $dash_path LED2_led led buttons
dashboard_set_property $dash_path LED2_led text " "
dashboard_set_property $dash_path LED2_led color green

dashboard_add $dash_path LED3_led led buttons
dashboard_set_property $dash_path LED3_led text " "
dashboard_set_property $dash_path LED3_led color green


##Insert LED 0 Button
dashboard_add $dash_path LED0 button buttons
dashboard_set_property $dash_path LED0 text "0"
dashboard_set_property $dash_path LED0 onClick {toggle_led $dash_path 0}

##Insert LED 1 Button
dashboard_add $dash_path LED1 button buttons
dashboard_set_property $dash_path LED1 text "1"
dashboard_set_property $dash_path LED1 onClick {toggle_led $dash_path 1}

##Insert LED 2 Button
dashboard_add $dash_path LED2 button buttons
dashboard_set_property $dash_path LED2 text "2"
dashboard_set_property $dash_path LED2 onClick {toggle_led $dash_path 2}

##Insert LED 3 Button
dashboard_add $dash_path LED3 button buttons
dashboard_set_property $dash_path LED3 text "3"
dashboard_set_property $dash_path LED3 onClick {toggle_led $dash_path 3}


########### DIP SW Group

## Buttons Groups
dashboard_add $dash_path leds group all
dashboard_set_property $dash_path leds title "Dip Switch Settings"
dashboard_set_property $dash_path leds itemsPerRow 5

dashboard_add $dash_path DS0 led leds
dashboard_set_property $dash_path DS0 text "1"
dashboard_set_property $dash_path DS0 color green

dashboard_add $dash_path DS1 led leds
dashboard_set_property $dash_path DS1 text "2"
dashboard_set_property $dash_path DS1 color green

dashboard_add $dash_path DS2 led leds
dashboard_set_property $dash_path DS2 text "3"
dashboard_set_property $dash_path DS2 color green

dashboard_add $dash_path DS3 led leds
dashboard_set_property $dash_path DS3 text "4"
dashboard_set_property $dash_path DS3 color green


##Insert update Button
dashboard_add $dash_path UPDATE button leds
dashboard_set_property $dash_path UPDATE text "UPDATE"
dashboard_set_property $dash_path UPDATE onClick {update_sw $dash_path } 

## Locate and open necessary paths
set master_path [lindex [get_service_paths master] 1]
open_service master $master_path

## Locate and open necessary paths
set monitor_path [get_service_paths monitor]
set master_path [lindex [get_service_paths master] 1]
open_service monitor $monitor_path

## Define Monitor Service Properties
monitor_add_range $monitor_path $master_path 0x10080 1
monitor_set_interval $monitor_path 3000
monitor_set_callback $monitor_path [list monitor_proc $dash_path $monitor_path $master_path]

#Activate the monitor service
monitor_set_enabled $monitor_path 1

## Callback Procedure
proc monitor_proc {dash_path mon_path mstr_path} {

set sw_data [monitor_read_data $mon_path $mstr_path 0x10080 1]

puts “Data at Address 0x10080: $sw_data”

	if { [expr {$sw_data & 1}] == 1 } {
      dashboard_set_property $dash_path DS0 color red 
		}
	if { [expr {$sw_data & 1}] == 0 } {
      dashboard_set_property $dash_path DS0 color green 
		}


	if { [expr {$sw_data & 2}] == 2 } {
      dashboard_set_property $dash_path DS1 color red 
		}
	if { [expr {$sw_data & 2}] == 0 } {
      dashboard_set_property $dash_path DS1 color green 
		}


	if { [expr {$sw_data & 4}] == 4 } {
      dashboard_set_property $dash_path DS2 color red 
		}
	if { [expr {$sw_data & 4}] == 0 } {
      dashboard_set_property $dash_path DS2 color green 
		}

	if { [expr {$sw_data & 8}] == 8 } {
      dashboard_set_property $dash_path DS3 color red 
		}
	if { [expr {$sw_data & 8}] == 0 } {
      dashboard_set_property $dash_path DS3 color green 
		}
	
}


## Callback Procedure
proc update_sw {dash_path} {

set master_path [lindex [get_service_paths master] 1]

open_service master $master_path
  
set sw_data [master_read_8 $master_path 0x10080 1]
#puts "Data : $sw_data"
		  

	if { [expr {$sw_data & 1}] == 1 } {
      dashboard_set_property $dash_path DS0 color red 
		}
	if { [expr {$sw_data & 1}] == 0 } {
      dashboard_set_property $dash_path DS0 color green 
		}


	if { [expr {$sw_data & 2}] == 2 } {
      dashboard_set_property $dash_path DS1 color red 
		}
	if { [expr {$sw_data & 2}] == 0 } {
      dashboard_set_property $dash_path DS1 color green 
		}


	if { [expr {$sw_data & 4}] == 4 } {
      dashboard_set_property $dash_path DS2 color red 
		}
	if { [expr {$sw_data & 4}] == 0 } {
      dashboard_set_property $dash_path DS2 color green 
		}


	if { [expr {$sw_data & 8}] == 8 } {
      dashboard_set_property $dash_path DS3 color red 
		}
	if { [expr {$sw_data & 8}] == 0 } {
      dashboard_set_property $dash_path DS3 color green 
		}
		
	close_service master $master_path
		
}

########### Pushu SW Group

## Buttons Groups
dashboard_add $dash_path push_leds group all
dashboard_set_property $dash_path push_leds title "Push Switch Settings"
dashboard_set_property $dash_path push_leds itemsPerRow 5

dashboard_add $dash_path PS0 led push_leds
dashboard_set_property $dash_path PS0 text "0"
dashboard_set_property $dash_path PS0 color green

dashboard_add $dash_path PS1 led push_leds
dashboard_set_property $dash_path PS1 text "1"
dashboard_set_property $dash_path PS1 color green

dashboard_add $dash_path PS2 led push_leds
dashboard_set_property $dash_path PS2 text "2"
dashboard_set_property $dash_path PS2 color green


##Insert update Button
dashboard_add $dash_path UPDATE button push_leds
dashboard_set_property $dash_path UPDATE text "UPDATE"
dashboard_set_property $dash_path UPDATE onClick {update_push_sw $dash_path } 


## Locate and open necessary paths
set master_path [lindex [get_service_paths master] 1]
open_service master $master_path

## Locate and open necessary paths
set push_sw_monitor_path [get_service_paths monitor]
set master_path [lindex [get_service_paths master] 1]
open_service monitor $push_sw_monitor_path

## Define Monitor Service Properties
monitor_add_range $push_sw_monitor_path $master_path 0x100C0 1
monitor_set_interval $push_sw_monitor_path 3000
monitor_set_callback $push_sw_monitor_path [list push_sw_monitor_proc $dash_path $push_sw_monitor_path $master_path]

#Activate the monitor service
monitor_set_enabled $push_sw_monitor_path 1

## Callback Procedure
proc push_sw_monitor_proc {dash_path mon_path mstr_path} {

set push_sw_data [monitor_read_data $mon_path $mstr_path 0x100C0 1]

puts “Data at Address 0x100C0: $push_sw_data

	if { [expr {$push_sw_data & 1}] == 1 } {
      dashboard_set_property $dash_path PS0 color red 
		}
	if { [expr {$push_sw_data & 1}] == 0 } {
      dashboard_set_property $dash_path PS0 color green 
		}


	if { [expr {$push_sw_data & 2}] == 2 } {
      dashboard_set_property $dash_path PS1 color red 
		}
	if { [expr {$push_sw_data & 2}] == 0 } {
      dashboard_set_property $dash_path PS1 color green 
		}


	if { [expr {$push_sw_data & 4}] == 4 } {
      dashboard_set_property $dash_path PS2 color red 
		}
	if { [expr {$push_sw_data & 4}] == 0 } {
      dashboard_set_property $dash_path PS2 color green 
		}
	
}


## Callback Procedure
proc update_push_sw {dash_path} {

set master_path [lindex [get_service_paths master] 1]

open_service master $master_path
  
set push_sw_data [master_read_8 $master_path 0x100C0 1]
#puts "Data : $sw_data"		  

	if { [expr {$push_sw_data & 1}] == 1 } {
      dashboard_set_property $dash_path PS0 color red 
		}
	if { [expr {$push_sw_data & 1}] == 0 } {
      dashboard_set_property $dash_path PS0 color green 
		}


	if { [expr {$push_sw_data & 2}] == 2 } {
      dashboard_set_property $dash_path PS1 color red 
		}
	if { [expr {$push_sw_data & 2}] == 0 } {
      dashboard_set_property $dash_path PS1 color green 
		}


	if { [expr {$push_sw_data & 4}] == 4 } {
      dashboard_set_property $dash_path PS2 color red 
		}
	if { [expr {$push_sw_data & 4}] == 0 } {
      dashboard_set_property $dash_path PS2 color green 
		}

		
	close_service master $master_path
		
}

