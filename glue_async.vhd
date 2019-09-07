-- Asynchronous bus glue

library ieee;
use ieee.std_logic_1164.all;

entity glue_async is port(
    clk: in std_logic;
    rst_n: in std_logic;
    en: in std_logic;
    wr: in std_logic;
    oe_n: out std_logic;
    we_n: out std_logic);
end;

architecture arch_glue_async of glue_async is
begin
    we_n <= '0' when clk = '0' and wr = '1' and rst_n = '1' else '1';
    oe_n <= '0' when en = '1' and rst_n = '1' else '1';
end arch_glue_async;

