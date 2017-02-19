----------------------------------------------------------------------------
--
--  Atmel AVR Instruction Register
--
--  This is the entity declaration for the Atmel AVR instruction register.
--
--  Revision History:
--     2016-01-23     Initial Revision    Harrison Krowas
--
----------------------------------------------------------------------------
--
--
--  IR
--
--  The instruction register is a 16-bit DFF array.
--
--  Inputs:
--    IRIn   -  Input from the Instruction Address Unit
--    clock  -  DFF clock
--    IR_en  -  DFF enable
--
--  Outputs:
--    IROut - Output of IR

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  IR  is
    port(
        IRIn   :  in  std_logic_vector(15 downto 0);    -- DFF input
        IR_en  :  in  std_logic;
        clock  :  in  std_logic;
        IROut  :  buffer  std_logic_vector(15 downto 0)    -- DFF output
    );
end  IR;

architecture IR_ARCH of IR is
begin
  process(clock)
  begin
    if (rising_edge(clock)) then
      -- En_SP enables writes to SP. Reset makes SP all ones.
      for i in 15 downto 0 loop
        IROut(i) <= (IRin(i) and IR_en) or (IROut(i) and not(IR_en));
      end loop;
    end if;
  end process;
end IR_ARCH;
