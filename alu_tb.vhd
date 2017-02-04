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
    signal StatReg   :  std_logic_vector(7 downto 0);   -- status register
    
	 
	 variable IR_file			:  bit_vector(15 downto 0);  -- IR for operation
	 variable OperandA_file	:  bit_vector( 7 downto 0);  -- Operand A for operation
	 variable OperandB_file	:  bit_vector( 7 downto 0);  -- Operand B for operation
	 variable Result_file 	:  bit_vector(7 downto 0);  -- expected result
    variable StatReg_file  :  bit_vector(7 downto 0);   -- expected SR

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
     
  begin
 
    while not endfile(test_file) loop 
		
		-- Read one line into the test bench
      readline(test_file, rline);	
        
      -- This will read the values into the signals from the file 
      read(rline, IR_file);          -- IR 
      read(rline, OperandA_file);    -- OperandA
      read(rline, OperandB_file);    -- OperandB
      read(rline, Result_file);  		-- SR
      read(rline, StatReg_file); 		-- Result 
		 
		  
		IR <= to_stdlogicvector(IR_file);
      OperandA <= to_stdlogicvector(OperandA_file);
      OperandB <= to_stdlogicvector(OperandB_file);
		  
      -- Check the result of the operation 
      wait for 100 ns;
      assert(std_match(Result, to_stdlogicvector(Result_file)))    -- See if result is the same.
          report  "result incorrect"
          severity  ERROR;
      assert(std_match(StatReg, to_stdlogicvector(StatReg_file)))  -- See if SR is correct
          report "status register incorrect"
          severity  ERROR;
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
end alu_tb_arch;
