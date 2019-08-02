-- nanoCPU
-- Based on https://github.com/cpldcpu/MCPU (GPL2)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nanocpu is port (
    data: inout std_logic_vector(7 downto 0);
    address: out std_logic_vector(13 downto 0);
    oe: out std_logic;
    we: out std_logic;
    clk: in std_logic;
    rst: in std_logic);
end;

architecture arch_nanocpu of nanocpu is
    signal acc: std_logic_vector(8 downto 0);
    signal reg_addr: std_logic_vector(13 downto 0);
    signal pc: std_logic_vector(5 downto 0);
    signal states: std_logic_vector(2 downto 0);

    signal use_scratch: std_logic;
    signal seg_dat: std_logic_vector(7 downto 0);
    signal seg_prg: std_logic_vector(7 downto 0);
begin
    process(clk, rst)
    begin
        if (rst = '0') then
            reg_addr <= (others => '0');
            states <= "000";
            acc <= (others => '0');
            pc <= (others => '0');
            seg_dat <= (others => '0');
            seg_prg <= (others => '0');
            use_scratch <= '0';
        elsif rising_edge(clk) then
            -- Address generation
            if (states = "000") then
                -- `reg_addr` holds seg_prg + PC output
                -- `data` holds inst
                pc <= std_logic_vector(unsigned(reg_addr(5 downto 0)) + 1);
                if use_scratch = '1' then
                    reg_addr <= "00010000" & data(5 downto 0);
                else
                    reg_addr <= seg_dat & data(5 downto 0);
                end if;
            elsif (states = "111") then 
                -- branch
                reg_addr <= seg_prg & data(5 downto 0);
            else
                -- output instruction addr
                reg_addr <= seg_prg & pc;
            end if;

            -- ALU
            case states is
                -- nor
                when "011" => acc(7 downto 0) <= acc(7 downto 0) nor data;
                -- add
                when "010" => acc <= std_logic_vector(unsigned("0" & acc(7 downto 0)) + unsigned("0" & data));
                -- (no ALU)
                when others => null;
            end case;

            -- Control logic
            if (states /= "000" and states /= "111") then
                -- Not in inst fetch stage, just output instruction addr (above)
                states <= "000";
            elsif (states = "111") then
                states <= "000";
            elsif (data(7 downto 0) = "11111100") then
                -- SWD (Switch to data space)
                use_scratch <= '0';
                states <= "000";
            elsif (data(7 downto 0) = "11111101") then
                -- SWS (Switch to scratch space)
                use_scratch <= '1';
                states <= "000";
            elsif (data(7 downto 0) = "11111111") then
                -- LPS (Load Program Segment register)
                seg_prg <= acc(7 downto 0);
                states <= "000";
            elsif (data(7 downto 0) = "11111110") then
                -- LDS (Load Data Segment register)
                seg_dat <= acc(7 downto 0);
                states <= "000";
            elsif (data(7 downto 6) = "11" and acc(8) = '1') then
                -- 101 - 11 JCC (not taken, output disable)
                states <= "101";
            elsif (data(7 downto 6) = "11" and acc(8) = '0') then
                -- 111 - 11 JCC (taken, output inst address)
                states <= "111";
            else
                -- 011 - 00 NOR
                -- 010 - 01 ADD
                -- 001 - 10 STA
                states <= "0" & not data(7 downto 6);
            end if;
        end if;
    end process;

    -- SRAM output
    address <= reg_addr;
    data <= "ZZZZZZZZ" when states /= "001" else acc(7 downto 0);
    oe <= '1' when (clk = '1' or states = "001" or states = "101" or rst = '0') else '0';
    we <= '1' when (clk = '1' or states /= "001" or rst = '0') else '0';
end arch_nanocpu;
