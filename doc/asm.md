
Instructions
============

Core instruction
----------------

- NOR
- ADD
- STA
- JCC

Special instruction
-------------------

- SWD
- SWS
- LDP
- LCP

Base constants
--------------

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
_ORG <VAL>
_PAGE
```
