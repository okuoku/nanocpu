library ieee;
use ieee.std_logic_1164.all;

entity ioc_root is port (
    rst: std_logic;
    -- SRAM I/F
    data: inout std_logic_vector(7 downto 0);
    address: inout std_logic_vector(6 downto 0);
    we: in std_logic;
    xwe: out std_logic; -- Gated we
    -- Memory bank controller
    rgn: in std_logic_vector(1 downto 0);
    bank: out std_logic_vector(4 downto 0);
    csel: out std_logic_vector(3 downto 0);
    -- CPU bootstrapper
    clk: in std_logic;
    xoe: out std_logic; -- oe to SPI
    spi_hold: out std_logic;
    srst: out std_logic);
end;

architecture arch_ioc_root of ioc_root is
    signal mbc_bank: std_logic_vector(5 downto 0);
    signal mbc_data: std_logic_vector(7 downto 0);
    signal mbc_we: std_logic;
    signal mbc_csel: std_logic_vector(3 downto 0);

    signal boot_address: std_logic_vector(6 downto 0);
    signal boot_data: std_logic_vector(7 downto 0);
    signal boot_we: std_logic;
    signal boot_oe: std_logic;
    signal boot_srst: std_logic;
    signal boot_csel_ram: std_logic;
    signal boot_csel_spi: std_logic;
    signal boot_spi_hold: std_logic;
begin

    MBC: entity work.ioc_mbc
    port map (
        rst => rst,
        data_in => data,
        address => address(2 downto 0),
        we_in => we,
        we_out => mbc_we,
        rgn => rgn,
        bank => mbc_bank,
        csel => mbc_csel);

    BOOT: entity work.ioc_boot
    port map(
        rst => rst,
        clk => clk,
        data_in => data,
        data_out => boot_data,
        address => boot_address,
        we => boot_we,
        oe => boot_oe,
        csel_ram => boot_csel_ram,
        csel_spi => boot_csel_spi,
        spi_hold => boot_spi_hold,
        srst => boot_srst);


    -- MUX
    csel(0) <= mbc_csel(0) when boot_srst = '1' else boot_csel_ram;
    csel(1) <= mbc_csel(1);
    csel(2) <= mbc_csel(2) when boot_srst = '1' else boot_csel_spi;
    csel(3) <= mbc_csel(3);

    bank <= mbc_bank(4 downto 0);

    data <= (others => 'Z') when boot_srst = '1' or boot_oe = '0' 
            or boot_spi_hold = '0' else
            boot_data;
    address <= (others => 'Z') when boot_srst = '1' else boot_address;
    xoe <= 'Z' when boot_srst = '1' else boot_oe;
    xwe <= mbc_we when boot_srst = '1' else boot_we;

    spi_hold <= boot_spi_hold;

end arch_ioc_root;
