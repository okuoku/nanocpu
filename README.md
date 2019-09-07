nanocpu
=======

Article(Japanese): https://qiita.com/okuoku/items/3dd2da20f46c2e63286f

nanocpu is a minimal 8Bit CPU that fits in 64 macrocell Coolrunner II CPLD.
It is based on MCPU ( https://github.com/cpldcpu/MCPU/ ) but extended with:

 - 14 bits address bus
 - 8 bits page registers for program and data
 - fixed "scratchpad" page for data
 - fixed "reset handler" page for program and data
 - 4 additional opcodes to control these extensions
   - `LCP` - Load Code Page - Load ACC to code page register
   - `LDP` - Load Data page register - Load ACC to data page register
   - `SWS` - SWitch to Scratchpad - Switch data access to scratchpad area
   - `SWD` - SWitch to Data - Switch data access to data area

Original MCPU opcodes ( `ADD` , `NOR` , `STA` and `JCC` ) are retained but
`JCC(60)` to `JCC(63)` are used to provide 4 additional opcodes so
code flow is restricted a bit.

CPU
===

Registers
---------

|Register|Width|Use|
|:-------|:---:|:---|
|ACC|8 bit|ACCumulator|
|PC|6 bit|Program Counter|
|CP|8 bit|Code Page|
|DP|8 bit|Data Page|
|C|1 bit|Carry flag|

Instructions
------------

Standard OPs: `NOR` `ADD` `STA` `JCC`

Extended OPs: `SWD` `SWS` `LCP` `LDP`

Standard OPs(memory instructions) will take 6bit operand.
Every memory operand will be concatinated with `DP` or scratchpad location.

Extended OPs(control instructions) will take no operand and uses some portions of `JCC` op.
Thus, `JCC` cannot jump to address `60` to `63`.

|code|sym|name|OP|
|:---|:---:|:---|:---|
|00aaaaaa|NOR|NOR|ACC NOR [aaaaaa] => ACC|
|01aaaaaa|ADD|ADD|ACC + [aaaaaa] => ACC,C|
|10aaaaaa|STA|STore Accumulator|ACC => [aaaaaa]|
|11aaaaaa|JCC|Jump if Clear Carry|[aaaaaa] => PC if C = 0, 0 => C|

|code|sym|name|OP|
|:---|:---:|:---|:---|
|JCC(60)|SWD|SWitch to Data space|Use Data Segment for data access|
|JCC(61)|SWS|SWitch to Scratch space|Use Scratchpad Segment for data access|
|JCC(62)|LDP|Load to Data Page|ACC => DP|
|JCC(63)|LCP|Load to Code Page|ACC => CP|

Special segments
----------------

|name|type|location|content|
|:---|:---|:-------|:------|
|Scratchpad|data|`00000000`|Scratch data location can be accessed using `SWS` instruction|
|Reset handler|program|`10000000`|Reset handler code and data|

