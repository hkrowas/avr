----------------------------------------------------------------------------
--
--  Atmel AVR ALU Test Entity Declaration
--
--  This is the entity declaration which must be used for building the ALU
--  portion of the AVR design for testing.
--
--  Revision History:
--     17 Apr 98  Glen George       Initial revision.
--     20 Apr 98  Glen George       Fixed minor syntax bugs.
--     18 Apr 04  Glen George       Updated comments and formatting.
--     21 Jan 06  Glen George       Updated comments.
--     04 Feb 17  Torkom P          Added architecture for alu test with cunit
--
----------------------------------------------------------------------------


--
--  ALU_TEST
--
--  This is the ALU testing interface.  It just brings all the important
--  ALU signals out for testing along with the Instruction Register.
--
--  Inputs:
--    IR       - Instruction Register (16 bits)
--    OperandA - first operand to ALU (8 bits) - looks like the output
--               of the register array
--    OperandB - second operand to ALU (8 bits) - looks like the output
--               of the register array
--    clock    - the system clock
--
--  Outputs:
--    Result   - result of the ALU operation selected by the Instruction
--               Register (8 bits)
--    StatReg  - Status Register contents (8 bits)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  ALU_TEST  is

    port(
        IR        :  in  opcode_word;                       -- Instruction Register
        OperandA  :  in  std_logic_vector(7 downto 0);      -- first operand
        OperandB  :  in  std_logic_vector(7 downto 0);      -- second operand
        clock     :  in  std_logic;                         -- system clock
        Result    :  out std_logic_vector(7 downto 0);      -- ALU result
        StatReg   :  out std_logic_vector(7 downto 0)       -- status register
    );

end  ALU_TEST;


architecture ALU_TEST_ARCH of ALU_TEST is
    component ALU
    port(
        OperandA  :  in  std_logic_vector(7 downto 0);    -- first operand
        OperandB  :  in  std_logic_vector(7 downto 0);    -- second operand
        AluOp     :  in  std_logic_vector(5 downto 0);    -- ALU operation to perform
        StatRegIn :  in  std_logic_vector(7 downto 0);    -- status register from previous
        Result    :  out std_logic_vector(7 downto 0);    -- ALU result
        StatRegOut:  out std_logic_vector(7 downto 0)     -- status register output
    );
    end component;

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

    component SR
    port(
        RegIn   :  in  std_logic_vector(7 downto 0);    -- DFF input
        Mask    :  in  std_logic_vector(7 downto 0);
        clock   :  in  std_logic;
        RegOut  :  buffer std_logic_vector(7 downto 0)
    );
    end component;

    signal FlagMask     :  std_logic_vector(7 downto 0); -- signal for the flag mask from the cunit
    signal StatRegOut   :  std_logic_vector(7 downto 0); -- signal out of the ALU
    signal ALUOp        :  std_logic_vector(5 downto 0); -- alu operation from the cunit
	 signal StatusRegister : std_logic_vector(7 downto 0); -- status register signal within cpu


begin

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
      IR => IR,
	  SR => StatusRegister,
      clock => clock,
      ALUOp => ALUOp,
      FlagMask => FlagMask
    );

    status_register : SR
    port map(
        RegIn => StatRegOut,
        Mask => FlagMask,
        clock => clock,
        RegOut => StatusRegister
    );

	 StatReg <= StatusRegister;

end ALU_TEST_ARCH;
