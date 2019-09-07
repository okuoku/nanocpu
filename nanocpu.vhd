-- nanoCPU
-- Based on https://github.com/cpldcpu/MCPU (GPL2)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nanocpu is port (
    clk: in std_logic;
    rst_n: in std_logic;
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic_vector(7 downto 0);
    addr: out std_logic_vector(13 downto 0);
    en: out std_logic;
    wr: out std_logic);
end;

architecture arch_nanocpu of nanocpu is
    type type_phase is (code, data);
    type type_busturn is (command_read, command_write, command_null, action);
    signal datpag: std_logic_vector(7 downto 0);

    -- Registers
    signal phase: type_phase; -- 1 bit
    signal busturn: type_busturn; -- 2 bits
    signal acc: std_logic_vector(8 downto 0); -- 9 bits
    signal pc: std_logic_vector(5 downto 0); -- 6 bits
    signal pag_dat: std_logic_vector(7 downto 0); -- 8: Data page register
    signal pag_prg: std_logic_vector(7 downto 0); -- 8: Program page register
    signal use_scratch: std_logic; -- 1 bit
    
    signal buf_addr: std_logic_vector(5 downto 0); -- 6: Address buffer
    signal op: std_logic_vector(1 downto 0); -- 2: current opcode
begin
    process(clk, rst_n)
    begin
        if (rst_n = '0') then
            busturn <= command_read;
            phase <= code;
            acc <= (others => '0');
            pc <= (others => '0');
            pag_dat <= "10000000";
            pag_prg <= "10000000";
            use_scratch <= '0';
        elsif rising_edge(clk) then
            if busturn = command_read then -- finish read request
                busturn <= action;
            elsif busturn = command_write then -- run next
                phase <= code;
                busturn <= command_read;
            elsif busturn = command_null then
                phase <= code;
                busturn <= command_read;
            else -- action
                if phase = code then -- code phase
                    op <= data_in(7 downto 6);
                    buf_addr <= data_in(5 downto 0);
                    if data_in(7 downto 6) = "11" then -- Jump/Special
                        if data_in(5 downto 0) = "111100" then -- SWD
                            pc <= std_logic_vector(unsigned(buf_addr) + 1);
                            use_scratch <= '0';
                        elsif data_in(5 downto 0) = "111101" then -- SWS
                            pc <= std_logic_vector(unsigned(buf_addr) + 1);
                            use_scratch <= '1';
                        elsif data_in(5 downto 0) = "111110" then -- LDS
                            pc <= std_logic_vector(unsigned(buf_addr) + 1);
                            pag_dat <= acc(7 downto 0);
                        elsif data_in(5 downto 0) = "111111" then -- LDP
                            pag_prg <= acc(7 downto 0);
                            pc <= (others => '0');
                        else -- JCC
                            if acc(8) = '0' then
                                pc <= data_in(5 downto 0);
                            else
                                pc <= std_logic_vector(unsigned(buf_addr) + 1);
                            end if;
                            acc(8) <= '0';
                        end if;
                        busturn <= command_null; -- To reduce pc MUX fan-in
                    elsif data_in(7 downto 6) = "10" then -- STA
                        pc <= std_logic_vector(unsigned(buf_addr) + 1);
                        busturn <= command_write;
                        phase <= data;
                    else -- ADD/NOR
                        pc <= std_logic_vector(unsigned(buf_addr) + 1);
                        busturn <= command_read;
                        phase <= data;
                    end if;
                else -- data phase
                    busturn <= command_read;
                    phase <= code;
                    buf_addr <= pc;
                    if op = "00" then -- NOR
                        acc(7 downto 0) <= acc(7 downto 0) nor data_in;
                    elsif op = "01" then -- ADD
                        acc <= std_logic_vector(unsigned("0" & acc(7 downto 0)) + unsigned("0" & data_in));
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Address output
    data_out <= acc(7 downto 0);
    en <= '1' when busturn = command_read or busturn = action else '0';
    wr <= '1' when busturn = command_write else '0';
    datpag <= (others => '0') when use_scratch = '1' else pag_dat;
    addr <= pag_prg & buf_addr when phase = code else datpag & buf_addr;

end arch_nanocpu;
