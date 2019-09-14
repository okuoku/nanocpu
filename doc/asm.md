
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
- LDP (254)
- LCP (255)

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
_PAGE
```
