-- INCOMPLETE 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ioc_boot is port (
    rst: in std_logic;
    clk: in std_logic;
    -- SRAM I/F
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic_vector(7 downto 0);
    address: out std_logic_vector(6 downto 0);
    we: out std_logic;
    oe: out std_logic;
    csel_ram: out std_logic;
    csel_spi: out std_logic;
    spi_hold: out std_logic;
    -- CPU I/F
    srst: out std_logic);
end;

architecture arch_ioc_boot of ioc_boot is
    signal done: std_logic;
    type type_state is (spi_start, spi_select,
                        command_send, command_wait, 
                        address_send, address_wait, 
                        xfer_start, xfer_wait, xfer_write, xfer_next,
                        spi_leave);
    signal state: type_state;
    attribute fsm_encoding : string;
    attribute fsm_encoding of state: signal is "compact";
    signal want_read_control: std_logic;
    signal has_spi_write_data: std_logic;
    signal has_ram_write_data: std_logic;
    signal ptr: std_logic_vector(5 downto 0);
begin
    process (rst, clk)
    begin 
        if(rst = '0') then
            done <= '0';
            ptr <= "000000";
            csel_ram <= '1';
            csel_spi <= '1';
            state <= spi_start;
            spi_hold <= '1';
        elsif rising_edge(clk) then
            if (done = '0') then
                if state = spi_start then
                    data_out <= "11110000"; -- FIXME
                    csel_spi <= '0';
                    state <= spi_select;
                elsif state = spi_select then
                    state <= command_send;
                    data_out <= "10000000"; -- FIXME
                    csel_spi <= '0';
                elsif state = command_send then
                    state <= command_wait;
                elsif state = command_wait then
                    if data_in(1) = '0' then
                        state <= address_send;
                        data_out <= (others => '0');
                    end if;
                elsif state = address_send then
                    state <= address_wait;
                elsif state = address_wait then
                    if data_in(1) = '0' then
                        ptr <= (others => '0');
                        state <= xfer_start;
                    end if;
                elsif state = xfer_start then
                    state <= xfer_wait;
                    spi_hold <= '0';
                elsif state = xfer_wait then
                    state <= xfer_write;
                elsif state = xfer_write then
                    ptr <= std_logic_vector(unsigned(ptr) + 1);
                    state <= xfer_next;
                    csel_ram <= '0';
                    spi_hold <= '0';
                elsif state = xfer_next then
                    if ptr = "111111" then
                        done <= '1';
                    end if;
                    state <= spi_leave;
                    csel_ram <= '1';
                elsif state = spi_leave then
                    -- do nothing
                end if;
            end if;
        end if;
    end process;

    has_spi_write_data <= '1' when
                          state = command_send or
                          state = address_send else
                          '0';

    has_ram_write_data <= '1' when
                          state = xfer_write else
                          '0';

    want_read_control <= '1' when 
                         state = command_wait or
                         state = address_wait or
                         state = xfer_wait else
                         '0';

    we <= '0' when clk = '0' and (has_spi_write_data = '1' or
          has_ram_write_data = '1') else '1';

    address <= '0' & ptr when state = xfer_next else
               "0000010" when state = spi_start else
               "0000001" when want_read_control = '1' else
               (others => '0');

    srst <= '1' when done = '1' else '0';

end arch_ioc_boot;
