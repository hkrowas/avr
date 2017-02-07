----------------------------------------------------------------------------
--
--  Atmel AVR Register Array Test Bed
--
--  This is the test bed for the register array. It tests the array by inputting
--  values to the array and checking whether they were taken after the next rising
--  edge.
--
--  Revision History:
--     2017-01-31  Harrison Krowas     Initial revision.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use std.textio.all;

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

  signal RegAOut_test : std_logic_vector(7 downto 0);
  signal RegBOut_test : std_logic_vector(7 downto 0);

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
    file test_file : text is in "test/reg_test.txt";
    variable rline : line; -- This contains one line from the data

    variable IR_file : std_logic_vector(15 downto 0);
    variable RegIn_file : string(1 to 8);
    variable RegOut_file : string(1 to 8);

    variable IR_var : std_logic_vector(15 downto 0);
    variable RegIn_var : std_logic_vector(7 downto 0);
    variable RegAOut_var : std_logic_vector(7 downto 0);
    variable RegBOut_var : std_logic_vector(7 downto 0);

  begin
    wait for 21 ns;
    while not endfile(test_file) loop
      -- Read one line into the test bench
        readline(test_file, rline);

        read(rline, IR_var);      -- Read in value from txt file
        read(rline, RegIn_var);
        read(rline, RegAOut_var);
        read(rline, RegBOut_var);
        IR <= IR_var;
        RegIn <= RegIn_var;       -- Set input to register array
        RegAOut_test <= RegAOut_var;
        RegBOut_test <= RegBOut_var;
        wait for 18 ns;       -- clock occurs during this wait
        assert(std_match(RegAOut, RegAOut_test));    -- See if value was written to A.
        assert(std_match(RegBOut, RegBOut_test));
        wait for 2 ns;
    end loop;
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
