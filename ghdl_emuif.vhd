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
    rstreq: out std_logic;
    rst: in std_logic);
end busemu;

architecture arch_busemu of busemu is
    -- Returns: ERDDDDDDDD
    function busemu_cycle (addr,datain,xoe,xwe : integer) return integer;
    attribute foreign of busemu_cycle : function is "VHPIDIRECT ./busemu.so busemu_cycle";

    function busemu_cycle (addr,datain,xoe,xwe : integer) return integer is
    begin
        -- Dummy
        assert false severity failure;
    end busemu_cycle;
    signal outdata: std_logic_vector(7 downto 0);
begin

    process(rst,oe,we)
    -- emu I/F
    variable emu_address : integer;
    variable emu_data : integer;
    -- emu virtual signals
    variable emu_ret : std_logic_vector(9 downto 0);
    variable emu_outdata : std_logic_vector(7 downto 0);
    variable emu_rstreq : std_logic; -- 8
    variable emu_err : std_logic; -- 9
    begin
        if rst = '0' then
            -- NB: busemu_cycle does not handle nRST signal
            --     (SRAMs does not connected to system nRST)
            rstreq <= '0';
        elsif falling_edge(oe) then
            -- Read cycle
            emu_address := to_integer(unsigned(address));

            emu_ret := std_logic_vector(to_unsigned(busemu_cycle(emu_address, 0, 0, 1), emu_ret'length));

            emu_outdata := emu_ret(7 downto 0);
            emu_rstreq := emu_ret(8);
            emu_err := emu_ret(9);

            if emu_err = '1' then
                assert false severity failure;
            end if;

            outdata <= emu_outdata(7 downto 0);
            rstreq <= emu_rstreq;
        elsif falling_edge(we) then
            -- Write cycle
            emu_address := to_integer(unsigned(address));
            emu_data := to_integer(unsigned(data));

            emu_ret := std_logic_vector(to_unsigned(busemu_cycle(emu_address, emu_data, 1, 0), emu_ret'length));

            emu_outdata := emu_ret(7 downto 0);
            emu_rstreq := emu_ret(8);
            emu_err := emu_ret(9);

            if emu_err = '1' then
                assert false severity failure;
            end if;

            outdata <= emu_outdata(7 downto 0);
            rstreq <= emu_rstreq;
        end if;
    end process;

    data <= outdata when oe = '0' else "ZZZZZZZZ";
end arch_busemu;
