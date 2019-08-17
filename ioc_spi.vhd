library ieee;
use ieee.std_logic_1164.all;

entity ioc_spi is port (
    rst: in std_logic;
    clk: in std_logic;
    -- SRAM I/F
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic_vector(7 downto 0);
    we: in std_logic;
    address: in std_logic_vector(1 downto 0);
    -- SPI
    ss: out std_logic_vector(3 downto 0);
    int: in std_logic_vector(3 downto 0);
    sclk: out std_logic;
    miso: in std_logic;
    mosi: out std_logic);
end;

--
-- Registers:
-- (Read)
--  0: Data
--  1: Status
--           A - Activity
--          B  - Data busy
--        00   - Zero (reserved)
--    IIII     - Interrupt status
--
--
-- (Write)
--  0: Data (Write dummy data to read next)
--  1: Configuration port
--         CC - Chip select
--        E   - Enable

architecture arch_ioc_spi of ioc_spi is
    signal toggle_data_bus: std_logic;
    signal toggle_data_sr: std_logic;
    signal toggle_config_bus: std_logic;
    signal toggle_config_sr: std_logic;

    -- SPI
    signal config_ss: std_logic_vector(3 downto 0);

    -- SR
    signal data_busy: std_logic;
    signal active: std_logic;
    signal sr_ss: std_logic;
    signal sr_data_in: std_logic_vector(7 downto 0);
    signal sr_data_in_rdy: std_logic;
    signal sr_data_in_ack: std_logic;
    signal sr_data_out: std_logic_vector(7 downto 0);
    signal sr_data_out_rdy: std_logic;

    -- SRAM I/F
    signal config_enable: std_logic;
    signal config_chip: std_logic_vector(1 downto 0);
    signal wq: std_logic_vector(7 downto 0);
    signal rq: std_logic_vector(7 downto 0);
begin
    SR: entity work.spi_sr
    port map(
        clk => clk,
        ss => sr_ss,
        -- Data
        data_in => sr_data_in,
        data_in_ack => sr_data_in_ack,
        data_in_rdy => sr_data_in_rdy,
        data_out => sr_data_out,
        data_out_rdy => sr_data_out_rdy,

        -- SPI
        sclk => sclk,
        si => miso,
        so => mosi);

    sr_data_in_rdy <= '0' when toggle_data_bus = toggle_data_sr else '1';
    sr_data_in <= wq;

    -- SPI I/F
    process(rst, clk)
    begin
        if rst = '0' then
            toggle_data_sr <= '0';
            toggle_config_sr <= '0';
            config_ss <= "1111";
        elsif rising_edge(clk) then
            -- config > data priority to ensure 1clk for select pulse
            if toggle_config_bus /= toggle_config_sr then
                if config_enable = '0' then
                    config_ss <= "1111";
                else
                    if config_chip = "00" then
                        config_ss <= "1110";
                    elsif config_chip = "01" then
                        config_ss <= "1101";
                    elsif config_chip = "10" then
                        config_ss <= "1011";
                    else
                        config_ss <= "0111";
                    end if;
                    toggle_config_sr <= toggle_config_bus;
                end if;
            elsif toggle_data_bus /= toggle_data_sr then
                if sr_data_in_ack = '1' then
                    toggle_data_sr <= toggle_data_bus;
                end if;
            end if;
            if sr_data_out_rdy = '1' then
                rq <= sr_data_out;
            end if;
        end if;
    end process;

    active <= '1' when sr_data_out_rdy = '0' or
              toggle_data_bus /= toggle_data_sr else '0';
    data_busy <= '0' when toggle_data_bus = toggle_data_sr else '1';
    sr_ss <= '1' when config_ss = "1111" else '0';
    ss <= config_ss;

    -- SRAM Register I/F
    process(rst, we)
    begin
        if rst = '0' then
            toggle_data_bus <= '0';
            toggle_config_bus <= '0';
        elsif falling_edge(we) then
            if address = "00" then
                if toggle_data_bus = '1' then
                    toggle_data_bus <= '0';
                else
                    toggle_data_bus <= '1';
                end if;
                wq <= data_in;
            elsif address = "01" then
                if toggle_config_bus = '1' then
                    toggle_config_bus <= '0';
                else
                    toggle_config_bus <= '1';
                end if;
                config_chip <= data_in(1 downto 0);
                config_enable <= data_in(2);
            end if;
        end if;
    end process;

    data_out <= int & "00" & data_busy & active when address = "01"
                else rq;

end arch_ioc_spi;
