----------------------------------------------------------------------------
--
--  Atmel AVR Register Array Test Bed
--
--  This is the test bed for the register array
--
--  Revision History:
--     2017-01-31  Harrison Krowas     Initial revision.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;

entity reg_tb is
end reg_tb;

architecture reg_tb_arch of reg_tb is
  component REG_TEST
    port(
        IR       :  in  opcode_word;                        -- Instruction Register
        RegIn    :  in  std_logic_vector(7 downto 0);       -- input register bus
        clock    :  in  std_logic;                          -- system clock
        RegAOut  :  out std_logic_vector(7 downto 0);       -- register bus A out
        RegBOut  :  out std_logic_vector(7 downto 0)        -- register bus B out
    );
  end component;

  signal IR       :  opcode_word;
  signal RegIn    :  std_logic_vector(7 downto 0);       -- input register bus
  signal clock    :  std_logic;                          -- system clock
  signal RegAOut  :  std_logic_vector(7 downto 0);       -- register bus A out
  signal RegBOut  :  std_logic_vector(7 downto 0);       -- register bus B out

  signal END_SIM : BOOLEAN := FALSE;


begin
  UUT : REG_TEST
    port map (
      IR => IR,
      RegIn => RegIn,
      clock => clock,
      RegAOut => RegAOut,
      RegBOut => RegBOut
    );
  process
  begin
    -- Access R0 and R0
    IR <= opADC(15 downto 10) & "0000000000";
    RegIn <= x"BF";
    wait for 40 ns;
    assert(std_match(RegAOut, x"BF"));
    -- try non-writing operation on R0
    IR <= opCP(15 downto 10) & "0000000000";
    RegIn <= x"37";
    wait for 40 ns;
    assert(std_match(RegAOut, x"BF"));
    -- See if we can still write to R0
    IR <= opADC(15 downto 10) & "0000000000";
    RegIn <= x"CD";
    wait for 40 ns;
    assert(std_match(RegAOut, x"CD"));
    -- Write something to R1
    -- Access R0 and R0
    IR <= opADC(15 downto 10) & "0000010000";
    RegIn <= x"EE";
    wait for 40 ns;
    assert(std_match(RegAOut, x"EE"));
    IR <= opADC(15 downto 10) & "0000000000";
    RegIn <= x"CD";
    wait for 40 ns;
    assert(std_match(RegAOut, x"CD"));
    -- Test immediate operand addressing
    IR <= opSUBI(15 downto 12) & "000000000000";
    RegIn <= x"BB";
    wait for 40 ns;
    assert(std_match(RegAOut, x"BB"));
    IR <= opCP(15 downto 10) & "0100000000";
    RegIn <= x"37";
    wait for 40 ns;
    assert(std_match(RegAOut, x"BB"));
    -- Test B select
    IR <= opCP(15 downto 10) & "1000000000";
    RegIn <= x"37";
    wait for 40 ns;
    assert(std_match(RegBOut, x"BB"));
    assert(std_match(RegAOut, x"CD"));

    END_SIM <= TRUE;
    wait;
  end process;

  CLOCK_CLK : process

  begin

      -- this process generates a 20 ns period, 50% duty cycle clock

      -- only generate clock if still simulating

      if END_SIM = FALSE then
          clock <= '0';
          wait for 10 ns;
      else
          wait;
      end if;

      if END_SIM = FALSE then
          clock <= '1';
          wait for 10 ns;
      else
          wait;
      end if;

  end process;
end reg_tb_arch;
