library ieee;
use ieee.std_logic_1164.all;

entity test_chip_boot is
    port(clk: in std_logic;
         rst_n: in std_logic;
         success: out std_logic;
         fail: out std_logic);
end;

architecture arch_test_chip_boot of test_chip_boot is
    -- CPU
    signal cpu_addr: std_logic_vector(19 downto 0);
    signal cpu_data_in: std_logic_vector(7 downto 0);
    signal cpu_data_out: std_logic_vector(7 downto 0);
    signal cpu_wr: std_logic;
    signal cpu_csel: std_logic_vector(2 downto 0);

    -- SPI
    signal ss_n: std_logic_vector(3 downto 0);
    signal int_n: std_logic_vector(3 downto 0);
    signal sclk: std_logic;
    signal miso: std_logic;
    signal mosi: std_logic;

    -- RAM
    signal ram_addr: std_logic_vector(12 downto 0);
    signal ram_data_out: std_logic_vector(7 downto 0);
    signal ram_wr: std_logic;

    -- DA
    signal da_addr: std_logic_vector(11 downto 0);
    signal da_wr: std_logic;


    -- Bootrom
    signal rom_ss_n: std_logic;
begin
    -- MUX
    rom_ss_n <= ss_n(0);
    int_n <= (others => '1');

    da_wr <= '1' when cpu_wr = '1' and cpu_csel(2) = '1' else '0';
    da_addr <= cpu_addr(11 downto 0);

    ram_wr <= '1' when cpu_wr = '1' and cpu_csel(0) = '1' else '0';
    ram_addr <= cpu_addr(12 downto 0);

    cpu_data_in <= ram_data_out when cpu_csel(0) = '1' else
                   (others => '0');

    C: entity work.chip_single
    port map(
        clk => clk,
        clk_spi => clk,
        rst_n => rst_n,

        wr => cpu_wr,
        data_in => cpu_data_in,
        data_out => cpu_data_out,
        addr => cpu_addr,
        csel => cpu_csel,

        ss_n => ss_n,
        int_n => int_n,
        sclk => sclk,
        miso => miso,
        mosi => mosi);

    DA: entity work.test_da
    port map(
        pclk => clk,
        rst_n => rst_n,
        success => success,
        fail => fail,

        addr => da_addr,
        data_in => cpu_data_out,
        wr => da_wr);

    RAM: entity work.mem_ram8k
    port map(
        clk => clk,

        addr => ram_addr,
        data_in => cpu_data_out,
        data_out => ram_data_out,
        wr => ram_wr);

    BOOTROM: entity work.spi_rom4k_spiloader
    port map(
        clk => clk,

        ss_n => rom_ss_n,
        sclk => sclk,
        miso => miso,
        mosi => mosi);

end arch_test_chip_boot;
