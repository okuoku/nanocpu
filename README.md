nanocpu
=======

Article(Japanese): https://qiita.com/okuoku/items/3dd2da20f46c2e63286f

nanocpu is a minimal 8Bit CPU that fits in 64 macrocell CPLD.
It is based on MCPU ( https://github.com/cpldcpu/MCPU/ ) but extended with:

 - 14 bits address bus
 - 8 bits segment register for program and data
 - 1 interrupt pin for "pseudo" interrupt
 - fixed "scratchpad" segment for data
 - fixed "initialize" and "interrupt handler" segment for program
 - 4 additional opcodes to control these extensions
   - `LPS` - Load Program Segment - Load ACC to Program Segment register
   - `LDS` - Load Data Segment - Load ACC to Data Segment register
   - `SWS` - SWitch to Scratchpad - Switch data access to scratchpad area
   - `SWD` - SWitch to Data - Switch data access to data area

Original MCPU opcodes ( `ADD` , `NOR` , `STA` and `JCC` ) are retained but
`JCC(60)` to `JCC(63)` are used to provide 4 additional opcodes so
code flow is rather restricted.


