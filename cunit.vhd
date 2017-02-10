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
--  The centrel unit for the AVR.
--
--  Inputs:
--    IR  -  Instruction register for instruction decoding
--    SR  -  Status register for branching
--    clock
--
--  Outputs:
--    Con  - constant operand
--    ConSel - Selects whether to use a constant as the second ALU operand
--    ALUOp - Operation code sent to ALU (maybe some substring of instruction opcode)
--    En  -  Register array write enable
--    SelA  -  Register A select (to ALU)
--    SelB  -  Register B select (to ALU)
--    ISelect  -  Instruction access unit source select
--    DBaseSelect  -  Data access unit base select
--    BOffSelect   -  Data access unit offset select
--    FlagMask  -  SR mask. Set bits indicate that flag changes with instruction.
--    ALUOp - Operation sent to ALU
--            "----00"   F-Block select
--            "----01"   Add/Sub select
--            "----10"   Shifter select
--            "----11"   Misc select
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
        Con      :  out std_logic_vector(7 downto 0);
        ConSel   :  out std_logic;
        ALUOp    :  out std_logic_vector(5 downto 0);
        En       :  out std_logic;
        SelA     :  out std_logic_vector(4 downto 0);
        SelB     :  out std_logic_vector(4 downto 0);
        ISelect  :  out std_logic_vector(1 downto 0);
        DBaseSelect :  out std_logic_vector(1 downto 0);
        BOffSelect  :  out std_logic_vector(1 downto 0);
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
  constant ALU_ADIW  :  std_logic_vector(5 downto 0) := ALU_ADD;
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
  constant ALU_NEG   :  std_logic_vector(5 downto 0) := "000101";
  constant ALU_OR    :  std_logic_vector(5 downto 0) := "111000";
  constant ALU_ORI   :  std_logic_vector(5 downto 0) := ALU_OR;
  constant ALU_ROR   :  std_logic_vector(5 downto 0) := "001010";
  constant ALU_SBC   :  std_logic_vector(5 downto 0) := "001101";
  constant ALU_SBCI  :  std_logic_vector(5 downto 0) := ALU_SBC;
  constant ALU_SBIW  :  std_logic_vector(5 downto 0) := ALU_SUB;
  constant ALU_SUBI  :  std_logic_vector(5 downto 0) := ALU_SUB;
  constant ALU_SWAP  :  std_logic_vector(5 downto 0) := "000111";

  signal count  :  std_logic;       -- counter for 2 clock instructions

begin
  --SelB <= IR(9) & IR(3 downto 0);   -- SelB is this for all opcodes

  process(IR, SR, clock, count)
  begin
    -- All opcodes. This section controls En and the flag mask, which are both
    -- specific to the instruction.
    En <= 'X';
    ALUOp <= "XXXXXX";
    SelA <= "XXXXX";
    SelB <= "XXXXX";
    FlagMask <= "XXXXXXXX";
    Count <= 'X';
    Con <= "XXXXXXXX";
    ConSel <= 'X';
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
      if (count = '0') then
        ALUOp <= ALU_ADD;
      else
        ALUOp <= ALU_ADC;
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
      if (count = '0') then
        ALUOp <= ALU_SUB;
      else
        ALUOp <= ALU_SBC;
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

    -- This section controls the value of SelA and Con based on the opcode

    -- If word instruction
    if (std_match(IR, OpSBIW) or std_match(IR, OpADIW)) then
      ConSel <= '1';
      if (count = '0') then
        Con <= "00" & IR(7 downto 6) & IR(3 downto 0);
        SelA <= "11" & IR(5 downto 4) & "0";
      else
        Con <= "0000000" & SR(0);
        SelA <= "11" & IR(5 downto 4) & "1";
      end if;
    end if;

    -- If an immediate instruction
    if (std_match(IR, OpANDI) or std_match(IR, OpCPI) or std_match(IR, OpORI)
      or std_match(IR, OpSBCI) or std_match(IR, OpSUBI)) then
      ConSel <= '1';
      SelA <= "1" & IR(7 downto 4);
      Con <= IR(11 downto 8) & IR(3 downto 0);
    end if;

    -- If not immediate or word.
    if (not(std_match(IR, OpANDI) or std_match(IR, OpCPI) or std_match(IR, OpORI)
      or std_match(IR, OpSBCI) or std_match(IR, OpSUBI) or std_match(IR, OpSBIW)
      or std_match(IR, OpADIW))) then
      ConSel <= '0';
      Con <= IR(11 downto 8) & IR(3 downto 0);
      SelA <= IR(8 downto 4);
    end if;
  end process;

  -- This process controls the finite state machine for instruction decoding.
  process (clock)
  begin
    if(rising_edge(clock)) then
      -- Counter used for multiclock instructions
      if (std_match(IR, OpSBIW) or std_match(IR, OpADIW)) then
        count <= not(count);
      else
        count <= '0';
      end if;
    end if;
  end process;
end CUNIT_ARCH;
