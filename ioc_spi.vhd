-- INCOMPLETE


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ioc_spi is port (
    rst: in std_logic;
    clk: in std_logic;
    -- SRAM I/F
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic_vector(7 downto 0);
    we: in std_logic;
    address: in std_logic_vector(2 downto 0);
    -- SPI
    csel: out std_logic_vector(3 downto 0);
    int: in std_logic_vector(3 downto 0);
    sclk: out std_logic;
    si: in std_logic;
    so: out std_logic);
end;

architecture arch_ioc_spi of ioc_spi is
    signal dir: std_logic;
    signal cur: std_logic_vector(1 downto 0);
    signal reg: std_logic_vector(7 downto 0);
    signal buf: std_logic_vector(7 downto 0);
    signal buf_addr: std_logic_vector(2 downto 0);

    signal target: std_logic_vector(3 downto 0);
    -- FIXME: FSM did not infered with this...
    -- type type_state is (s0,s1,s2,s3,s4,s5,s6,s7,empty);
    -- signal state: type_state;
    signal state: std_logic_vector(3 downto 0);
    signal write_active: std_logic;
    signal read_active: std_logic;
    signal serial_active: std_logic;
    signal serial_select: std_logic;

    signal reg_cntl: std_logic_vector(7 downto 0);
    signal reg_intr: std_logic_vector(7 downto 0);
    signal intr_active: std_logic;
    signal intr_status: std_logic_vector(3 downto 0);
begin
    SR: process(clk, rst)
    begin
        if (rst = '0') then
            reg <= (others => '0');
            write_active <= '0';
            read_active <= '0';
            state <= "1001";
            serial_select <= '0';
            
        elsif rising_edge(clk) then
            if state = "0000" then
                state <= "0001";
                reg <= reg(6 downto 0) & si;
            elsif state = "0001" then
                state <= "0010";
                reg <= reg(6 downto 0) & si;
            elsif state = "0010" then
                state <= "0011";
                reg <= reg(6 downto 0) & si;
            elsif state = "0011" then
                state <= "0100";
                reg <= reg(6 downto 0) & si;
            elsif state = "0100" then
                state <= "0101";
                reg <= reg(6 downto 0) & si;
            elsif state = "0101" then
                state <= "0110";
                reg <= reg(6 downto 0) & si;
            elsif state = "0110" then
                state <= "0111";
                reg <= reg(6 downto 0) & si;
            elsif state = "0111" then
                state <= "1000";
                reg <= reg(6 downto 0) & si;
            elsif state = "1000" then
                state <= "1001";
                read_active <= '0';
                write_active <= '0';
            elsif serial_active = '1' then
                state <= "0000";
            else 
                -- Bus I/F
                if buf_addr = "010" then
                    intr_status <= intr_status nor buf(3 downto 0);
                elsif buf_addr = "011" then
                    serial_select <= buf(3);
                    dir <= buf(2);
                    cur <= buf(1 downto 0);
                elsif serial_active = '0' and buf_addr = "000" then
                    if dir = '0' then
                        read_active <= '1';
                    else
                        write_active <= '1';
                    end if;
                    reg <= buf(7 downto 0);
                end if;
            end if;

        end if;
    end process;

    BUSIF: process(rst,we)
    begin
        if rst = '0' then
            buf_addr <= "111";
        elsif falling_edge(we) then
           -- register write
            buf_addr <= address;
            buf <= data_in;
        end if;
    end process;

    -- Register interface
    reg_cntl <= "00000" & serial_select & serial_active & intr_active;
    reg_intr <= "0000" & intr_status;
    intr_active <= '0' when intr_status = "0000" else '1';

    data_out <= reg_cntl when address = "001" else
                reg_intr when address = "010" else
                reg;

    -- Serial interface
    so <= reg(7) when write_active = '1' else 'Z';
    serial_active <= '1' when read_active = '1' or write_active = '1' else '0';
    sclk <= '1' when clk = '0' and serial_active = '1' else '0';
    csel <= "1111" when serial_select = '0' else
            "1110" when cur = "00" else
            "1101" when cur = "01" else
            "1011" when cur = "10" else
            "0111" when cur = "11";
end arch_ioc_spi;
