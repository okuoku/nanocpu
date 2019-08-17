library ieee;
use ieee.std_logic_1164.all;

entity test_iocboot is
end test_iocboot;

architecture arch of test_iocboot is
    signal clk: std_logic;
    signal rst_n: std_logic;
    signal miso: std_logic;
    signal mosi: std_logic;
    signal ss_n: std_logic;
    signal sclk: std_logic;

    signal address: std_logic_vector(6 downto 0);
    signal data: std_logic_vector(7 downto 0);
    signal boot_we_n: std_logic;
    signal boot_oe_n: std_logic;
    signal boot_csel_ram_n: std_logic;
    signal boot_csel_spi_n: std_logic;
    signal boot_data_out: std_logic_vector(7 downto 0);
    signal boot_spi_hold_n: std_logic;
    signal boot_srst: std_logic;

    signal spi_ss_n: std_logic_vector(3 downto 0);
    signal spi_address: std_logic_vector(1 downto 0);
    signal spi_data_out: std_logic_vector(7 downto 0);
    signal spi_int_n: std_logic_vector(3 downto 0);
    signal spi_we_n: std_logic;

    signal ram_address: std_logic_vector(17 downto 0);
    signal ram_data: std_logic_vector(7 downto 0);

    -- clock speed
    constant clk_period: time := 10 ns;
begin
    IOCBOOT: entity work.ioc_boot
    port map(
        rst => rst_n,
        clk => clk,
        data_in => data,
        data_out => boot_data_out,
        address => address,
        we => boot_we_n,
        oe => boot_oe_n,
        srst => boot_srst,
        spi_hold => boot_spi_hold_n,
        csel_ram => boot_csel_ram_n,
        csel_spi => boot_csel_spi_n);

    IOCSPI: entity work.ioc_spi
    port map(
        rst => rst_n,
        clk => clk,

        data_in => data,
        data_out => spi_data_out,
        address => spi_address,
        we => spi_we_n,

        int => spi_int_n,

        ss => spi_ss_n,
        sclk => sclk,
        miso => miso,
        mosi => mosi);

    CTR: entity work.test_spi_ctr
    port map(
        rst_n => rst_n,
        clk => clk,

        ss_n => ss_n,
        sclk => sclk,
        miso => miso,
        mosi => mosi);

    RAM: entity work.test_aram
    port map(
        address => ram_address,
        data => ram_data,
        we_n => boot_we_n,
        oe_n => boot_oe_n,
        csel_n => boot_csel_ram_n);

    ram_address(6 downto 0) <= address;
    ram_address(17 downto 7) <= (others => '0');
    ram_data <= data;


    -- MUX
    data <= boot_data_out when boot_csel_ram_n = '1' and boot_csel_spi_n = '1'
            else
            spi_data_out when boot_csel_spi_n = '0' and boot_oe_n = '0' else
            spi_data_out when boot_spi_hold_n = '0' else
            boot_data_out;

    spi_address <= "00" when boot_spi_hold_n = '0' else
                   address(1 downto 0);

    spi_int_n <= (others => '1');

    ss_n <= spi_ss_n(0);

    -- FIXME: Perhaps ioc_spi should have chip enable
    spi_we_n <= '0' when boot_csel_spi_n = '0' and boot_we_n = '0' else '1';

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
