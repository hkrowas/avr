----------------------------------------------------------------------------
--
--  Atmel AVR ALU
--
--  This is the entity declaration for the Atmel AVR ALU.
--
--  Revision History:
--     2016-01-23     Initial Revision    Harrison Krowas
--
----------------------------------------------------------------------------
--
--
--  ALU
--
--  The ALU performs on operation on two inputs and outputs a single output
--  to the register array.
--
--  Inputs:
--    OperandA - first operand to ALU (8 bits) - looks like the output
--               of the register array
--    OperandB - second operand to ALU (8 bits) - looks like the output
--               of the register array
--    AluOp    - 7 bit vector that tells the ALU which operation to perform.
--    StatRegIn- status register input. The status register is used for some
--               ALU operations.
--
--
--  Outputs:
--    Result   - result of the ALU operation selected by the Instruction
--               Register (8 bits)
--    StatReg  - status register. Flags are always output regardless of operation.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  ALU  is
    port(
        OperandA  :  in  std_logic_vector(7 downto 0);    -- first operand
        OperandB  :  in  std_logic_vector(7 downto 0);    -- second operand
        AluOp     :  in  std_logic_vector(n downto 0);    -- ALU operation to perform
        StatRegIn :  in  std_logic_vector(7 downto 0);
        Result    :  out std_logic_vector(7 downto 0);    -- ALU result
        StatRegOut:  out std_logic_vector(7 downto 0)     -- status register
    );
end  ALU;
