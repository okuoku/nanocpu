library ieee;
use ieee.std_logic_1164.all;

entity ghdl_basic0 is
end ghdl_basic0;

architecture arch of ghdl_basic0 is
    signal clk: std_logic;
    signal rst_n: std_logic;
    signal success: std_logic;
    signal fail: std_logic;

    constant clk_period: time := 10 ns;

begin
    C: entity work.test_chip_plain_basic0
    port map(
        clk => clk,
        rst_n => rst_n,
        success => success,
        fail => fail);

    resetlogic: process
    begin
        rst_n <= '0';
        wait for clk_period;
        rst_n <= '1';
        wait;
    end process;

    clocking: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
end arch;

