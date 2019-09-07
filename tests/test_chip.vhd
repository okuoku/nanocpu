library ieee;
use ieee.std_logic_1164.all;

entity test_chip is
end test_chip ;

architecture arch of test_chip is
    signal clk: std_logic;
    signal rst_n: std_logic;

    -- SRAM I/F
    signal addr: std_logic_vector(19 downto 0);
    signal data_in: std_logic_vector(7 downto 0);
    signal data_out: std_logic_vector(7 downto 0);
    signal data_en: std_logic;

    signal oe_n: std_logic;
    signal we_n: std_logic;
    signal ram_address: std_logic_vector(16 downto 0);
    signal ram_data: std_logic_vector(7 downto 0);
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

    CHIP: entity work.chip_asram
    port map(
        clk => clk,
        clk_spi => clk,
        rst_n => rst_n,
        data_en => data_en,
        data_in => data_in,
        data_out => data_out,
        addr => addr,
        sram_ce_n => ram_ce_n,
        oe_n => oe_n,
        we_n => we_n,

        spi_int_n => spi_int_n,
        sclk => sclk,
        miso => miso,
        mosi => mosi);
    spi_int_n <= (others => '1');

    RAM: entity work.test_aram
    port map(
        address => ram_address,
        data => ram_data,
        we_n => we_n,
        oe_n => oe_n,
        csel_n => ram_ce_n);
    ram_address <= addr(16 downto 0) when ram_ce_n = '0' else (others => 'Z');
    ram_data <= data_out when data_en = '1' else (others => 'Z');
    data_in <= ram_data when ram_ce_n = '0' else (others => 'Z');

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
