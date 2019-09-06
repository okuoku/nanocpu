--
-- Test: SPI counter device with reset
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_spi_ctr is port (
    rst_n: in std_logic;
    -- SPI
    ss_n: in std_logic;
    sclk: in std_logic;
    miso: out std_logic;
    mosi: in std_logic);
end;

    
architecture arch_test_spi_ctr of test_spi_ctr is
    signal the_counter: std_logic_vector(7 downto 0);
    signal spi_in_ack: std_logic;
    signal spi_out_rdy: std_logic;
begin
    SR: entity work.spi_dsr
    port map(
        ss_n => ss_n,
        sclk => sclk,
        si => mosi,
        so => miso,
        data_in => the_counter,
        data_in_ack => spi_in_ack,
        data_out_rdy => spi_out_rdy);

    process(rst_n, spi_in_ack)
    begin
        if rst_n = '0' then
            the_counter <= (others => '0');
        elsif falling_edge(spi_in_ack) then
            the_counter <= std_logic_vector(unsigned(the_counter) + 1);
        end if;
    end process;
end arch_test_spi_ctr;

