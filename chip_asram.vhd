-- Single chip w/ Async external SRAM I/F

library ieee;
use ieee.std_logic_1164.all;

entity chip_asram is port(
    clk: in std_logic;
    clk_spi: in std_logic;
    rst_n: in std_logic;
    -- SRAM I/F
    oe_n: out std_logic;
    we_n: out std_logic;
    sram_ce_n: out std_logic;
    aux0_ce_n: out std_logic;
    aux1_ce_n: out std_logic;
    addr: out std_logic_vector(19 downto 0);
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic_vector(7 downto 0);
    data_en: out std_logic;
    -- SPI
    spi_ss_n: out std_logic_vector(3 downto 0);
    spi_int_n: in std_logic_vector(3 downto 0);
    sclk: out std_logic;
    miso: in std_logic;
    mosi: out std_logic);
end;

architecture arch_chip_asram of chip_asram is
    signal csel: std_logic_vector(2 downto 0);
    signal wr: std_logic;
    signal en: std_logic;
begin
    
    sram_ce_n <= '0' when csel(0) = '1' else '1';
    aux0_ce_n <= '0' when csel(1) = '1' else '1';
    aux1_ce_n <= '0' when csel(2) = '1' else '1';

    data_en <= wr;

    CHIP: entity work.chip_single
    port map(
        clk => clk,
        clk_spi => clk_spi,
        rst_n => rst_n,
        wr => wr,
        en => en,
        data_in => data_in,
        data_out => data_out,
        addr => addr,
        csel => csel,

        ss_n => spi_ss_n,
        int_n => spi_int_n,
        sclk => sclk,
        miso => miso,
        mosi => mosi);

    GLUE: entity work.glue_async
    port map(
        clk => clk,
        rst_n => rst_n,
        en => en,
        wr => wr,
        oe_n => oe_n,
        we_n => we_n);
end;
    
