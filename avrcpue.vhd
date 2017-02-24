----------------------------------------------------------------------------
--
--  Atmel AVR CPU Entity Declaration
--
--  This is the entity declaration for the complete AVR CPU.  The design
--  should implement this entity to make testing possible.
--
--  Revision History:
--     11 May 98  Glen George       Initial revision.
--      9 May 00  Glen George       Updated comments.
--      7 May 02  Glen George       Updated comments.
--     21 Jan 08  Glen George       Updated comments.
--     2016-02-18  Harrison Krowas    Added architecture
--
----------------------------------------------------------------------------


--
--  AVR_CPU
--
--  This is the complete entity declaration for the AVR CPU.  It is used to
--  test the complete design.
--
--  Inputs:
--    ProgDB - program memory data bus (16 bits)
--    Reset  - active low reset signal
--    INT0   - active low interrupt
--    INT1   - active low interrupt
--    clock  - the system clock
--
--  Outputs:
--    ProgAB - program memory address bus (16 bits)
--    DataAB - data memory address bus (16 bits)
--    DataWr - data write signal
--    DataRd - data read signal
--
--  Inputs/Outputs:
--    DataDB - data memory data bus (8 bits)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  AVR_CPU  is

    port (
        ProgDB  :  in     std_logic_vector(15 downto 0);   -- program memory data bus
        Reset   :  in     std_logic;                       -- reset signal (active low)
        INT0    :  in     std_logic;                       -- interrupt signal (active low)
        INT1    :  in     std_logic;                       -- interrupt signal (active low)
        clock   :  in     std_logic;                       -- system clock
        ProgAB  :  out    std_logic_vector(15 downto 0);   -- program memory address bus
        DataAB  :  out    std_logic_vector(15 downto 0);   -- data memory address bus
        DataWr  :  out    std_logic;                       -- data memory write enable (active low)
        DataRd  :  out    std_logic;                       -- data memory read enable (active low)
        DataDB  :  inout  std_logic_vector(7 downto 0)     -- data memory data bus
    );


end  AVR_CPU;

