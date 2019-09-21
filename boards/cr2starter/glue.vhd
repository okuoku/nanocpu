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

architecture rtl of glue_async_chip is
    signal GIO: std_logic_vector(37 downto 9);
    signal JA: std_logic_vector(7 downto 0);
    signal JB: std_logic_vector(7 downto 0);
    signal JC: std_logic_vector(7 downto 0);
    signal JD: std_logic_vector(7 downto 0);
    signal BTN: std_logic_vector(0 downto 0); -- Due to optimization

    signal reset_button: std_logic;
begin

    C: entity work.top
    port map(
        clk => clk,
        --GIO => GIO,
        JA => JA,
        JB => JB,
        JC => JC,
        JD => JD,
        BTN => BTN,
        GIO(37 downto 9) => GIO,
        GIO(8 downto 1) => data
    );

    mosi <= JA(1);
    sclk <= JA(3);
    JA(2) <= miso;

    spi_ss_n(0) <= JA(0);
    JA(5) <= spi_int_n(0);
    spi_ss_n(1) <= JB(0);
    JB(5) <= spi_int_n(1);
    spi_ss_n(2) <= JC(0);
    JC(5) <= spi_int_n(2);
    spi_ss_n(3) <= JD(0);
    JD(5) <= spi_int_n(3);

    addr <= GIO(28 downto 9);

    BTN(0) <= reset_button;
    reset_button <= not rst_n;

    sram_ce_n <= GIO(33);
    aux0_ce_n <= GIO(34);
    aux1_ce_n <= GIO(35);
    we_n <= GIO(36);
    oe_n <= GIO(37);

end rtl;
