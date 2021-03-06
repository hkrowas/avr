----------------------------------------------------------------------------
--
--  Atmel AVR ALU Test Bed
--
--  This is the test bed for the ALU 
--
--  Revision History:
--     2017-02-04  Torkom Pailevanian     Initial revision.
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use std.textio.all;

library opcodes;
use opcodes.opcodes.all;

library txt_util;
use txt_util.txt_util.all;

entity alu_tb is
end alu_tb;

architecture alu_tb_arch of alu_tb is
    component ALU_TEST
    port(
        IR        :  in  opcode_word;                   -- Instruction Register
        OperandA  :  in  std_logic_vector(7 downto 0);  -- first operand
        OperandB  :  in  std_logic_vector(7 downto 0);  -- second operand
        clock     :  in  std_logic;                     -- system clock
        Result    :  out std_logic_vector(7 downto 0);  -- ALU result
        StatReg   :  out std_logic_vector(7 downto 0)   -- status register
    );
    end component;
	
    signal IR        :  opcode_word;                   -- Instruction Register
    signal OperandA  :  std_logic_vector(7 downto 0);  -- first operand
    signal OperandB  :  std_logic_vector(7 downto 0);  -- second operand
    signal clock     :  std_logic;                     -- system clock
    signal Result    :  std_logic_vector(7 downto 0);  -- ALU result
    signal StatReg   :  std_logic_vector(7 downto 0) := "00000000";   -- status register
    
	 
	 signal END_SIM : BOOLEAN := FALSE;

begin
    UUT : ALU_TEST
    port map (
        IR => IR,
        OperandA => OperandA,
        OperandB => OperandB,
        clock => clock,
        Result => Result,
        StatReg => StatReg
    );
  process
    
    -- The test file contains the IR, OperandA, OperandB, SR and Result 
    --  on a signle line for each operation 
    file test_file : text is in "..\test\alu_test.txt";
    
    variable rline : line; -- This contains one line from the data 
	 
	 variable IR_file			:  string(1 to 16);  -- IR for operation
	 variable OperandA_file	:  string(1 to  9);  -- Operand A for operation
	 variable OperandB_file	:  string(1 to  9);  -- Operand B for operation
	 variable Result_file 	:  string(1 to  9);  -- expected result
    variable StatReg_file  :  string(1 to  9);  -- expected SR
	 variable prevStat		:  std_logic_vector(7 downto 0) := "--------"; -- Latched value of SR
     
  begin
		
    while not endfile(test_file) loop 
		wait for 1 ns;
		
		-- Read one line into the test bench
      readline(test_file, rline);	
        
      -- This will read the values into the signals from the file 
      read(rline, IR_file);          -- IR 
      read(rline, OperandA_file);    -- OperandA
      read(rline, OperandB_file);    -- OperandB
      read(rline, StatReg_file); 	 -- SR
      read(rline, Result_file);  	 -- Result
		  
	   IR <= to_std_logic_vector(IR_file);
		-- Taking a slice from 2 to 9 since there is a space between 
		--  the inputs in the txt file but not for the IR register
      OperandA <= to_std_logic_vector(OperandA_file(2 to 9));
      OperandB <= to_std_logic_vector(OperandB_file(2 to 9));
		  
      -- Check the result of the operation
		wait for 18 ns;

      assert(std_match(Result, to_std_logic_vector(Result_file(2 to 9))))    -- See if result is the same.
          report  "result incorrect"
          severity  ERROR;
      assert(std_match(StatReg, prevStat))  -- See if SR is correct
          report "status register incorrect"
          severity  ERROR;
		prevStat := to_std_logic_vector(StatReg_file(2 to 9));
		
		wait for 1 ns;
		
    end loop;
    END_SIM <= TRUE;
    wait;
  end process;

  CLOCK_CLK : process

  begin
      -- this process generates a 20 ns period, 50% duty cycle clock

      -- only generate clock if still simulating
      if END_SIM = FALSE then
          clock <= '1';
          wait for 10 ns;
      else
          wait;
      end if;

      if END_SIM = FALSE then
          clock <= '0';
          wait for 10 ns;
      else
          wait;
      end if;

  end process;
end alu_tb_arch;
