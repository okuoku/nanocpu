library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_ram8k is 
    port ( clk: in std_logic;
           addr: in std_logic_vector(12 downto 0);
           data_in: in std_logic_vector(7 downto 0);
           data_out: out std_logic_vector(7 downto 0);
           wr: in std_logic);
end entity;

architecture arch_mem_ram8k of mem_ram8k is
    type type_mem is array(0 to 8191) of std_logic_vector(7 downto 0);
    signal mem: type_mem;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if wr = '1' then
                mem(to_integer(unsigned(addr))) <= data_in;
            end if;
            data_out <= mem(to_integer(unsigned(addr)));
        end if;
    end process;
end arch_mem_ram8k;
