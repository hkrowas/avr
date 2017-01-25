----------------------------------------------------------------------------
--
--  Atmel AVR Status Register
--
--  This is the entity declaration for the Atmel AVR status register.
--
--  Revision History:
--     2016-01-23     Initial Revision    Harrison Krowas
--
----------------------------------------------------------------------------
--
--
--  SR
--
--  The status register is an 8-bit DFF array with enable.
--
--  Inputs:
--    RegIn  -  DFF input
--    Mask   -  Input mask. Equivalent to DFF enable. This input is taken from
--              the control unit.
--    clock  -  DFF clock
--
--  Outputs:
--    RegOut - DFF output

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  SR  is
    port(
        RegIn   :  in  std_logic_vector(7 downto 0);    -- DFF input
        Mask    :  in  std_logic_vector(7 downto 0);
        clock   :  in  std_logic;
        RegOut  :  out std_logic_vector(7 downto 0)
    );
end  SR;
