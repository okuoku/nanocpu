-- 
-- Emulator bridge 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity busemu is port (
    data: inout std_logic_vector(7 downto 0);
    address: in std_logic_vector(13 downto 0);
    oe: in std_logic;
    we: in std_logic;
    clk: in std_logic;
    rst: out std_logic);
end busemu;

architecture arch_busemu of busemu is
    -- Returns: ERDDDDDDDD
    function busemu_cycle (addr,datain,xwe : integer) return integer;
    attribute foreign of busemu_cycle : function is "VHPIDIRECT ./busemu.so busemu_cycle";

    function busemu_cycle (addr,datain,xwe : integer) return integer is
    begin
        -- Dummy
        assert false severity failure;
    end busemu_cycle;
begin

    process(clk)
    -- emu I/F
    variable emu_address : integer;
    variable emu_data : integer;
    variable emu_we : integer;
    -- emu virtual signals
    variable emu_ret : std_logic_vector(9 downto 0);
    variable emu_outdata : std_logic_vector(7 downto 0);
    variable emu_rst : std_logic; -- 8
    variable emu_err : std_logic; -- 9
    begin
        if falling_edge(clk) then
            emu_address := to_integer(unsigned(address));
            emu_data := to_integer(unsigned(data));
            if we = '0' then
                emu_we := 0;
            else
                emu_we := 1;
            end if;

            emu_ret := std_logic_vector(to_unsigned(busemu_cycle(emu_address, emu_data, emu_we), emu_ret'length));

            emu_outdata := emu_ret(7 downto 0);
            emu_rst := emu_ret(8);
            emu_err := emu_ret(9);

            if emu_err = '1' then
                assert false severity failure;
            end if;

            rst <= emu_rst;
            if oe = '1' then
                data <= emu_outdata;
            else
                data <= "ZZZZZZZZ";
            end if;
        end if;
    end process;
end arch_busemu;
