----------------------------------------------------------------------------
--
--  Atmel AVR Control Unit
--
--  This is the entity declaration for the Atmel AVR control unit.
--
--  Revision History:
--     2016-01-24     Initial Revision       Harrison Krowas
--     2016-02-02     Added ALUOp decoding   Harrison Krowas
--
----------------------------------------------------------------------------
--
--
--  CUNIT
--
--  The control unit for the AVR. It includes an instruction decoder and a state
--  machine for controlling external blocks with multicycle instructions. It
--  controls the register array, the data access unit, the instruction address
--  unit, the flagmask for the SR, the enable for the SP, the R/W lines for
--  memory access, and sends an op code to the ALU for arithmetic operations.
--
--  Inputs:
--    IR  -  Instruction register for instruction decoding
--    SR  -  Status register for branching
--    clock
--
--  Outputs:
--    DataRd - Data read enable (active low)
--    DataWr - Data write enable (active low)
--    SP_EN - Write enable for SP for PUSH/POP
--    PrePost - Pre/Post increment select
--    Con  - constant operand
--    ConSel - Selects whether to use a constant as the second ALU operand
--    ALUOp - Operation code sent to ALU (maybe some substring of instruction opcode)
--    En  -  Register array write enable
--    EnW - Word write to register array
--    DMux - Mux select for the data unit, which outputs to RegIn
--           "00" ALUOut
--           "01" DataBus
--           "10" IR constant
--           "11" RegB for MOV instruction
--    WSel - Word write select to register array
--    SelA  -  Register A select (to ALU)
--    SelB  -  Register B select (to ALU)
--    ISelect  -  Instruction access unit source select
--    DBaseSelect  -  Data access unit base select
--    BOffSelect   -  Data access unit offset select
--    FlagMask  -  SR mask. Set bits indicate that flag changes with instruction.
--    ALUOp - Operation sent to ALU
--              "----00"   F-Block select
--              "----01"   Add/Sub select
--              "----10"   Shifter select
--              "----11"   Misc select
--            F-Block
--              "000000"   0
--              "000100"   A nor B
--              "001100"   not A
--              "010100"   not B
--              "011000"   A xor B
--              "011100"   A nand B
--              "100000"   A and B
--              "100100"   A xnor B
--              "111000"   A or B
--              "111100"   1
--            Add/Sub
--              "--0001"   add
--              "--0101"   subtract
--              "--1001"   add with carry
--              "--1101"   subtract with carry
--            Shifter
--              "010010"   LSR
--              "000110"   ASR
--              "001010"   ROR
--              "100010"   RRC
--            Misc
--              "000011"   BST
--              "000111"   SWAP
--              "001011"   BLD
--              "010011"   BSET
--              "100011"   BCLR


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  CUNIT  is
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
end  CUNIT;

