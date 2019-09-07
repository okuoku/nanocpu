library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ioc_boot is port (
    rst_n: in std_logic;
    clk: in std_logic;
    -- Bus I/F (host)
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic_vector(7 downto 0);
    addr: out std_logic_vector(6 downto 0);
    wr: out std_logic;
    en: out std_logic;
    csel_ram: out std_logic;
    csel_spi: out std_logic;
    spi_hold: out std_logic;
    -- CPU I/F
    srst_n: out std_logic);
end;

architecture arch_ioc_boot of ioc_boot is
    type type_busturn is (silent, 
                          spi_select,
                          spi_control_read, spi_control_write,
                          spi_data_write, 
                          ram_select, copy);
    signal busturn: type_busturn;
    attribute fsm_encoding : string;
    attribute fsm_encoding of busturn: signal is "compact";

    type type_state is (spi_on,
                        spi_start, spi_select_send, spi_select_wait,
                        command_send, command_wait, 
                        address0_send, address0_wait, 
                        address1_send, address1_wait, 
                        address2_send, address2_wait, 
                        xfer_start, xfer_wait, xfer_write, 
                        xfer_next0, xfer_next1,
                        cpu_activate);
    signal state: type_state;
    attribute fsm_encoding of state: signal is "compact";
    signal ptr: std_logic_vector(6 downto 0);
begin
    process (rst_n, clk)
    begin 
        if(rst_n = '0') then
            ptr <= "0000000";
            state <= spi_on;
            busturn <= silent;
        elsif rising_edge(clk) then
            if state = spi_on then
                state <= spi_start;
                busturn <= spi_select;
            elsif state = spi_start then
                data_out <= "00000100"; -- Chip select 00, Enable
                state <= spi_select_send;
                busturn <= spi_control_write;
            elsif state = spi_select_send then
                state <= spi_select_wait;
                busturn <= silent;
            elsif state = spi_select_wait then
                state <= command_send;
                data_out <= "00000011"; -- Read command ($03)
                busturn <= spi_data_write;
            elsif state = command_send then
                state <= command_wait;
                busturn <= spi_control_read;
            elsif state = command_wait then
                if data_in(0) = '0' then
                    state <= address0_send;
                    data_out <= "00000000"; -- Address 0 (0)
                    busturn <= spi_data_write;
                end if;
            elsif state = address0_send then
                state <= address0_wait;
                busturn <= spi_control_read;
            elsif state = address0_wait then
                if data_in(0) = '0' then
                    state <= address1_send;
                    data_out <= "00000000"; -- Address 0 (0)
                    busturn <= spi_data_write;
                end if;
            elsif state = address1_send then
                state <= address1_wait;
                busturn <= spi_control_read;
            elsif state = address1_wait then
                if data_in(0) = '0' then
                    state <= address2_send;
                    data_out <= "00000000"; -- Address 0 (0)
                    busturn <= spi_data_write;
                end if;
            elsif state = address2_send then
                state <= address2_wait;
                busturn <= spi_control_read;
            elsif state = address2_wait then
                if data_in(0) = '0' then
                    state <= xfer_start;
                    data_out <= "00000000"; -- Address 0 (0)
                    busturn <= spi_data_write;
                end if;
            elsif state = xfer_start then
                state <= xfer_wait;
                busturn <= spi_control_read;
            elsif state = xfer_wait then
                if data_in(0) = '0' then
                    state <= xfer_write;
                    busturn <= ram_select;
                end if;
            elsif state = xfer_write then
                state <= xfer_next0;
                busturn <= copy;
            elsif state = xfer_next0 then
                if ptr = "1111111" then
                    state <= cpu_activate;
                else
                    state <= xfer_next1;
                end if;
                ptr <= std_logic_vector(unsigned(ptr) + 1);
                busturn <= silent;
            elsif state = xfer_next1 then
                data_out <= "00000000"; -- Dummy data
                state <= xfer_start;
                busturn <= spi_data_write;
            elsif state = cpu_activate then
                busturn <= silent;
            end if;
        end if;
    end process;

    addr <= "0000000" when busturn = spi_data_write else
            "0000001" when busturn = spi_control_read or 
                           busturn = spi_control_write else
            ptr       when busturn = copy else
            "0000000";


    spi_hold <= '1' when busturn = copy else '0';
    csel_ram <= '1' when busturn = copy or busturn = ram_select else '0';
    csel_spi <= '1' when busturn = spi_select or busturn = spi_control_read
                  or busturn = spi_control_write or busturn = spi_data_write
                  else '0';
    wr <= '1' when busturn = spi_control_write or
                   busturn = spi_data_write or
                   busturn = copy else '0';
    en <= '1' when busturn = spi_control_read else '0';

    srst_n <= '1' when state = cpu_activate else '0';

end arch_ioc_boot;
