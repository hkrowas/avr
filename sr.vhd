----------------------------------------------------------------------------
--
--  Atmel AVR Status Register
--
--  This is the entity declaration for the Atmel AVR status register.
--
--  Revision History:
--     2017-01-23     Initial Revision    Harrison Krowas
--     2017-02-23     Changes to I bit    Harrison Krowas
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


entity  SR  is
    port(
        RegIn   :  in  std_logic_vector(7 downto 0);    -- DFF input
        Mask    :  in  std_logic_vector(7 downto 0);
        clock   :  in  std_logic;
        I_set   :  in  std_logic;
        RegOut  :  buffer std_logic_vector(7 downto 0)
    );
end  SR;

architecture SR_ARCH of SR is
begin
  process (clock)
  begin
    if (rising_edge(clock)) then
      -- RegOut gets old value if bit in mask not set
      -- RegOut gets Regin value if bit in mask is set
      RegOut <= (RegOut and not(Mask)) or (RegIn and Mask);
    end if;
    if (I_set = '1') then
      RegOut(7) <= '1';
    end if;
  end process;
end SR_ARCH;
