----------------------------------------------------------------------------
--
--  Atmel AVR Control Unit
--
--  This is the entity declaration for the Atmel AVR control unit.
--
--  Revision History:
--     2016-01-24     Initial Revision    Harrison Krowas
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
--    ALUOp - Operation code sent to ALU (maybe some substring of instruction opcode)
--    En  -  Register array write enable
--    SelA  -  Register A select (to ALU)
--    SelB  -  Register B select (to ALU)
--    ISelect  -  Instruction access unit source select
--    DBaseSelect  -  Data access unit base select
--    BOffSelect   -  Data access unit offset select
--    FlagMask  -  SR mask

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  CUNIT  is
    port (
        IR       :  in  std_logic_vector(15 downto 0);
        SR       :  in  std_logic_vector(15 downto 0);
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

  signal count  :  std_logic;       -- counter for 2 clock instructions

begin
  SelB <= IR(9) & IR(3 downto 0);   -- SelB is this for all opcodes

  process
  begin
    -- All opcodes
    if (IR = OpADC) then
      En <= '1';
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (IR = OpADD) then
      En <= '1';
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (IR = OpADIW) then
      En <= '1';
      FlagMask <= Z or C or N or V or S;
    end if;
    if (IR = OpAND) then
      En <= '1';
      FlagMask <= Z or N or V or S;
    end if;
    if (IR = OpANDI) then
      En <= '1';
      FlagMask <= Z or N or V or S;
    end if;
    if (IR = OpASR) then
      En <= '1';
      FlagMask <= Z or C or N or V or S;
    end if;
    if (IR = OpBCLR) then
      En <= '0';
      for i in 7 downto 0 loop
        if (i = conv_integer(IR(6 downto 4))) then
          FlagMask(i) <= '1';
        else
          FlagMask(i) <= '0';
        end if;
      end loop;
    end if;
    if (IR = OpBLD) then
      En <= '1';
      FlagMask <= x"00";
    end if;
    if (IR = OpBSET) then
      En <= '0';
      for i in 7 downto 0 loop
        if (i = conv_integer(IR(6 downto 4))) then
          FlagMask(i) <= '1';
        else
          FlagMask(i) <= '0';
        end if;
      end loop;
    end if;
    if (IR = OpBST) then
      En <= '0';
      FlagMask <= T;
    end if;
    if (IR = OpCOM) then
      En <= '1';
      FlagMask <= Z or C or N or V or S;
    end if;
    if (IR = OpCP) then
      En <= '0';
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (IR = OpCPC) then
      En <= '0';
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (IR = OpCPI) then
      En <= '0';
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (IR = OpDEC) then
      En <= '1';
      FlagMask <= Z or N or V or S;
    end if;
    if (IR = OpEOR) then
      En <= '1';
      FlagMask <= Z or N or V or S;
    end if;
    if (IR = OpINC) then
      En <= '1';
      FlagMask <= Z or N or V or S;
    end if;
    if (IR = OpLSR) then
      En <= '1';
      FlagMask <= Z or C or N or V or S;
    end if;
    if (IR = OpMUL) then
      En <= '1';
      FlagMask <= C;
    end if;
    if (IR = OpNEG) then
      En <= '1';
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (IR = OpOR) then
      En <= '1';
      FlagMask <= Z or N or V or S;
    end if;
    if (IR = OpORI) then
      En <= '1';
      FlagMask <= Z or N or V or S;
    end if;
    if (IR = OpROR) then
      En <= '1';
      FlagMask <= Z or C or N or V or S;
    end if;
    if (IR = OpSBC) then
      En <= '1';
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (IR = OpSBCI) then
      En <= '1';
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (IR = OpSBIW) then
      En <= '1';
      FlagMask <= Z or C or N or V or S;
    end if;
    if (IR = OpSUB) then
      En <= '1';
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (IR = OpSUBI) then
      En <= '1';
      FlagMask <= Z or C or N or V or S or H;
    end if;
    if (IR = OpSWAP) then
      En <= '1';
      FlagMask <= x"00";
    end if;

    -- This section controls the value of SelA and Con based on the opcode
    if (IR = OpSBIW or IR = OpADIW) then
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
    if (IR = OpANDI or IR = OpCPI or IR = OpORI or IR = OpSBCI or IR = OpSUBI) then
      ConSel <= '1';
      SelA <= "1" & IR(7 downto 4);
      Con <= IR(11 downto 8) & IR(3 downto 0);
    end if;
    if (not(IR = OpANDI or IR = OpCPI or IR = OpORI or IR = OpSBCI
      or IR = OpSUBI or IR = OpSBIW or IR = OpADIW)) then
      ConSel <= '0';
      Con <= IR(11 downto 8) & IR(3 downto 0);
      SelA <= IR(8 downto 4);
    end if;
  end process;

  process (clock)
  begin
    if(rising_edge(clock)) then
      if (IR = OpSBIW or IR = OpADIW) then
        count <= '1';
      else
        count <= '0';
      end if;
    end if;
  end process;
end CUNIT_ARCH;
