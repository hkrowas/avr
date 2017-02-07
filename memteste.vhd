----------------------------------------------------------------------------
--
--  Atmel AVR Data Memory Test Entity Declaration
--
--  This is the entity declaration which must be used for building the data
--  memory access portion of the AVR design for testing.
--
--  Revision History:
--     24 Apr 98  Glen George       Initial revision.
--     25 Apr 00  Glen George       Fixed entity name and updated comments.
--      2 May 02  Glen George       Updated comments.
--      3 May 02  Glen George       Fixed Reset signal type.
--     23 Jan 06  Glen George       Updated comments.
--     21 Jan 08  Glen George       Updated comments.
--
----------------------------------------------------------------------------


--
--  MEM_TEST
--
--  This is the data memory access testing interface.  It just brings all
--  the important data memory access signals out for testing along with the
--  Instruction Register and Program Data Bus.
--
--  Inputs:
--    IR     - Instruction Register (16 bits)
--    ProgDB - program memory data bus (16 bits)
--    Reset  - active low reset signal
--    clock  - the system clock
--
--  Outputs:
--    DataAB - data memory address bus (16 bits)
--    DataDB - data memory data bus (8 bits)
--    DataRd - data read (active low)
--    DataWr - data write (active low)


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  MEM_TEST  is

    port (
        IR      :  in     opcode_word;                      -- Instruction Register
        ProgDB  :  in     std_logic_vector(15 downto 0);    -- second word of instruction
        Reset   :  in     std_logic;                        -- system reset signal (active low)
        clock   :  in     std_logic;                        -- system clock
        DataAB  :  out    std_logic_vector(15 downto 0);    -- data address bus
        DataDB  :  inout  std_logic_vector(7 downto 0);     -- data data bus
        DataRd  :  out    std_logic;                        -- data read (active low)
        DataWr  :  out    std_logic                         -- data write (active low)
    );

end  MEM_TEST;

architecture MEM_TEST_ARCH of MEM_TEST is
  component CUNIT
    port (
      IR       :  in  opcode_word;
      SR       :  in  std_logic_vector(7 downto 0);
      clock    :  in  std_logic;
      DataRd   :  out std_logic;
      DataWr   :  out std_logic;
      PrePost  :  out std_logic;
      SP_EN    :  out std_logic;
      Con      :  out std_logic_vector(7 downto 0);
      ConSel   :  out std_logic;
      ALUOp    :  out std_logic_vector(5 downto 0);
      En       :  out std_logic;
      EnW      :  out std_logic;
      DMux     :  out std_logic_vector(1 downto 0);
      WSel     :  out std_logic_vector(1 downto 0);
      SelA     :  out std_logic_vector(4 downto 0);
      SelB     :  out std_logic_vector(4 downto 0);
      ISelect  :  out std_logic_vector(1 downto 0);
      DBaseSelect :  out std_logic_vector(2 downto 0);
      DOffSelect  :  out std_logic_vector(1 downto 0);
      FlagMask    :  out std_logic_vector(7 downto 0)
    );
  end component;
  component DUNIT
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
  end component;
  component SP
    port(
        SPin   :  in  std_logic_vector(15 downto 0);    -- DFF input
        clock  :  in  std_logic;
        Reset  :  in  std_logic;
        En_SP  :  in  std_logic;
        SPOut  :  buffer  std_logic_vector(15 downto 0)    -- DFF output
    );
  end component;
  component REG
      port(
          RegIn    :  in  std_logic_vector(7 downto 0);       -- input register bus
          clock    :  in  std_logic;                          -- system clock
          En       :  in  std_logic;                          -- Write enable
          EnW      :  in  std_logic;
          WSel     :  in  std_logic_vector(1 downto 0);
          SelA     :  in  std_logic_vector(4 downto 0);
          SelB     :  in  std_logic_vector(4 downto 0);
          Address  :  in  std_logic_vector(15 downto 0);
          RegA     :  out std_logic_vector(7 downto 0);       -- register bus A out
          RegB     :  out std_logic_vector(7 downto 0);       -- register bus B out
          XReg     :  out std_logic_vector(15 downto 0);
          YReg     :  out std_logic_vector(15 downto 0);
          ZReg     :  out std_logic_vector(15 downto 0)
      );
  end component;

  signal PrePost  :  std_logic;
  signal SP_En    :  std_logic;
  signal En       :  std_logic;
  signal EnW      :  std_logic;
  signal DMux     :  std_logic_vector(1 downto 0);
  signal WSel     :  std_logic_vector(1 downto 0);
  signal DBaseSelect :  std_logic_vector(2 downto 0);
  signal DOffSelect  :  std_logic_vector(1 downto 0);
  signal SelA   :  std_logic_vector(4 downto 0);
  signal SelB   :  std_logic_vector(4 downto 0);

  signal XReg   :  std_logic_vector(15 downto 0);
  signal YReg   :  std_logic_vector(15 downto 0);
  signal ZReg   :  std_logic_vector(15 downto 0);
  signal RegB   :  std_logic_vector(7 downto 0);
  signal RegIn  :  std_logic_vector(7 downto 0);
  signal SP_Out : std_logic_vector(15 downto 0);
  signal Address : std_logic_vector(15 downto 0);

  signal DBBuffer : std_logic_vector(7 downto 0);
  signal DataWr_buffer : std_logic;

begin
  control_unit : CUNIT
    port map (
      IR => IR,
      SR => "00000000",
      PrePost => PrePost,
      SP_En => SP_En,
      En => En,
      EnW => EnW,
      DMux => DMux,
      SelA => SelA,
      SelB => SelB,
      WSel => WSel,
      DBaseSelect => DBaseSelect,
      DOffSelect => DOffSelect,
      clock => clock,
      DataRd => DataRd,
      DataWr => DataWr_buffer
    );
  data_unit : DUNIT
    port map (
      clock => clock,
      IR => IR,
      DABus => DataAB,
      XReg => XReg,
      YReg => YReg,
      ZReg => ZReg,
      ASelect => DBaseSelect,
      OSelect => DOffSelect,
      PrePost => PrePost,
      SP => SP_Out,
      DBusIn => DataDB,
      RegB   => RegB,
      ProgDB => ProgDB,
      ALUOut =>  x"00",
      DMux => DMux,
      DBusOut => RegIn,
      Address => Address
    );
  stack_pointer : SP
    port map (
      clock => clock,
      Reset => Reset,
      SPOut => SP_Out,
      SPIn => Address,
      En_SP => SP_En
    );
  reg_array : REG
    port map (
      RegIn => RegIn,
      clock => clock,
      En => En,
      EnW => EnW,
      WSel => WSel,
      SelA => SelA,
      SelB => SelB,
      Address => Address,
      RegA => DBBuffer,
      RegB => RegB,
      XReg => XReg,
      YReg => YReg,
      ZReg => ZReg
    );

  -- This is a tristate buffer for the databus. Goes lo-z when DataWr goes active.
  with DataWr_buffer select DataDB <=
    "ZZZZZZZZ" when '1',
    DBBuffer   when '0',
    "ZZZZZZZZ" when others;

  DataWr <= DataWr_buffer;
end MEM_TEST_ARCH;
