library ieee;
use ieee.std_logic_1164.all;

entity cpld64_spi is port (
    clk: std_logic;
    rst: std_logic;
    -- SRAM I/F
    data: inout std_logic_vector(7 downto 0);
    address: in std_logic_vector(1 downto 0);
    csel: in std_logic;
    we: in std_logic;
    oe: in std_logic;
    -- SPI
    ss: out std_logic_vector(3 downto 0);
    sclk: out std_logic;
    miso: in std_logic;
    mosi: out std_logic;
    int: in std_logic_vector(3 downto 0);
    -- CPU bootstrapper
    spi_hold: in std_logic);
end;

architecture arch_cpld64_spi of cpld64_spi is
    signal spi_data: std_logic_vector(7 downto 0);
    signal spi_address: std_logic_vector(1 downto 0);

begin
    SPI: entity work.ioc_spi
    port map(
        rst => rst,
        clk => clk,
        -- SRAM I/F,
        data_in => data,
        data_out => spi_data,
        we => we,
        address => spi_address,

        -- SPI
        ss => ss,
        int => int,
        sclk => sclk,
        miso => miso,
        mosi => mosi);

    -- MUX
    spi_address <= "00" when spi_hold = '1' else
                   address;
    data <= spi_data when spi_hold = '1' else
            spi_data when csel = '0' and oe = '0' else
            "ZZZZZZZZ";

end arch_cpld64_spi;
