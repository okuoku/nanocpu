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
    type type_busturn is (c_read, c_write, c_null, action);
    signal datpag: std_logic_vector(7 downto 0);
    signal next_pc: std_logic_vector(5 downto 0);
    signal add9_a: std_logic_vector(7 downto 0);
    signal add9_b: std_logic_vector(7 downto 0);
    signal add9_result: std_logic_vector(8 downto 0);

    -- Registers
    signal phase: type_phase; -- 1 bit
    signal busturn: type_busturn; -- 2 bits
    attribute fsm_encoding: string;
    attribute fsm_encoding of busturn: signal is "compact";
    signal acc: std_logic_vector(8 downto 0); -- 9 bits
    signal pc: std_logic_vector(5 downto 0); -- 6 bits
    signal pag_dat: std_logic_vector(7 downto 0); -- 8: Data Slice register
    signal pag_prg: std_logic_vector(7 downto 0); -- 8: Program Slice register
    signal use_scratch: std_logic; -- 1 bit
    signal buf_addr: std_logic_vector(5 downto 0); -- 6: Address buffer
    signal op: std_logic_vector(1 downto 0); -- 2: current opcode
begin
    process(clk, rst_n)
    begin
        if (rst_n = '0') then
            busturn <= c_read;
            phase <= code;
            acc <= (others => '0');
            pc <= (others => '0');
            buf_addr <= (others => '0');
            pag_dat <= "11000000";
            pag_prg <= "11000000";
            use_scratch <= '0';
        elsif rising_edge(clk) then
            -- PC(pc), address source
            if busturn = action and phase = code then
                if data_in(7 downto 0) = "11111111" then -- LPS
                    pc <= (others => '0');
                    pag_prg <= acc(7 downto 0);
                elsif data_in(7 downto 0) = "11111110" then -- LDS
                    pc <= next_pc;
                    pag_dat <= acc(7 downto 0);
                elsif data_in(7 downto 0) = "11111100" then -- SWD
                    pc <= next_pc;
                    use_scratch <= '0';
                elsif data_in(7 downto 0) = "11111101" then -- SWS
                    pc <= next_pc;
                    use_scratch <= '1';
                elsif data_in(7 downto 6) = "11" and acc(8) = '0' then -- JCC
                    pc <= data_in(5 downto 0);
                else
                    pc <= next_pc;
                end if;
            end if;

            -- ALU(acc)
            if busturn = action and phase = data then
                case op is
                    when "00" => acc(7 downto 0) <= acc(7 downto 0) nor data_in;
                    when "01" => acc <= add9_result;
                    when "11" => acc(8) <= '0'; -- Branch
                    when others => null; -- STA
                end case;
            end if;

            -- Control, address buffer
            if busturn = c_read then -- finish read request
                busturn <= action;
            elsif busturn = c_write then -- run next
                busturn <= c_read;
                phase <= code;
                buf_addr <= pc;
            elsif busturn = c_null then -- branch
                busturn <= c_read;
                buf_addr <= pc;
            else -- action
                if phase = code then -- code phase
                    op <= data_in(7 downto 6);
                    if data_in(7 downto 6) = "11" then -- Jump/Special
                        busturn <= c_null; -- Wait pc update
                    elsif data_in(7 downto 6) = "10" then -- STA
                        busturn <= c_write;
                        buf_addr <= data_in(5 downto 0);
                        phase <= data;
                    else -- ADD/NOR
                        busturn <= c_read;
                        buf_addr <= data_in(5 downto 0);
                        phase <= data;
                    end if;
                else -- data phase
                    busturn <= c_read;
                    phase <= code;
                    buf_addr <= pc;
                end if;
            end if;
        end if;
    end process;

    -- Adder
    add9_a <= "00000001" when phase = code else data_in;
    add9_b <= "00" & pc when phase = code else acc(7 downto 0);
    add9_result <= std_logic_vector(unsigned("0" & add9_a) + unsigned("0" & add9_b));
    next_pc <= add9_result(5 downto 0);

    -- Control signals
    data_out <= acc(7 downto 0);
    en <= '1' when busturn /= c_write else '0';
    wr <= '1' when busturn = c_write else '0';
    datpag <= (others => '0') when use_scratch = '1' else pag_dat;
    addr <= pag_prg & buf_addr when phase = code else datpag & buf_addr;
end arch_nanocpu;
