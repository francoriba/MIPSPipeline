## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports i_clk]

## 100
##create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports i_clk]
## 65
##create_clock -add -name sys_clk_pin -period 15.3846 -waveform {0 7.6923} [get_ports i_clk]

## 64
##create_clock -add -name sys_clk_pin -period 15.6250 -waveform {0 7.8125} [get_ports i_clk]

##67
 create_clock -add -name sys_clk_pin -period 14.9254 -waveform {0 7.4627} [get_ports i_clk]

## 70
##create_clock -add -name sys_clk_pin -period 14.2857 -waveform {0 7.14285} [get_ports i_clk]
## 90
#create_clock -add -name sys_clk_pin -period 11.1111 -waveform {0 5.55555} [get_ports i_clk]

##Buttons
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports i_reset]

##USB-RS232 Interface
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports i_rx]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports o_tx]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]