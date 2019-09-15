
Instructions
============

Core instruction
----------------

- NOR (0 + ADDR)
- ADD (64 + ADDR)
- STA (128 + ADDR)
- JCC (192 + ADDR)

Special instruction
-------------------

- SWD (252)
- SWS (253)
- LDS (254)
- LPS (255)

Constants
=========

Base constant locations
-----------------------

```
CONSTANT VALUE ADDRESS
-------- ----- -------
kZERO        0
kONE         1
kTWO         2
kTHREE       3
kFOUR        4
kALLONE    255
```

Base constants are always-accessible constant values that reside in
scratchpad space. 

Assembler directives
--------------------

```
___
_ORG <VAL>
_DEF <LABEL> <VAL>
_IMM <VAL>
```

Combinations
============

Arithmetic
----------

```
LD 0 = NOR kAllOne // Load zero
NOT = NOR kZero    // NOT acc
SUB X = NOR kZero ; ADD X ; ADD kOne    // Subtract
```

Jump
----

```
JMP P = JCC P ; JCC P
JZ P = ADD kAllOne ; JCC P
```

Jump tables can be implemented with `ADD` + `JCC` sequence such as:

```
;; Length = 2 [0, otherwise]
ADD kAllOne ; JCC P_zero ; (P_otherwise continues)

;; Length = 3 [0, 1, otherwise]
ADD kAllOne ; JCC P_0 ; ADD kAllOne ; JCC P_1 ; (P_otherwise continues)
```

