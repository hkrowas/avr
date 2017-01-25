----------------------------------------------------------------------------
--
--  Atmel AVR Instruction Access Unit
--
--  This is the entity declaration for the Atmel AVR instruction access unit.
--
--  Revision History:
--     2016-01-24     Initial Revision    Harrison Krowas
--
----------------------------------------------------------------------------
--
--
--  DUNIT
--
--  The instruction access unit for the AVR.
--
--  Inputs:
--    IR    -  Instruction register for direct addressing
--    Sel   -  Source select. Also controls direct addressing
--    ZReg  -  Z register
--
--  Outputs:
--    IABus   - Instruction address bus

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  IUNIT  is
    port(
        IR     :  in  std_logic_vector(15 downto 0);
        Sel    :  in   std_logic_vector(1 downto 0);
        ZReg   :  in  std_logic_vector(15 downto 0);
        IABus  :  out std_logic_vector(15 downto 0)
    );
end  IUNIT;
