--
-- Simple SPI 8-to-1 shift register
--

library ieee;
use ieee.std_logic_1164.all;

entity spi_sr is port (
    clk: in std_logic; -- core clock
    ss: in std_logic;
    -- SPI
    sclk: out std_logic; -- Gated `clk`
    si: in std_logic;
    so: out std_logic;
    -- IF
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic_vector(7 downto 0);
    data_out_rdy: out std_logic;
    data_in_ack: out std_logic;
    data_in_rdy: in std_logic);
end spi_sr;

architecture arch_spi_sr of spi_sr is
    signal reg: std_logic_vector(7 downto 0);
    type type_state is (s0,s1,s2,s3,s4,s5,s6,s7,empty,stall);
    signal state: type_state;
    attribute fsm_encoding: string;
    attribute fsm_encoding of state: signal is "compact";
begin
    process (clk, ss)
    begin
        if (ss = '1') then
            state <= empty;
        elsif rising_edge(clk) then
            if state = empty then
                if data_in_rdy = '1' then
                    state <= s0;
                    reg <= data_in;
                end if;
            elsif state = s0 then
                state <= s1;
                reg <= reg(6 downto 0) & si;
            elsif state = s1 then
                state <= s2;
                reg <= reg(6 downto 0) & si;
            elsif state = s2 then
                state <= s3;
                reg <= reg(6 downto 0) & si;
            elsif state = s3 then
                state <= s4;
                reg <= reg(6 downto 0) & si;
            elsif state = s4 then
                state <= s5;
                reg <= reg(6 downto 0) & si;
            elsif state = s5 then
                state <= s6;
                reg <= reg(6 downto 0) & si;
            elsif state = s6 then
                state <= s7;
                reg <= reg(6 downto 0) & si;
            elsif state = s7 then
                if data_in_rdy = '1' then
                    state <= s0;
                    reg <= data_in;
                else
                    reg <= reg(6 downto 0) & si;
                    state <= stall;
                end if;
            elsif state = stall then
                if data_in_rdy = '1' then
                    state <= s0;
                    reg <= data_in;
                end if;
            end if;
        end if;
    end process; 

    so <= reg(7);
    data_out_rdy <= '1' when state = s7 or state = stall else '0';
    data_out <= reg(6 downto 0) & si when state = s7
                else reg;
    data_in_ack <= '1' when state = s0 else '0';
    sclk <= '1' when clk = '1' and state /= empty and state /= stall else
            '0';
end arch_spi_sr;
