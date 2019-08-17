--
-- Test: SPI counter device with reset
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_spi_ctr is port (
    rst_n: in std_logic;
    clk: in std_logic;
    -- SPI
    ss_n: in std_logic;
    sclk: in std_logic;
    miso: out std_logic;
    mosi: in std_logic);
end;

    
architecture arch_test_spi_ctr of test_spi_ctr is
    signal the_counter: std_logic_vector(7 downto 0);
    signal spi_ss_n: std_logic;
    signal spi_in_rdy: std_logic;
    signal spi_out_rdy: std_logic;
begin
    SR: entity work.spi_sr
    port map(
        clk => clk,
        ss => spi_ss_n,
        si => mosi,
        so => miso,
        data_in => the_counter,
        data_in_rdy => spi_in_rdy,
        data_out_rdy => spi_out_rdy);


    process(rst_n, clk)
    begin
        if rst_n = '0' then
            the_counter <= (others => '0');
        elsif rising_edge(clk) then
            if spi_out_rdy = '1' then
                the_counter <= std_logic_vector(unsigned(the_counter) + 1);
            end if;
        end if;
    end process;
    spi_in_rdy <= '1';
    spi_ss_n <= '1' when rst_n = '0' else ss_n;
end arch_test_spi_ctr;

