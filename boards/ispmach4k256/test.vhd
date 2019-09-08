library ieee;
use ieee.std_logic_1164.all;

entity test_chip is
end test_chip ;

architecture arch of test_chip is
    signal clk: std_logic;
    signal reset_button: std_logic;

    -- SRAM I/F
    signal addr: std_logic_vector(19 downto 0);
    signal data: std_logic_vector(7 downto 0);

    signal oe_n: std_logic;
    signal we_n: std_logic;
    signal ram_address: std_logic_vector(16 downto 0);
    signal ram_ce_n: std_logic;

    -- SPI
    signal miso: std_logic;
    signal mosi: std_logic;
    signal sclk: std_logic;
    signal ss_n: std_logic_vector(3 downto 0);
    signal spi_int_n: std_logic_vector(3 downto 0);
    signal ctr_ss_n: std_logic;

    -- clock speed
    constant clk_period: time := 10 ns;
begin

    CHIP: entity work.top
    port map(
        clk => clk,
        reset_button => reset_button,

        oe_n => oe_n,
        we_n => we_n,
        sram_ce_n => ram_ce_n,
        addr => addr,
        data => data,

        spi_int_n => spi_int_n,
        sclk => sclk,
        miso => miso,
        mosi => mosi);
    spi_int_n <= (others => '1');

    RAM: entity work.test_aram
    port map(
        address => ram_address,
        data => data,
        we_n => we_n,
        oe_n => oe_n,
        csel_n => ram_ce_n);
    ram_address <= addr(16 downto 0) when ram_ce_n = '0';

    SPIROM: entity work.test_spi_ctr
    port map(
        rst_n => rst_n,
        ss_n => ctr_ss_n,
        sclk => sclk,
        mosi => mosi,
        miso => miso);
    ctr_ss_n <= ss_n(0);

    resetlogic: process
    begin
        reset_button <= '1';
        wait for clk_period;
        reset_button <= '0';
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
