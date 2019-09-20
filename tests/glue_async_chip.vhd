library ieee;
use ieee.std_logic_1164.all;

entity glue_async_chip is port(
    rst_n: in std_logic;

    clk: in std_logic;

    oe_n: out std_logic;
    we_n: out std_logic;
    sram_ce_n: out std_logic;
    aux0_ce_n: out std_logic;
    aux1_ce_n: out std_logic;
    addr: out std_logic_vector(19 downto 0);
    data: inout std_logic_vector(7 downto 0);

    spi_ss_n: out std_logic_vector(3 downto 0);
    spi_int_n: in std_logic_vector(3 downto 0);
    sclk: out std_logic;
    miso: in std_logic;
    mosi: out std_logic);
end;


architecture arch_glue_async_chip of glue_async_chip is
    signal cpu_data_in: std_logic_vector(7 downto 0);
    signal cpu_data_out: std_logic_vector(7 downto 0);
    signal cpu_data_en: std_logic;
begin
    C: entity work.chip_asram
    port map(
        clk => clk,
        clk_spi => clk,
        rst_n => rst_n,

        oe_n => oe_n,
        we_n => we_n,
        sram_ce_n => sram_ce_n,
        aux0_ce_n => aux0_ce_n,
        aux1_ce_n => aux1_ce_n,
        addr => addr,
        data_in => cpu_data_in,
        data_out => cpu_data_out,
        data_en => cpu_data_en,
        sclk => sclk,
        spi_ss_n => spi_ss_n,
        spi_int_n => spi_int_n,
        miso => miso,
        mosi => mosi);

    -- MUX
    cpu_data_in <= data;
    data <= (others => 'Z') when cpu_data_en = '0' else
            cpu_data_out;

end arch_glue_async_chip;
