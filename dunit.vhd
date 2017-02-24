----------------------------------------------------------------------------
--
--  Atmel AVR Data Access Unit
--
--  This is the entity declaration for the Atmel AVR data access unit.
--  The data access unit is capable of selecting the X, Y, Z, SP, or IR as a base
--  address and then adding a constant or +/-1 offset. The address can be post
--  or pre incremented based on the PostPre select line. It also controls the
--  input going to the register array, which can either be the output of the ALU
--  RegB, a constant from the IR, or the data bus.
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
--    PrePost  - Pre/Post increment select
--    SP  -  stack pointer
--    DBusIn - Program data bus. For use in STS, LDS instructions
--    ALUOut -
--
--  Outputs:
--    DBusOut - The output of the data unit that goes into the register arary
--    Address - computed addres + offset
--    DABus - Data address bus

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  DUNIT  is
    port(
        clock  :  in  std_logic;
        XReg   :  in  std_logic_vector(15 downto 0);
        YReg   :  in  std_logic_vector(15 downto 0);
        ZReg   :  in  std_logic_vector(15 downto 0);
        IR     :  in  std_logic_vector(15 downto 0);
        ASelect:  in  std_logic_vector(2 downto 0);
        OSelect:  in  std_logic_vector(1 downto 0);
        PrePost:  in  std_logic;
        SP     :  in  std_logic_vector(15 downto 0);
        DBusIn :  in  std_logic_vector(7 downto 0);
        RegB   :  in  std_logic_vector(7 downto 0);
        ALUOut :  in  std_logic_vector(7 downto 0);
        DMux   :  in  std_logic_vector(1 downto 0);
        ProgDB :  in  std_logic_vector(15 downto 0);
        DBusOut:  out std_logic_vector(7 downto 0);
        Address:  buffer std_logic_vector(15 downto 0);
        DABus  :  out std_logic_vector(15 downto 0)
    );
end  DUNIT;

architecture DUNIT_ARCH of DUNIT is
  signal ASource : std_logic_vector(15 downto 0); -- Address source
  signal OSource : std_logic_vector(15 downto 0);
  -- This is use for the STS and LDS instructions.
  -- It holds the previous value of the IR for immediate addressing.
  signal IR_delay :  std_logic_vector(15 downto 0);
begin
  -- Address Source Mux
  with ASelect select ASource <=
    XReg when "000",
    YReg when "001",
    ZReg when "010",
    IR_delay   when "011",
    SP   when "100",
    SP   when others;

  -- Offset Source mux
  with OSelect select OSource <=
    "0000000000" & IR(13) & IR(11 downto 10) & IR(2 downto 0) when "00",
    x"FFFF" when "01",
    x"0001" when "10",
    x"0001" when others;

  -- Address is address source plus offset
  Address <= ASource + OSource;

  -- This mux controls the pre/post increment
  with PrePost select DABus <=
    Address when '0',
    ASource when '1',
    Address when others;

  -- This mux controls the value that goes into the register array
  with DMux select DBusOut <=
    ALUOut when "00",
    DBusIn when "01",
    IR(11 downto 8) & IR(3 downto 0) when "10",   -- For LDI
    RegB when "11",                               -- For MOV
    ALUOut when others;

  process(clock)
  begin
    if (clock = '1') then
      IR_delay <= ProgDB;
    end if;
  end process;

end DUNIT_ARCH;
