library ieee;
use ieee.std_logic_1164.all;

entity cpu_root is port (
    rst: in std_logic;
    clk: in std_logic;
    
    data: inout std_logic_vector(7 downto 0);
    address: out std_logic_vector(13 downto 0);
    oe: out std_logic;
    we: out std_logic);
end;

architecture arch_cpu_root of cpu_root is
    signal cpu_en: std_logic;
    signal cpu_data: std_logic_vector(7 downto 0);
begin
    CPU: entity work.nanocpu
    port map(
        clk => clk,
        rst => rst,

        data_in => data,
        data_out => cpu_data,
        en => cpu_en,
        address => address,
        oe => oe,
        we => we);

    data <= cpu_data when rst = '1' and cpu_en = '0' else "ZZZZZZZZ";

end arch_cpu_root;
