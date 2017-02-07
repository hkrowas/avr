----------------------------------------------------------------------------
--
--  Atmel AVR Memory Unit Test Bed
--
--  This is the test bed for the data access unit. It tests all the data access
--  instructions by checking if the unit outputs the correct address on the
--  address bus, and for write operations the correct value on the databus. It
--  also checks the RD and WR lines before and during the access to ensure that
--  they go active at the correct time and do not glitch.
--
--  Revision History:
--     2017-02-07  Harrison Krowas     Initial revision.
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

entity MEM_TB is
end MEM_TB;

architecture MEM_TB_ARCH of MEM_TB is
  component MEM_TEST
    port (
        IR      :  in     opcode_word;                      -- Instruction Register
        ProgDB  :  in     std_logic_vector(15 downto 0);    -- second word of instruction
        Reset   :  in     std_logic;                        -- system reset signal (active low)
        clock   :  in     std_logic;                        -- system clock
        DataAB  :  out    std_logic_vector(15 downto 0);    -- data address bus
        DataDB  :  inout  std_logic_vector(7 downto 0);     -- data data bus
        DataRd  :  out    std_logic;                        -- data read (active low)
        DataWr  :  out    std_logic                         -- data write (active low)
    );
  end component;

  signal IR      :  opcode_word;
  signal ProgDB  :  std_logic_vector(15 downto 0);
  signal Reset   :  std_logic;
  signal clock   :  std_logic;
  signal DataAB  :  std_logic_vector(15 downto 0);
  signal DataDB  :  std_logic_vector(7 downto 0);
  signal DataRd  :  std_logic;
  signal DataWr  :  std_logic;

  signal DA_test : std_logic_vector(15 downto 0);
  signal DB_test : std_logic_vector(7 downto 0);
  signal DB_put  : std_logic_vector(7 downto 0);
  signal Rd_test : std_logic;
  signal Wr_test : std_logic;

  signal END_SIM : BOOLEAN := FALSE;

begin
  UUT : MEM_TEST
    port map (
      IR => IR,
      ProgDB => ProgDB,
      Reset => Reset,
      clock => clock,
      DataAB => DataAB,
      DataDB => DataDB,
      DataRd => DataRd,
      DataWr => DataWr
    );
  process
    file test_file : text is in "test/mem_test.txt";
    variable rline : line; -- This contains one line from the data

    variable IR_file : std_logic_vector(15 downto 0);
    variable RegIn_file : string(1 to 8);
    variable RegOut_file : string(1 to 8);

    variable IR_var : std_logic_vector(15 downto 0);
    variable DA_var : std_logic_vector(15 downto 0);
    variable DB_test_var : std_logic_vector(7 downto 0);
    variable DB_put_var  : std_logic_vector(7 downto 0);
    variable RD_var : std_logic;
    variable WR_var : std_logic;
    variable ProgDB_var : std_logic_vector(15 downto 0);

  begin
    Reset <= '0';   -- Set SP to 0xFFFF
    wait for 40 ns;
    Reset <= '1';
    wait for 11 ns;
    while not endfile(test_file) loop
      readline(test_file, rline);     -- Read in values from text file
      read(rline, IR_var);
      read(rline, DA_var);
      read(rline, DB_test_var);
      read(rline, DB_put_var);
      read(rline, RD_var);
      read(rline, WR_var);
      IR <= IR_var;
      DA_test <= DA_var;
      DB_test <= DB_test_var;
      DB_put <= DB_put_var;
      Rd_test <= RD_var;
      Wr_test <= Wr_var;    -- Read in line and convert to signlals
      assert(std_match(DataRd, '1'));   -- Rd/Wr should be inactive before access
      assert(std_match(DataWr, '1'));
      wait for 18 ns;
      DataDB <= DB_put;                 -- Put on DB to simulate memory
      if (not(std_match(IR, "100100------0000"))) then  -- If not a direct instruction
        assert(std_match(DataAB, DA_test));
      end if;
      if (std_match(IR, "10--------------")) then -- Wait if 2 cycle intstruciton
        wait for 11 ns;
        -- If LDS or STS, add another cycle of wait
        if (std_match(IR, "100100------0000")) then
          ProgDB <= DA_test;      -- Give Data access unit the operand if LDS or STS
          wait for 20 ns;
          assert(std_match(DataAB, DA_test));   -- Check if address given is on AB
        end if;
      end if;
      assert(std_match(RD_test, DataRd));   -- Test RD
      assert(std_match(WR_test, DataWr));   -- Test WR
      assert(std_match(DB_test, DataDB));   -- Test DB
      if (std_match(IR, "10--------------")) then   -- If 2 or more cycle instruction
        wait for 11 ns;
      else
        wait for 2 ns;
      end if;
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
end MEM_TB_ARCH;
