--
-- Simple SPI 8-to-1 shift register (for Device)
--

library ieee;
use ieee.std_logic_1164.all;

entity spi_dsr is port (
    -- SPI
    sclk: in std_logic;
    si: in std_logic;
    so: out std_logic;
    ss_n: in std_logic;
    -- IF
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic_vector(7 downto 0);
    data_out_rdy: out std_logic;
    data_in_ack: out std_logic);
end spi_dsr;

architecture arch_spi_dsr of spi_dsr is
    signal reg: std_logic_vector(7 downto 0);
    type type_state is (s0,s1,s2,s3,s4,s5,s6,s7);
    signal state: type_state;
    signal buf: std_logic;
    attribute fsm_encoding: string;
    attribute fsm_encoding of state: signal is "compact";
begin
    process (sclk, ss_n)
    begin
        if ss_n = '1' then
            state <= s0;
            reg <= data_in;
        elsif rising_edge(sclk) then
            buf <= si;
        elsif falling_edge(sclk) then
            if state = s0 then
                state <= s1;
                reg <= reg(6 downto 0) & buf;
            elsif state = s1 then
                state <= s2;
                reg <= reg(6 downto 0) & buf;
            elsif state = s2 then
                state <= s3;
                reg <= reg(6 downto 0) & buf;
            elsif state = s3 then
                state <= s4;
                reg <= reg(6 downto 0) & buf;
            elsif state = s4 then
                state <= s5;
                reg <= reg(6 downto 0) & buf;
            elsif state = s5 then
                state <= s6;
                reg <= reg(6 downto 0) & buf;
            elsif state = s6 then
                state <= s7;
                reg <= reg(6 downto 0) & buf;
            elsif state = s7 then
                state <= s0;
                reg <= data_in;
            end if;
        end if;
    end process; 

    so <= reg(7);
    data_in_ack <= '1' when state = s0 else '0';
    data_out_rdy <= '1' when state = s7 and sclk = '1' else '0';
    data_out <= reg(6 downto 0) & buf;

end arch_spi_dsr;
