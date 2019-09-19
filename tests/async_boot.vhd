library ieee;
use ieee.std_logic_1164.all;

entity async_boot is
end;

architecture arch_async_boot of async_boot is
    signal rst_n: std_logic;

    signal clk: std_logic;

    signal oe_n: std_logic;
    signal we_n: std_logic;
    signal sram_ce_n: std_logic;
    signal aux0_ce_n: std_logic;
    signal aux1_ce_n: std_logic;
    signal addr: std_logic_vector(19 downto 0);
    signal data: std_logic_vector(7 downto 0);

    signal spi_ss_n: std_logic_vector(3 downto 0);
    signal spi_int_n: std_logic_vector(3 downto 0);
    signal sclk: std_logic;
    signal miso: std_logic;
    signal mosi: std_logic;

    -- RAM
    signal ram_address: std_logic_vector(16 downto 0);

    -- DA
    signal da_addr: std_logic_vector(11 downto 0);
    signal da_wr: std_logic;
    signal da_pclk: std_logic;

    -- SPI ROM
    signal rom_ss_n: std_logic;

    constant clk_period: time := 50 ns;

begin
    C: entity work.glue_async_chip
    port map(
        clk => clk,
        rst_n => rst_n,

        oe_n => oe_n,
        we_n => we_n,
        sram_ce_n => sram_ce_n,
        aux0_ce_n => aux0_ce_n,
        aux1_ce_n => aux1_ce_n,
        addr => addr,
        data => data,

        spi_ss_n => spi_ss_n,
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
        csel_n => sram_ce_n);
    ram_address <= addr(16 downto 0);

    ROM: entity work.spi_rom4k_spiloader
    port map(
        clk => clk,
        ss_n => rom_ss_n,
        sclk => sclk,
        miso => miso,
        mosi => mosi);
    rom_ss_n <= spi_ss_n(0);

    DA: entity work.test_da
    port map(
        rst_n => rst_n,
        pclk => da_pclk,
        addr => da_addr,
        wr => da_wr,
        data_in => data);
    da_addr <= addr(11 downto 0);
    da_pclk <= '1' when we_n = '0' and clk = '1' and aux1_ce_n = '0' else '0';
    da_wr <= '1' when we_n = '0' else '1';

    resetlogic: process
    begin
        rst_n <= '0';
        wait for clk_period;
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

end arch_async_boot;
