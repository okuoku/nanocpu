library ieee;
use ieee.std_logic_1164.all;

entity ioc_mbc is port (
    rst: std_logic;
    -- SRAM I/F
    data_in: in std_logic_vector(7 downto 0);
    address: in std_logic_vector(2 downto 0);
    we_in: in std_logic;
    we_out: out std_logic;
    
    rgn: in std_logic_vector(1 downto 0);
    bank: out std_logic_vector(5 downto 0);
    csel: out std_logic_vector(3 downto 0));
end;

architecture arch_ioc_mbc of ioc_mbc is
    signal bank1: std_logic_vector(7 downto 0);
    signal bank2: std_logic_vector(7 downto 0);
    signal bank3: std_logic_vector(7 downto 0);

    signal chip: std_logic_vector(1 downto 0);
begin
    process(rst, we_in)
    begin
        if (rst = '0') then
            bank1 <= "10000000";
            bank2 <= "01000000"; -- nRST makes bank2 as ROM
            bank3 <= (others => '0');
        elsif falling_edge(we_in) then
            if rgn = "11" then
                if (address = "000") then
                    bank1 <= data_in;
                elsif (address = "001") then
                    bank2 <= data_in;
                elsif (address = "010") then
                    bank3 <= data_in;
                end if;
            end if;
        end if;
    end process;

    -- Output
    we_out <= '0' when we_in = '1' and rgn /= "11" else '1';

    bank <= "000000" when rgn = "00" else
            bank1(5 downto 0) when rgn = "01" else
            bank2(5 downto 0) when rgn = "10" else
            bank3(5 downto 0) when rgn = "11";

    chip <= "00" when rgn = "00" else
            bank1(7 downto 6) when rgn = "01" else
            bank2(7 downto 6) when rgn = "10" else
            bank3(7 downto 6) when rgn = "11";

    csel <= "1110" when chip = "00" else
            "1101" when chip = "01" else
            "1011" when chip = "10" else
            "0111" when chip = "11";
end arch_ioc_mbc;
