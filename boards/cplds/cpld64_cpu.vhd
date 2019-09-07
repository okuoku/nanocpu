library ieee;
use ieee.std_logic_1164.all;

entity cpu_root is port (
    clk: in std_logic;
    rst_n: in std_logic;
    
    data: inout std_logic_vector(7 downto 0);
    addr: out std_logic_vector(13 downto 0);
    oe_n: out std_logic;
    we_n: out std_logic);
end;

architecture arch_cpu_root of cpu_root is
    signal cpu_en: std_logic;
    signal cpu_wr: std_logic;
    signal cpu_data_out: std_logic_vector(7 downto 0);
begin
    CPU: entity work.nanocpu
    port map(
        clk => clk,
        rst_n => rst_n,

        data_in => data,
        data_out => cpu_data_out,
        en => cpu_en,
        wr => cpu_wr,
        addr => addr);

    GLUE: entity work.glue_async
    port map(
        clk => clk,
        rst_n => rst_n,
        en => cpu_en,
        wr => cpu_wr,
        oe_n => oe_n,
        we_n => we_n);

    data <= cpu_data_out when cpu_wr = '1' else "ZZZZZZZZ";

end arch_cpu_root;