architecture CUNIT_ARCH of CUNIT is
  -- Status Register Constants
  constant I  :  std_logic_vector(7 downto 0) := x"80";
  constant T  :  std_logic_vector(7 downto 0) := x"40";
  constant H  :  std_logic_vector(7 downto 0) := x"20";
  constant S  :  std_logic_vector(7 downto 0) := x"10";
  constant V  :  std_logic_vector(7 downto 0) := x"08";
  constant N  :  std_logic_vector(7 downto 0) := x"04";
  constant Z  :  std_logic_vector(7 downto 0) := x"02";
  constant C  :  std_logic_vector(7 downto 0) := x"01";

  -- ALUOp  Constants
  constant ALU_ADC   :  std_logic_vector(5 downto 0) := "001001";
  constant ALU_ADD   :  std_logic_vector(5 downto 0) := "000001";
  constant ALU_ADIW  :  std_logic_vector(5 downto 0) := "110001";
  constant ALU_AND   :  std_logic_vector(5 downto 0) := "100000";
  constant ALU_ANDI  :  std_logic_vector(5 downto 0) := ALU_AND;
  constant ALU_ASR   :  std_logic_vector(5 downto 0) := "000110";
  constant ALU_BCLR  :  std_logic_vector(5 downto 0) := "100011";
  constant ALU_BLD   :  std_logic_vector(5 downto 0) := "001011";
  constant ALU_BSET  :  std_logic_vector(5 downto 0) := "010011";
  constant ALU_BST   :  std_logic_vector(5 downto 0) := "000011";
  constant ALU_COM   :  std_logic_vector(5 downto 0) := "001100";
  constant ALU_CP    :  std_logic_vector(5 downto 0) := "000101";
  constant ALU_CPC   :  std_logic_vector(5 downto 0) := "001101";
  constant ALU_CPI   :  std_logic_vector(5 downto 0) := ALU_CP;
  constant ALU_SUB   :  std_logic_vector(5 downto 0) := "000101";
  constant ALU_DEC   :  std_logic_vector(5 downto 0) := "010101";
  constant ALU_EOR   :  std_logic_vector(5 downto 0) := "011000";
  constant ALU_INC   :  std_logic_vector(5 downto 0) := "010001";
  constant ALU_LSR   :  std_logic_vector(5 downto 0) := "100010";
  constant ALU_NEG   :  std_logic_vector(5 downto 0) := "100101";
  constant ALU_OR    :  std_logic_vector(5 downto 0) := "111000";
  constant ALU_ORI   :  std_logic_vector(5 downto 0) := ALU_OR;
  constant ALU_ROR   :  std_logic_vector(5 downto 0) := "001010";
  constant ALU_SBC   :  std_logic_vector(5 downto 0) := "001101";
  constant ALU_SBCI  :  std_logic_vector(5 downto 0) := ALU_SBC;
  constant ALU_SBIW  :  std_logic_vector(5 downto 0) := "110101";
  constant ALU_SUBI  :  std_logic_vector(5 downto 0) := ALU_SUB;
  constant ALU_SWAP  :  std_logic_vector(5 downto 0) := "000111";

  -- DBaseSelect Constants
  constant XReg : std_logic_vector(2 downto 0) := "000";
  constant YReg : std_logic_vector(2 downto 0) := "001";
  constant ZReg : std_logic_vector(2 downto 0) := "010";
  constant IR_SEL : std_logic_vector(2 downto 0) := "011";
  constant SP_SEL : std_logic_vector(2 downto 0) := "100";

  -- DOffSelect Constants
  constant const : std_logic_vector(1 downto 0) := "00";
  constant neg_one : std_logic_vector(1 downto 0) := "01";
  constant one : std_logic_vector(1 downto 0) := "10";

  signal count  :  std_logic_vector(1 downto 0);       -- counter for 2 clock instructions

  -- Type for Instruction Decoding State machine
  type i_states is (
    IDLE,             -- State for 1 cycle instructions
    WORD_INSTRUCTION, -- State for 2 cycle word operation instructions
    READ_INSTRUCTION, -- 2 Cycle read instruction
    WRITE_INSTRUCTION,-- 2 Cycle write instruction
    STS_INSTRUCTION,  -- For STS
    LDS_INSTRUCTION,  -- For LDS
    MEM_END           -- Last cycle of STS and LDS
  );

  signal IState  :  i_states;

begin

  process(IR, SR, clock, count)
  begin
    -- All opcodes. This section controls En and the flag mask, which are both
    -- specific to the instruction.
    En <= '-';
    PrePost <= '-';
    ALUOp <= "------";
    SelA <= "-----";
    SelB <= "00000";
    FlagMask <= "00000000";
    Con <= "--------";
    ConSel <= '-';
    SP_EN <= '0';     -- Default is to not change SP
    EnW <= '0';       -- Default is to not word write
    DBaseSelect <= "---";
    DOffSelect <= "--";
    WSel <= "--";
    DMux <= "00";

