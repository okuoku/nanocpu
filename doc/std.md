NanoCPU SoC Standards
=====================

Address notation
----------------

Although nanocpu has 14bits address space, standard MBC(Memory Bank Controller)
treats it as 2+12 bits (Region number + offset). For convenience, CPU address
will be noted as `1:234` format; region and offset are separated with `:` .

Configurations
--------------

`plain` is test-only 4KiB ROM + 8 KiB RAM configuration. 

`system` is general-purpose N KiB RAM + SPI bootstrap + SPI RAM configuration.

Memory Map
==========

Chip IDs
========

MBC Chip ID
-----------

"Preferred" chip IDs are defined as below;

|ID|Target|
|:--|:----|
|0|RAM|
|1|AUX0|
|2|AUX1|
|3|SPI|

SPI Chip ID
-----------

Bootstrapper (`boot`) assumes Chip `0` is bootstrap SPI flash.

"Preferred" chip IDs are defined as below;

|ID|Target|
|:--|:----|
|0|Bootstrap firmware(Flash)|
|1|RAM|

