library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ghdl_top is
end ghdl_top;

architecture arch of ghdl_top is
    signal clk: std_logic;
    signal rst: std_logic;
    signal data: std_logic_vector(7 downto 0);
    signal address: std_logic_vector(13 downto 0);
    signal oe: std_logic;
    signal we: std_logic;

    -- Clock speed
    constant clk_period: time := 10 ns;
begin
    -- Components
    CPU: entity work.cpu_root
    port map (
        data => data,
        address => address,
        oe => oe,
        we => we,
        clk => clk,
        rst => rst);

    BUSEMU: entity work.busemu
    port map(
        data => data,
        address => address,
        oe => oe,
        we => we,
        rst => rst);


    -- Reset logic
    resetlogic: process
    begin
        rst <= '0';
        wait for clk_period;
        rst <= '1';
        wait;
    end process;

    -- Clocking
    clocking: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

end arch;
