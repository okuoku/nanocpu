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

Debug adapter
=============

- `2:002` (Write) Indicate test failure
- `2:003` (Write) Indicate test success

Stdlibs
=======

Calling convention
------------------

copy($01)
---------

```
output:
  r0: (preserve)
  r1: <WORK> Myslice
  r2: <WORK> Pointer
  r3: <WORK> Copy byte
  
input:
  curps: Current PS
  curds: Current DS
  r4: src_base
  r5: src_slic
  r6: dst_base
  r7: dst_slic
  r8: len

copy:
    00: NOR kAllOne
    01: ADD kOne          # My Slice No.
    02: STA r1
    03: NOR kAllOne
    04: STA r2
copy_check:               # ACC = Ptr = r2, SWS
    05: NOR kZero
    06: ADD r8
    07: ADD kOne
    08: JCC copy_nextbyte # Ptr != r8 then nextbyte, copy_nextbyte = 16
copy_end:
    09: NOR kAllOne       # Redundant zero-clear (FIXME)
    10: ADD curds
    11: LDS
    12: NOR kAllOne
    13: ADD curps
    14: SWS               # Redundant SWS (FIXME)
    15: LDP
copy_nextbyte:
    16: NOR kAllOne
    17: ADD r1
    18: LDS
    19: NOR kAllOne
    20: ADD k128          # ADD(128)
    21: ADD r4            # base
    22: ADD r2            # offset
    23: SWD
    24: STA copy_ld       # copy_ld = 38
    25: SWS
    26: NOR kAllOne
    27: ADD k64
    28: ADD r6
    29: ADD r2
    30: SWD
    31: STA copy_sta      # copy_sta = 47
    32: SWS
    33: NOR kAllOne
    34: ADD r5
    35: LDS
    36: NOR kAllOne
    37: SWD
copy_ld:
    38: ADD 0             # <MODIFIED> LD
    39: SWS
    40: STA r3
    41: NOR kAllOne
    42: ADD r7
    43: LDS
    44: NOR kAllOne
    45: ADD r3
    46: SWD
copy_sta:
    47: STA 0             # <MODIFIED> STA
    48: SWS
    49: NOR kAllOne
    50: ADD r2
    51: ADD kOne
    52: STA r2            # r2++
    53: JCC copy_check    # copy_check = 05
```
