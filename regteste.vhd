----------------------------------------------------------------------------
--
--  Atmel AVR Register Array Test Entity Declaration
--
--  This is the entity declaration which must be used for building the
--  register array portion of the AVR design for testing.
--
--  Revision History:
--     17 Apr 98  Glen George       Initial revision.
--     20 Apr 98  Glen George       Fixed minor syntax bugs.
--     22 Apr 02  Glen George       Updated comments.
--     18 Apr 04  Glen George       Updated comments and formatting.
--     21 Jan 06  Glen George       Updated comments.
--
----------------------------------------------------------------------------


--
--  REG_TEST
--
--  This is the register array testing interface.  It just brings all the
--  important register array signals out for testing along with the
--  Instruction Register.
--
--  Inputs:
--    IR      - Instruction Register (16 bits)
--    RegIn   - input to the register array (8 bits)
--    clock   - the system clock
--
--  Outputs:
--    RegAOut - register bus A output (8 bits), eventually will connect to ALU
--    RegBOut - register bus B output (8 bits), eventually will connect to ALU
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  REG_TEST  is
    port(
        IR       :  in  opcode_word;                        -- Instruction Register
        RegIn    :  in  std_logic_vector(7 downto 0);       -- input register bus
        clock    :  in  std_logic;                          -- system clock
        RegAOut  :  out std_logic_vector(7 downto 0);       -- register bus A out
        RegBOut  :  out std_logic_vector(7 downto 0)        -- register bus B out
    );
end  REG_TEST;

architecture REG_TEST_ARCH of REG_TEST is
  component REG
      port(
          RegIn    :  in  std_logic_vector(7 downto 0);       -- input register bus
          clock    :  in  std_logic;                          -- system clock
          En       :  in  std_logic;                          -- Write enable
          SelA     :  in  std_logic_vector(4 downto 0);
          SelB     :  in  std_logic_vector(4 downto 0);
          RegA     :  out std_logic_vector(7 downto 0);       -- register bus A out
          RegB     :  out std_logic_vector(7 downto 0);       -- register bus B out
          XReg     :  out std_logic_vector(15 downto 0);
          YReg     :  out std_logic_vector(15 downto 0);
          ZReg     :  out std_logic_vector(15 downto 0)
      );
  end component;
  component CUNIT
    port (
        IR       :  in  std_logic_vector(15 downto 0);
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
  end component;

  signal SelA : std_logic_vector(4 downto 0);
  signal SelB : std_logic_vector(4 downto 0);
  signal En  :  std_logic;

  signal END_SIM : BOOLEAN := FALSE;

begin
  register_array : REG
    port map (
      RegIn => RegIn,
      clock => clock,
      RegA => RegAOut,
      RegB => RegBOut,
      SelA => SelA,
      SelB => SelB,
      En => En
    );
  control_unit : CUNIT
    port map (
      IR => IR,
      clock => clock,
      SelA => SelA,
      SelB => SelB,
      En => En,
      SR => x"00"
    );
end REG_TEST_ARCH;
