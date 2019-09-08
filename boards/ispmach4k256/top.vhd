library ieee;
use ieee.std_logic_1164.all;

entity top is port (
    clk: in std_logic;
    reset_button: in std_logic;

    oe_n: out std_logic;
    we_n: out std_logic;
    sram_ce_n: out std_logic;
    aux0_ce_n: out std_logic;
    aux1_ce_n: out std_logic;
    addr: out std_logic_vector(19 downto 0);
    data: inout std_logic_vector(7 downto 0);

    spi_ss_n: out std_logic_vector(3 downto 0);
    spi_int_n: in std_logic_vector(3 downto 0);
    sclk: out std_logic_vector(3 downto 0);
    miso: in std_logic_vector(3 downto 0);
    mosi: out std_logic_vector(3 downto 0));
end;

architecture rtl of top is
    signal rst_n: std_logic;

    signal sclk_one: std_logic;
    signal miso_one: std_logic;
    signal mosi_one: std_logic;

    signal data_in: std_logic_vector(7 downto 0);
    signal data_out: std_logic_vector(7 downto 0);
    signal data_en: std_logic;

    signal ss_n: std_logic_vector(3 downto 0);
begin

    sclk(0) <= sclk_one;
    sclk(1) <= sclk_one;
    sclk(2) <= sclk_one;
    sclk(3) <= sclk_one;

    mosi(0) <= mosi_one;
    mosi(1) <= mosi_one;
    mosi(2) <= mosi_one;
    mosi(3) <= mosi_one;

    miso_one <= (miso(0) AND (NOT ss_n(0))) OR
                (miso(1) AND (NOT ss_n(1))) OR
                (miso(2) AND (NOT ss_n(2))) OR
                (miso(3) AND (NOT ss_n(3)));
    spi_ss_n <= ss_n;

    rst_n <= NOT reset_button;

    data <= data_out when data_en = '1' else (others => 'Z');
    data_in <= data;

    CHIP: entity work.chip_asram
    port map(
        clk => clk,
        clk_spi => clk,
        rst_n => rst_n,
        oe_n => oe_n,
        we_n => we_n,
        sram_ce_n => sram_ce_n,
        aux0_ce_n => aux0_ce_n,
        aux1_ce_n => aux1_ce_n,
        data_in => data_in,
        data_out => data_out,
        data_en => data_en,
        addr => addr,

        spi_ss_n => ss_n,
        spi_int_n => spi_int_n,
        sclk => sclk_one,
        miso => miso_one,
        mosi => mosi_one);

end rtl;
