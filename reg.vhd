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
--  This is the general register array. Two out registers can be selected using
--  using RegAOut and RegBOut. A register can be written to using the write
--  enable line, and the register written is the same as RegAOut.
--
--  Inputs:
--    RegIn - input register bus
--    clock - system clock
--    En    - register write enable (register written is always SelA)
--    SelA  -  RegA select
--    SelB  -  RegB select
--
--  Outputs:
--    XReg  -  X register (R27:R26)
--    YReg  -  Y register (R29:R28)
--    ZReg  -  Z register (R31:R30)
--    RegA  - register bus A output (8 bits)
--    RegB  - register bus B output (8 bits)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  REG  is
    port(
        RegIn    :  in  std_logic_vector(7 downto 0);       -- input register bus
        clock    :  in  std_logic;                          -- system clock
        En       :  in  std_logic;                          -- Write enable
        SelA     :  in  std_logic_vector(4 downto 0);
        SelB     :  in  std_logic_vector(4 downto 0);
        RegA     :  out std_logic_vector(7 downto 0);       -- register bus A out
        RegB     :  out std_logic_vector(7 downto 0)        -- register bus B out
        XReg     :  out std_logic(15 downto 0);
        YReg     :  out std_logic(15 downto 0);
        ZReg     :  out std_logic(15 downto 0)
    );
end  REG;
