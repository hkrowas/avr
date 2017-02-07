----------------------------------------------------------------------------
--
--  Atmel AVR Register Array
--
--  This is the general register array for the Atmel AVR architecture
--
--  Revision History:
--     2017-01-23  Harrison Krowas   Initial revision.
--
----------------------------------------------------------------------------

--
--  REG
--
--  This is the general register array. It contains 32 general purpose registers
--  Two out registers can be selected using using RegAOut and RegBOut. A register
--  can be written to using the write enable line, and the register written is
--  the same as RegAOut. It also always outputs the X, Y, and Z registers for
--  address access, and these can be written to using the EnW input.
--
--  Inputs:
--    RegIn - input register bus
--    clock - system clock
--    En    - register write enable (register written is always SelA)
--    EnW   - Word write enable. Used for X, Y, Z ops.
--    WSel  - Word select. Selects X, Y, Z.
--    SelA  -  RegA select
--    SelB  -  RegB select
--    Address - This takes in the new X, Y, or Z value
--
--  Outputs:
--    RegA  - register bus A output (8 bits)
--    RegB  - register bus B output (8 bits)
--    XReg  -  X register (R27:R26)
--    YReg  -  Y register (R29:R28)
--    ZReg  -  Z register (R31:R30)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  REG  is
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
end  REG;

architecture REG_ARCH of REG is
  type reg_array is array(31 downto 0) of std_logic_vector(7 downto 0);
  signal regs  :  reg_array;
begin
  RegA <= regs(conv_integer(SelA));     -- Muxes for RegA and RegB
  RegB <= regs(conv_integer(SelB));
  XReg <= regs(27) & regs(26);   -- X, Y, and Z registers are concatenations of
  YReg <= regs(29) & regs(28);   -- two registers. They go to the addressing units.
  ZReg <= regs(31) & regs(30);
  process (clock)
  begin
    if (rising_edge(clock)) then
      -- If write enable is '1', selection A gets the input bus.
      if (En = '1') then
        regs(conv_integer(SelA)) <= RegIn;   -- Register written to is always A
      end if;
      -- Addressing registers
      if (EnW = '1') then
        if (WSel = "00") then
          regs(26) <= Address(7 downto 0);
          regs(27) <= Address(15 downto 8);
        end if;
        if (WSel = "01") then
          regs(28) <= Address(7 downto 0);
          regs(29) <= Address(15 downto 8);
        end if;
        if (WSel = "10") then
          regs(30) <= Address(7 downto 0);
          regs(31) <= Address(15 downto 8);
        end if;
      end if;
    end if;
  end process;
end REG_ARCH;