----------- ALU Operations------------------------------------------------

    if (std_match(IR, OpADC)) then
      En <= '1';
      ALUOp <= ALU_ADC;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (std_match(IR, OpADD)) then
      En <= '1';
      ALUOp <= ALU_ADD;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (std_match(IR, OpADIW)) then
      En <= '1';
      if (count = "0") then
        ALUOp <= ALU_ADD;
      else
        ALUOp <= "111001";
      end if;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S;
    end if;
    if (std_match(IR, OpAND)) then
      En <= '1';
      ALUOp <= ALU_AND;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or N or V or S;
    end if;
    if (std_match(IR, OpANDI)) then
      En <= '1';
      ALUOp <= ALU_ANDI;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or N or V or S;
    end if;
    if (std_match(IR, OpASR)) then
      En <= '1';
      ALUOp <= ALU_ASR;
      SelB <= IR(8 downto 4);
      FlagMask <= Z or C or N or V or S;
    end if;
    if (std_match(IR, OpBCLR)) then
      En <= '0';
      ALUOp <= ALU_BCLR;
      SelB <= IR(9) & IR(3 downto 0);
      -- This for loop calculates the flag mask based on the instruction
      for i in 7 downto 0 loop
        if (i = conv_integer(IR(6 downto 4))) then
          FlagMask(i) <= '1';
        else
          FlagMask(i) <= '0';
        end if;
      end loop;
    end if;
    if (std_match(IR, OpBLD)) then
      En <= '1';
      ALUOp <= ALU_BLD;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= x"00";
    end if;
    if (std_match(IR, OpBSET)) then
      En <= '0';
      ALUOp <= ALU_BSET;
      SelB <= IR(9) & IR(3 downto 0);
      -- This for loop calculates the flag mask based on the instruction
      for i in 7 downto 0 loop
        if (i = conv_integer(IR(6 downto 4))) then
          FlagMask(i) <= '1';
        else
          FlagMask(i) <= '0';
        end if;
      end loop;
    end if;
    if (std_match(IR, OpBST)) then
      En <= '0';
      ALUOp <= ALU_BST;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= T;
    end if;
    if (std_match(IR, OpCOM)) then
      En <= '1';
      ALUOp <= ALU_COM;
      SelB <= IR(8 downto 4);
      FlagMask <= Z or C or N or V or S;
    end if;
    if (std_match(IR, OpCP)) then
      En <= '0';
      ALUOp <= ALU_CP;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (std_match(IR, OpCPC)) then
      En <= '0';
      ALUOp <= ALU_CPC;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (std_match(IR, OpCPI)) then
      En <= '0';
      ALUOp <= ALU_CPI;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (std_match(IR, OpDEC)) then
      En <= '1';
      ALUOp <= ALU_DEC;
      SelB <= IR(8 downto 4);
      FlagMask <= Z or N or V or S;
    end if;
    if (std_match(IR, OpEOR)) then
      En <= '1';
      ALUOp <= ALU_EOR;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or N or V or S;
    end if;
    if (std_match(IR, OpINC)) then
      En <= '1';
      ALUOp <= ALU_INC;
      SelB <= IR(8 downto 4);
      FlagMask <= Z or N or V or S;
    end if;
    if (std_match(IR, OpLSR)) then
      En <= '1';
      ALUOp <= ALU_LSR;
      SelB <= IR(8 downto 4);
      FlagMask <= Z or C or N or V or S;
    end if;
    if (std_match(IR, OpMUL)) then
      En <= '1';
      --ALUOp <= ALU_MUL;
      FlagMask <= C;
      SelB <= IR(9) & IR(3 downto 0);
    end if;
    if (std_match(IR, OpNEG)) then
      En <= '1';
      ALUOp <= ALU_NEG;
      SelB <= IR(8 downto 4);
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (std_match(IR, OpOR)) then
      En <= '1';
      ALUOp <= ALU_OR;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or N or V or S;
    end if;
    if (std_match(IR, OpORI)) then
      En <= '1';
      ALUOp <= ALU_ORI;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or N or V or S;
    end if;
    if (std_match(IR, OpROR)) then
      En <= '1';
      ALUOp <= ALU_ROR;
      SelB <= IR(8 downto 4);
      FlagMask <= Z or C or N or V or S;
    end if;
    if (std_match(IR, OpSBC)) then
      En <= '1';
      ALUOp <= ALU_SBC;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (std_match(IR, OpSBCI)) then
      En <= '1';
      ALUOp <= ALU_SBCI;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (std_match(IR, OpSBIW)) then
      En <= '1';
      if (count = "0") then
        ALUOp <= ALU_SUB;
      else
        ALUOp <= "111101";
      end if;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S;
    end if;
    if (std_match(IR, OpSUB)) then
      En <= '1';
      ALUOp <= ALU_SUB;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (std_match(IR, OpSUBI)) then
      En <= '1';
      ALUOp <= ALU_SUBI;
      SelB <= IR(9) & IR(3 downto 0);
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (std_match(IR, OpSWAP)) then
      En <= '1';
      ALUOp <= ALU_SWAP;
      SelB <= IR(8 downto 4);
      FlagMask <= x"00";
    end if;

