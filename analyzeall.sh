#!/bin/sh
cc -shared -O3 -g -o busemu.so busemu/busemu_main.c
/opt/ghdl/bin/ghdl -a test_aram.vhd
/opt/ghdl/bin/ghdl -a spi_sr.vhd
/opt/ghdl/bin/ghdl -a spi_dsr.vhd
/opt/ghdl/bin/ghdl -a test_spi_ctr.vhd
/opt/ghdl/bin/ghdl -a ioc_boot.vhd
/opt/ghdl/bin/ghdl -a ioc_spi.vhd
/opt/ghdl/bin/ghdl -a tests/test_iocboot.vhd
/opt/ghdl/bin/ghdl -a nanocpu.vhd
/opt/ghdl/bin/ghdl -a ghdl_emuif.vhd
/opt/ghdl/bin/ghdl -a boards/cplds/cpld64_cpu.vhd
/opt/ghdl/bin/ghdl -a ghdl_top.vhd
