----------------------------------------------------------------------------
--
--  Atmel AVR Stack Pointer
--
--  This is the entity declaration for the Atmel AVR stack pointer.
--
--  Revision History:
--     2016-01-24     Initial Revision    Harrison Krowas
--
----------------------------------------------------------------------------
--
--
--  SP
--
--  The stack pointer is a 16-bit DFF array.
--
--  Inputs:
--    SPIn   - Input from the Control Unit
--    clock  - DFF clock
--
--  Outputs:
--    SPOut - Output of SP

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  SP  is
    port(
        SPin   :  in  std_logic_vector(15 downto 0);    -- DFF input
        clock  :  in  std_logic;
        SPOut  :  out  std_logic_vector(15 downto 0)    -- DFF output
    );
end  SP;