architecture AVR_CPU_ARCH of AVR_CPU is
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
  component IR
    port(
        IRIn   :  in  std_logic_vector(15 downto 0);    -- DFF input
        IR_en  :  in  std_logic;
        clock  :  in  std_logic;
        IROut  :  buffer  std_logic_vector(15 downto 0)    -- DFF output
    );
  end component;
  component ALU
    port(
        OperandA  :  in  std_logic_vector(7 downto 0);    -- first operand
        OperandB  :  in  std_logic_vector(7 downto 0);    -- second operand
        AluOp     :  in  std_logic_vector(5 downto 0);    -- ALU operation to perform
        StatRegIn :  in  std_logic_vector(7 downto 0);
        Result    :  out std_logic_vector(7 downto 0);    -- ALU result
        StatRegOut:  out std_logic_vector(7 downto 0)     -- status register
    );
  end component;
  component SR
    port(
        RegIn   :  in  std_logic_vector(7 downto 0);    -- DFF input
        Mask    :  in  std_logic_vector(7 downto 0);
        clock   :  in  std_logic;
        RegOut  :  buffer std_logic_vector(7 downto 0)
    );
  end component;
  component CUNIT
    port (
        IR       :  in  opcode_word;
        SR       :  in  std_logic_vector(7 downto 0);
        clock    :  in  std_logic;
        SReg     :  in  std_logic_vector(7 downto 0);
        ProgDB   :  in  std_logic_vector(15 downto 0);
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
        IR_en    :  buffer std_logic;
        PC_en    :  out std_logic;
        PC_load  :  out std_logic;
        SelPC    :  out std_logic_vector(2 downto 0);
        IR_Buf   : out std_logic_vector(15 downto 0);
        DBaseSelect :  out std_logic_vector(2 downto 0);
        DOffSelect  :  out std_logic_vector(1 downto 0);
        DataOutSel  :  out std_logic_vector(1 downto 0);
        FlagMask    :  out std_logic_vector(7 downto 0)
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

  signal Con  :  std_logic_vector(7 downto 0);
  signal ConSel  :  std_logic;

  signal OperandA  :  std_logic_vector(7 downto 0);
  signal OperandB  :  std_logic_vector(7 downto 0);
  signal ALUOp  :  std_logic_vector(5 downto 0);

  signal IR_out  :  std_logic_vector(15 downto 0);
  signal IR_en : std_logic;
  signal IR_buf : std_logic_vector(15 downto 0);

  signal StatusRegister : std_logic_vector(7 downto 0);
  signal StatRegOut  :  std_logic_vector(7 downto 0);
  signal FlagMask  :  std_logic_vector(7 downto 0);

  signal PC_en : std_logic;
  signal PC_load : std_logic;
  signal SelPC  :  std_logic_vector(2 downto 0);

  signal Result : std_logic_vector(7 downto 0);

  signal DataOutSel  :  std_logic_vector(1 downto 0);
  signal RegA  :  std_logic_vector(7 downto 0);
  signal PC_high  :  std_logic_vector(7 downto 0);
  signal PC_low  :  std_logic_vector(7 downto 0);
  signal PC  :  std_logic_vector(15 downto 0);

begin
  dataWr <= DataWr_Buffer;
  PC_high <= PC(15 downto 8);
  PC_low <= PC(7 downto 0);
  data_unit : DUNIT
    port map (
      clock => clock,
      IR => IR_out,
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
      ALUOut => Result,
      DMux => DMux,
      DBusOut => RegIn,
      Address => Address
    );

  stack_pointer : SP
    port map (
      clock => clock,
      Reset => Reset,
      En_SP => SP_en,
      SPIn => Address,
      SPout => SP_out
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
      RegA => RegA,
      RegB => RegB,
      XReg => XReg,
      YReg => YReg,
      ZReg => ZReg
    );

  arithmetic_logic_unit : ALU
    port map (
      OperandA      =>  OperandA,
      OperandB      =>  OperandB,
      AluOp         =>  ALUOp,
      StatRegIn     =>  StatusRegister,
      Result        =>  Result,
      StatRegOut    =>  StatRegOut
    );
  control_unit : CUNIT
    port map (
      IR => IR_out,
      SR => StatusRegister,
      clock => clock,
      ProgDB => ProgDB,
      DataRd => DataRd,
      DataWr => DataWr_Buffer,
      PrePost => PrePost,
      SP_EN => SP_en,
      Con => Con,
      ConSel => ConSel,
      ALUOp => ALUOp,
      En => En,
      EnW => EnW,
      DMux => DMux,
      SelA => SelA,
      SelB => SelB,
      WSel => WSel,
      IR_en => IR_en,
      PC_en => PC_en,
      PC_load => PC_load,
      SelPC => SelPC,
      IR_buf => IR_buf,
      DBaseSelect => DBaseSelect,
      DOffSelect => DOffSelect,
      DataOutSel => DataOutSel,
      FlagMask => FlagMask
    );

  status_register : SR
    port map (
        RegIn => StatRegOut,
        Mask => FlagMask,
        clock => clock,
        RegOut => StatusRegister
    );

  instruction_register : IR
    port map (
      IRIn => ProgDB,
      IR_en => IR_en,
      clock => clock,
      IROut => IR_out
    );

    with DataOutSel select DBBuffer <=
      RegA  when  "00",
      PC_high when "01",
      PC_low when  "10",
      RegA when others;

    with DataWr_buffer select DataDB <=
      "ZZZZZZZZ" when '1',
      DBBuffer   when '0',
      "ZZZZZZZZ" when others;

    with ConSel select OperandB <=
      RegB when '0',
      Con   when '1',
      RegB when others;

end AVR_CPU_ARCH;