--------- Data Access Operations----------------------------------------------

    if (std_match(IR, OpLDX)) then
      DMux <= "01";
      if (count = "00") then
        En <= '0';
      end if;
      if (count = "01") then
        En <= '1';
      end if;
      DBaseSelect <= XReg;
      PrePost <= '1';
    end if;
    if (std_match(IR, OpLDXI)) then
      DMux <= "01";
      if (count = "00") then
        EnW <= '0';
        En <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
        En <= '1';
      end if;
      DBaseSelect <= XReg;
      DOffSelect <= one;
      PrePost <= '1';
      WSel <= XReg(1 downto 0);
    end if;
    if (std_match(IR, OpLDXD)) then
      DMux <= "01";
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '1';
      DBaseSelect <= XReg;
      DOffSelect <= neg_one;
      PrePost <= '0';
      WSel <= XReg(1 downto 0);
    end if;
    if (std_match(IR, OpLDYI)) then
      DMux <= "01";
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '1';
      DBaseSelect <= YReg;
      DOffSelect <= one;
      PrePost <= '1';
      WSel <= YReg(1 downto 0);
    end if;
    if (std_match(IR, OpLDYD)) then
      DMux <= "01";
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '1';
      DBaseSelect <= YReg;
      DOffSelect <= neg_one;
      PrePost <= '0';
      WSel <= YReg(1 downto 0);
    end if;
    if (std_match(IR, OpLDZI)) then
      DMux <= "01";
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '1';
      DBaseSelect <= ZReg;
      DOffSelect <= one;
      PrePost <= '1';
      WSel <= ZReg(1 downto 0);
    end if;
    if (std_match(IR, OpLDZD)) then
      DMux <= "01";
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '1';
      DBaseSelect <= ZReg;
      DOffSelect <= neg_one;
      PrePost <= '0';
      WSel <= ZReg(1 downto 0);
    end if;
    if (std_match(IR, OpLDDY)) then
      DMux <= "01";
      En <= '1';
      DBaseSelect <= YReg;
      DOffSelect <= const;
      PrePost <= '0';
    end if;
    if (std_match(IR, OpLDDZ)) then
      DMux <= "01";
      En <= '1';
      DBaseSelect <= ZReg;
      DOffSelect <= const;
      PrePost <= '0';
    end if;
    if (std_match(IR, OpLDS)) then
      DMux <= "01";
      En <= '1';
      DBaseSelect <= IR_SEL;
      PrePost <= '1';
    end if;
    if (std_match(IR, OpSTX)) then
      En <= '0';
      DBaseSelect <= XReg;
      PrePost <= '1';
    end if;
    if (std_match(IR, OpSTXI)) then
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '0';
      DBaseSelect <= XReg;
      DOffSelect <= one;
      PrePost <= '1';
      WSel <= XReg(1 downto 0);
    end if;
    if (std_match(IR, OpSTXD)) then
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '0';
      DBaseSelect <= XReg;
      DOffSelect <= neg_one;
      PrePost <= '0';
      WSel <= XReg(1 downto 0);
    end if;
    if (std_match(IR, OpSTYI)) then
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '0';
      DBaseSelect <= YReg;
      DOffSelect <= one;
      PrePost <= '1';
      WSel <= YReg(1 downto 0);
    end if;
    if (std_match(IR, OpSTYD)) then
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '0';
      DBaseSelect <= YReg;
      DOffSelect <= neg_one;
      PrePost <= '0';
      WSel <= YReg(1 downto 0);
    end if;
    if (std_match(IR, OpSTZI)) then
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '0';
      DBaseSelect <= ZReg;
      DOffSelect <= one;
      PrePost <= '1';
      WSel <= ZReg(1 downto 0);
    end if;
    if (std_match(IR, OpSTZD)) then
      if (count = "00") then
        EnW <= '0';
      end if;
      if (count = "01") then
        EnW <= '1';
      end if;
      En <= '0';
      DBaseSelect <= ZReg;
      DOffSelect <= neg_one;
      PrePost <= '0';
      WSel <= ZReg(1 downto 0);
    end if;
    if (std_match(IR, OpPOP)) then
      DMux <= "01";
      EnW <= '0';
      En <= '0';
      DBaseSelect <= SP_SEL;
      DOffSelect <= one;
      PrePost <= '0';
      if (count = "01") then
        -- Write Out SP on last cycle
        En <= '1';
        SP_EN <= '1';
      end if;
    end if;
    if (std_match(IR, OpPUSH)) then
      EnW <= '0';
      En <= '0';
      DBaseSelect <= SP_SEL;
      DOffSelect <= neg_one;
      PrePost <= '1';
      if (count = "01") then
        -- Write Out SP on last cycle
        SP_EN <= '1';
      end if;
    end if;
    -- Immediate Memory Instructions
    if (std_match(IR, OpSTS)) then
      PrePost <= '1';
      DBaseSelect <= IR_SEL;
      En <= '0';
    end if;
    if (std_match(IR, OpMOV)) then
      DMux <= "11";
      En <= '1';
      SelB <= IR(9) & IR(3 downto 0);
    end if;
    if (std_match(IR, OpLDI)) then
      DMux <= "10";
      En <= '1';
    end if;
    if (std_match(IR, OpSTDY)) then
      PrePost <= '0';
      DBaseSelect <= YReg;
      DOffSelect <= const;
      En <= '0';
    end if;
    if (std_match(IR, OpSTDZ)) then
      PrePost <= '0';
      DBaseSelect <= ZReg;
      DOffSelect <= const;
      En <= '0';
    end if;

