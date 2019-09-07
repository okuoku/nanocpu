library ieee;
use ieee.std_logic_1164.all;

entity top is port (
    clk: in std_logic;
    GIO: inout std_logic_vector(37 downto 1);
    JA: inout std_logic_vector(7 downto 0);
    JB: inout std_logic_vector(7 downto 0);
    JC: inout std_logic_vector(7 downto 0);
    JD: inout std_logic_vector(7 downto 0);
    BTN: in std_logic_vector(1 downto 0);
    SW: in std_logic_vector(1 downto 0);
    LD: out std_logic_vector(3 downto 0);
    CAT: out std_logic_vector(7 downto 0);
    ANO: out std_logic_vector(3 downto 0));
end;

architecture rtl of top is
    signal rst_n: std_logic;
    -- Glue
    signal wr: std_logic;
    signal en: std_logic;
    signal oe_n: std_logic;
    signal we_n: std_logic;
    signal csel: std_logic_vector(2 downto 0);
    -- SRAM I/F
    signal sram_ce_n: std_logic;
    signal aux0_ce_n: std_logic;
    signal aux1_ce_n: std_logic;
    signal addr: std_logic_vector(19 downto 0);
    signal data_in: std_logic_vector(7 downto 0);
    signal data_out: std_logic_vector(7 downto 0);
    -- SPI
    signal spi_ss_n: std_Logic_vector(3 downto 0);
    signal spi_int_n: std_logic_vector(3 downto 0);
    signal sclk: std_logic;
    signal miso: std_logic;
    signal mosi: std_logic;
    
    signal si: std_logic_vector(3 downto 0);
begin
    -- Board
    rst_n <= '0' when BTN(0) = '1' else '1';
    
    GIO(8 downto 1) <= data_out when wr = '1' else (others => 'Z');
    data_in <= GIO(8 downto 1);

    GIO(28 downto 9) <= addr;
    sram_ce_n <= '0' when csel(0) = '1' else '1';
    aux0_ce_n <= '0' when csel(1) = '1' else '1';
    aux1_ce_n <= '0' when csel(2) = '1' else '1';
    GIO(33) <= sram_ce_n;
    GIO(34) <= aux0_ce_n;
    GIO(35) <= aux1_ce_n;
    GIO(36) <= we_n;
    GIO(37) <= oe_n;

    miso <= (si(0) AND (NOT spi_ss_n(0))) OR
            (si(1) AND (NOT spi_ss_n(1))) OR
            (si(2) AND (NOT spi_ss_n(2))) OR
            (si(3) AND (NOT spi_ss_n(3)));

    GIO(32 downto 29) <= (others => '0');

    -- Pmod A
    JA(0) <= spi_ss_n(0);  -- Pin 1
    JA(1) <= mosi;         -- Pin 2
    JA(2) <= 'Z';
    si(0) <= JA(2);           -- Pin 3
    JA(3) <= sclk;         -- Pin 4
    JA(4) <= rst_n;        -- Pin 8 (rst_n)
    JA(5) <= 'Z';
    spi_int_n(0) <= JA(5); -- Pin 9 (INT ??)
    JA(6) <= '0';
    JA(7) <= '0';

    -- Pmod B
    JB(0) <= spi_ss_n(1);  -- Pin 1
    JB(1) <= mosi;         -- Pin 2
    JB(2) <= 'Z';
    si(1) <= JB(2);           -- Pin 3
    JB(3) <= sclk;         -- Pin 4
    JB(4) <= rst_n;        -- Pin 8 (rst_n)
    JB(5) <= 'Z';
    spi_int_n(1) <= JB(5); -- Pin 9 (INT ??)
    JB(6) <= '0';
    JB(7) <= '0';

    -- Pmod C
    JC(0) <= spi_ss_n(2);  -- Pin 1
    JC(1) <= mosi;         -- Pin 2
    JC(2) <= 'Z';
    si(2) <= JC(2);           -- Pin 3
    JC(3) <= sclk;         -- Pin 4
    JC(4) <= rst_n;        -- Pin 8 (rst_n)
    JC(5) <= 'Z';
    spi_int_n(2) <= JC(5); -- Pin 9 (INT ??)
    JC(6) <= '0';
    JC(7) <= '0';

    -- Pmod D
    JD(0) <= spi_ss_n(3);  -- Pin 1
    JD(1) <= mosi;         -- Pin 2
    JD(2) <= 'Z';
    si(3) <= JD(2);           -- Pin 3
    JD(3) <= sclk;         -- Pin 4
    JD(4) <= rst_n;        -- Pin 8 (rst_n)
    JD(5) <= 'Z';
    spi_int_n(3) <= JD(5); -- Pin 9 (INT ??)
    JD(6) <= '0';
    JD(7) <= '0';

    LD <= (others => '0');
    CAT <= (others => '0');
    ANO <= (others => '0');

    CHIP: entity work.chip_single
    port map(
        clk => clk,
        clk_spi => clk,
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
end rtl;
