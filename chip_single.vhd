-- Single chip

library ieee;
use ieee.std_logic_1164.all;

entity chip_single is port (
    clk: in std_logic;
    clk_spi: in std_logic;
    rst_n: in std_logic;

    -- External Bus I/F
    wr: out std_logic;
    en: out std_logic;
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic_vector(7 downto 0);
    addr: out std_logic_vector(19 downto 0);
    csel: out std_logic_vector(2 downto 0);
    
    -- SPI I/F
    ss_n: out std_logic_vector(3 downto 0);
    int_n: in std_logic_vector(3 downto 0);
    sclk: out std_logic;
    miso: in std_logic;
    mosi: out std_logic);
end;

architecture arch_chip_single of chip_single is
    -- internal
    signal internal_wr: std_logic;
    signal internal_en: std_logic;
    signal internal_csel_spi: std_logic;

    -- CPU
    signal cpu_rst_n: std_logic; -- controlled by BOOT
    signal cpu_addr: std_logic_vector(13 downto 0);
    signal cpu_en: std_logic; -- MUXed with BOOT
    signal cpu_wr: std_logic; -- Filtered with MBC
    signal cpu_data_in: std_logic_vector(7 downto 0);
    signal cpu_data_out: std_logic_vector(7 downto 0);

    -- MBC
    signal mbc_wr:std_logic;
    signal mbc_addr: std_logic_vector(2 downto 0);
    signal mbc_rgn: std_logic_vector(1 downto 0);
    signal mbc_bank: std_logic_vector(5 downto 0);
    signal mbc_csel: std_logic_vector(3 downto 0);

    -- BOOT
    signal boot_wr: std_logic;
    signal boot_en: std_logic;
    signal boot_csel_ram: std_logic;
    signal boot_csel_spi: std_logic;
    signal boot_spi_hold: std_logic;
    signal boot_data_out: std_logic_vector(7 downto 0);
    signal boot_addr: std_logic_vector(6 downto 0);

    -- SPI (Bus)
    signal spi_data_in: std_logic_vector(7 downto 0);
    signal spi_data_out: std_logic_vector(7 downto 0);
    signal spi_addr: std_logic_vector(1 downto 0);
    signal spi_wr: std_logic;
begin
    -- MUX: wr
    internal_wr <= boot_wr when cpu_rst_n = '0' else mbc_wr;
    wr <= internal_wr when internal_csel_spi = '0' else '0';
    spi_wr <= boot_wr when cpu_rst_n = '0' and boot_csel_spi = '1' else
              mbc_wr when internal_csel_spi = '1' else
              '0';
    -- MUX: en
    internal_en <= boot_en when cpu_rst_n = '0' else cpu_en;
    en <= internal_en when internal_csel_spi = '0' else '0';

    -- MUX: csel
    internal_csel_spi <= boot_csel_spi when cpu_rst_n = '0' else
                         mbc_csel(3);
    csel <= "001" when cpu_rst_n = '0' and boot_csel_ram = '1' else
            "000" when cpu_rst_n = '0' and boot_csel_ram = '0' else 
            mbc_csel(2 downto 0);

    -- MUX: data_in
    spi_data_in <= boot_data_out when cpu_rst_n = '0' else
                   cpu_data_out;
    cpu_data_in <= spi_data_out when internal_csel_spi = '1' else
                   data_in;

    -- MUX: data_out
    data_out <= spi_data_out when boot_spi_hold = '1' else cpu_data_out;

    -- MUX: addr
    addr <= "0000000000000" & boot_addr when cpu_rst_n = '0' else
            "00" & mbc_bank & cpu_addr(11 downto 0); -- FIXME: Adjust width
    mbc_addr <= cpu_addr(2 downto 0);
    spi_addr <= boot_addr(1 downto 0) when cpu_rst_n = '0' and boot_spi_hold = '0' else
                "00" when cpu_rst_n = '0' and boot_spi_hold = '1' else
                cpu_addr(1 downto 0);

    -- MAP: cpu => mbc (direct connection)
    mbc_rgn <= cpu_addr(13 downto 12);

    BOOT: entity work.ioc_boot
    port map(
        rst_n => rst_n,
        clk => clk,
        data_in => spi_data_out,
        data_out => boot_data_out,
        addr => boot_addr,
        wr => boot_wr,
        en => boot_en,
        csel_ram => boot_csel_ram,
        csel_spi => boot_csel_spi,
        spi_hold => boot_spi_hold,
        srst_n => cpu_rst_n);

    CPU: entity work.nanocpu
    port map(
        clk => clk,
        rst_n => cpu_rst_n,
        data_in => cpu_data_in,
        data_out => cpu_data_out,
        addr => cpu_addr,
        en => cpu_en,
        wr => cpu_wr);

    MBC: entity work.ioc_mbc
    port map(
        rst_n => cpu_rst_n,
        pclk => clk,
        wr_in => cpu_wr,
        wr_out => mbc_wr,
        data_in => cpu_data_out,
        addr => mbc_addr,
        rgn => mbc_rgn,
        bank => mbc_bank,
        csel => mbc_csel);

    SPI: entity work.ioc_spi
    port map(
        rst_n => rst_n,
        clk_spi => clk_spi,
        pclk => clk,
        wr => spi_wr,
        data_in => spi_data_in,
        data_out => spi_data_out,
        addr => spi_addr,
        ss_n => ss_n,
        int_n => int_n,
        sclk => sclk,
        miso => miso,
        mosi => mosi);

end arch_chip_single;
