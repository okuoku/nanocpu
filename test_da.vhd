library ieee;
use ieee.std_logic_1164.all;

entity test_da is port(
    rst_n: in std_logic;
    clk: in std_logic;
    addr: in std_logic_vector(11 downto 0);
    data_in: in std_logic_vector(7 downto 0);
    wr: in std_logic;

    -- output
    success: out std_logic;
    fail: out std_logic);
end;


architecture arch_test_da of test_da is
    signal reg_success: std_logic;
    signal reg_fail: std_logic;
begin
    process(rst_n, clk)
    begin
        if(rst_n = '0') then
            reg_success <= '0';
            reg_fail <= '0';
        elsif rising_edge(clk) and wr = '1' then
            case addr is
                when "000000000010" => reg_fail <= '1';
                when "000000000011" => reg_success <= '1';
                when others => reg_fail <= '1';
            end case;
        end if;
    end process;

    success <= reg_success;
    fail <= reg_fail;
end arch_test_da;
