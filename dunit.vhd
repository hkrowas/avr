----------------------------------------------------------------------------
--
--  Atmel AVR Data Access Unit
--
--  This is the entity declaration for the Atmel AVR data access unit.
--
--  Revision History:
--     2016-01-24     Initial Revision    Harrison Krowas
--
----------------------------------------------------------------------------
--
--
--  DUNIT
--
--  The data unit for the Atmel AVR.
--
--  Inputs:
--    XReg  -  X register
--    YReg  -  Y register
--    ZReg  -  Z register
--    IR    -  Instruction register for direct addressing
--    ASelect  -  Selects base source
--    OSelect  -  Selects offset source
--
--  Outputs:
--    DABus - Data address bus

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  DUNIT  is
    port(
        XReg   :  in  std_logic_vector(15 downto 0);
        YReg   :  in  std_logic_vector(15 downto 0);
        ZReg   :  in  std_logic_vector(15 downto 0);
        IR     :  in  std_logic_vector(15 downto 0);
        ASelect:  in  std_logic_vector(1 downto 0);
        OSelect:  in  std_logic_vector(1 downto 0);
        DABus  :  out std_logic_vector(15 downto 0)
    );
end  DUNIT;
