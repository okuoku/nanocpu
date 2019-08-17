--
-- Test: Asynchronous RAM model
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_aram is port (
    address: in std_logic_vector(17 downto 0);
    data: inout std_logic_vector(7 downto 0);
    we_n: in std_logic;
    oe_n: in std_logic;
    csel_n: in std_logic);
end test_aram;

architecture arch_test_aram of test_aram is
    type ram_type is array (262144 downto 0) of std_logic_vector(7 downto 0);
    signal store: ram_type;
begin
    process(we_n)
    begin
        if we_n = '0' and csel_n ='0' then
            store(to_integer(unsigned(address))) <= data;
        end if;
    end process;

    data <= store(to_integer(unsigned(address))) when 
            csel_n = '0' and oe_n = '0' else
            "ZZZZZZZZ";
end arch_test_aram;
