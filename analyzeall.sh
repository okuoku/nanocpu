#!/bin/sh
cc -shared -O3 -g -o busemu.so busemu/busemu_main.c
/opt/ghdl/bin/ghdl -a nanocpu.vhd
/opt/ghdl/bin/ghdl -a ghdl_emuif.vhd
/opt/ghdl/bin/ghdl -a ghdl_top.vhd