-------- This section controls the value of SelA and Con based on the opcode----

    -- Default values
    ConSel <= '0';
    Con <= IR(11 downto 8) & IR(3 downto 0);
    SelA <= IR(8 downto 4);

    -- If word instruction
    if (std_match(IR, OpSBIW) or std_match(IR, OpADIW)) then
      ConSel <= '1';
      if (count = "00") then
        Con <= "00" & IR(7 downto 6) & IR(3 downto 0);
        SelA <= "11" & IR(5 downto 4) & "0";
      else
        Con <= "0000000" & SR(0);
        SelA <= "11" & IR(5 downto 4) & "1";
      end if;
    end if;

    -- If an immediate instruction
    if (std_match(IR, OpANDI) or std_match(IR, OpCPI) or std_match(IR, OpORI)
      or std_match(IR, OpSBCI) or std_match(IR, OpSUBI) or std_match(IR, OpLDI)) then
      ConSel <= '1';
      SelA <= "1" & IR(7 downto 4);
      Con <= IR(11 downto 8) & IR(3 downto 0);
    end if;

  end process;

----- This process controls the finite state machine for instruction decoding--
----  It also controls the DataWr/Rd to prevent glitching ----------------------

  process (clock)
  begin
    if (clock = '1') then
      case IState is
        when IDLE =>
          count <= "00";
          DataWr <= '1';
          DataRd <= '1';
          if (std_match(IR, OpSBIW) or std_match(IR, OpADIW)) then
            count <= "01";
            IState <= WORD_INSTRUCTION;
          end if;
          -- If LD instruction
          if (std_match("1001000---------", IR)
              or std_match("10-0--0---------", IR)) then
            count <= "01";
            if (std_match(OpLDS, IR)) then
              IState <= LDS_INSTRUCTION;
            else
              DataRd <= '0';
              IState <= READ_INSTRUCTION;
            end if;
          end if;
          -- If ST instruction
          if (std_match("1001001---------", IR)
              or std_match("10-0--1---------", IR)) then
            count <= "01";
            if (std_match(OpSTS, IR)) then
              IState <= STS_INSTRUCTION;
            else
              DataWr <= '0';
              IState <= WRITE_INSTRUCTION;
            end if;
          end if;
        when WORD_INSTRUCTION =>
          count <= "00";
          IState <= IDLE;
        when READ_INSTRUCTION =>
          count <= "00";
          DataRd <= '1';
          IState <= IDLE;
        when WRITE_INSTRUCTION =>
          count <= "00";
          DataWr <= '1';
          IState <= IDLE;
        when STS_INSTRUCTION =>
          count <= "10";
          DataWr <= '0';
          IState <= MEM_END;
        when LDS_INSTRUCTION =>
          count <= "10";
          DataRd <= '0';
          IState <= MEM_END;
        when MEM_END =>
          count <= "00";
          DataWr <= '1';
          DataRd <= '1';
          IState <= IDLE;
        when others =>
          count <= "00";
          DataRd <= '1';
          DataWr <= '1';
          IState <= IDLE;
      end case;
    end if;
  end process;
end CUNIT_ARCH;
