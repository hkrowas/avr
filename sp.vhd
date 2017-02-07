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
--    Reset  - active low synchronous reset
--    En_SP   - register enable
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
        Reset  :  in  std_logic;
        En_SP  :  in  std_logic;
        SPOut  :  buffer  std_logic_vector(15 downto 0)    -- DFF output
    );
end  SP;

architecture SP_ARCH of SP is
begin
  process(clock)
  begin
    if (rising_edge(clock)) then
      -- En_SP enables writes to SP. Reset makes SP all ones.
      for i in 15 downto 0 loop
        SPOut(i) <= (SPin(i) and En_SP) or (SPout(i) and not(En_SP)) or not(Reset);
      end loop;
    end if;
  end process;
end SP_ARCH;
