----------------------------------------------------------------------------
--
--  Atmel AVR Program Memory
--
--  This component describes a program for the AVR CPU.  It creates the 
--  program in a small (334 x 16) ROM.
--
--  Revision History:
--     11 May 00  Glen George       Initial revision (from 5/9/00 version of 
--                                  progmem.vhd).
--     28 Jul 00  Glen George       Added instructions and made memory return
--                                  NOP when not mapped.
--      7 Jun 02  Glen George       Updated commenting.
--     16 May 04  Glen George       Added more instructions for testing and
--                                  updated commenting.
--     21 Jan 08  Glen George       Updated commenting.
--     02 Mar 17  Torkom P          Changed insturctions to match our test prog 
--
----------------------------------------------------------------------------


--
--  PROG_MEMORY
--
--  This is the program memory component.  It is just a 334 word ROM with no
--  timing information.  It is meant to be connected to the AVR CPU.  The ROM
--  is always enabled and may be changed when Reset it active.
--
--  Inputs:
--    ProgAB - address bus (16 bits)
--    Reset  - system reset (active low)
--
--  Outputs:
--    ProgDB - program memory data bus (16 bits)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity  PROG_MEMORY  is

    port (
        ProgAB  :  in   std_logic_vector(15 downto 0);  -- program address bus
        Reset   :  in   std_logic;                      -- system reset
        ProgDB  :  out  std_logic_vector(15 downto 0)   -- program data bus
    );

end  PROG_MEMORY;


architecture  ROM  of  PROG_MEMORY  is

    -- define the type for the ROM (an array)
    type  ROMtype  is array(0 to 323) of std_logic_vector(15 downto 0);

    -- define the actual ROM (initialized to a simple program)
    signal  ROMbits  :  ROMtype  :=  ( 
X"E5A4", X"E2B1", X"9618", X"35AC", X"F011", 
X"940E", X"0142", X"32B1", X"F011", X"940E", 
X"0142", X"971C", X"35A0", X"F011", X"940E", 
X"0142", X"32B1", X"F011", X"940E", X"0142", 
X"E000", X"E31A", X"0F01", X"1701", X"F011", 
X"940E", X"0142", X"F00B", X"C002", X"940E", 
X"0142", X"E71F", X"E70F", X"0F10", X"F40B", 
X"C002", X"940E", X"0142", X"E001", X"E011", 
X"1B01", X"F409", X"C002", X"940E", X"0142", 
X"9408", X"1F00", X"3001", X"F409", X"C002", 
X"940E", X"0142", X"5001", X"F409", X"C002", 
X"940E", X"0142", X"9408", X"0B00", X"3F0F", 
X"F409", X"C002", X"940E", X"0142", X"9408", 
X"4001", X"3F0D", X"F409", X"C002", X"940E", 
X"0142", X"E000", X"EF1F", X"2301", X"F409", 
X"C002", X"940E", X"0142", X"EF0F", X"2301", 
X"3F0F", X"F409", X"C002", X"940E", X"0142", 
X"7000", X"F409", X"C002", X"940E", X"0142", 
X"E000", X"E010", X"2B01", X"F409", X"C002", 
X"940E", X"0142", X"E416", X"2B01", X"3406", 
X"F409", X"C002", X"940E", X"0142", X"EF1F", 
X"2B01", X"3F0F", X"F409", X"C002", X"940E", 
X"0142", X"E000", X"6308", X"3308", X"F409", 
X"C002", X"940E", X"0142", X"2700", X"F409", 
X"C002", X"940E", X"0142", X"9500", X"3F0F", 
X"F409", X"C002", X"940E", X"0142", X"E406", 
X"9500", X"3B09", X"F409", X"C002", X"940E", 
X"0142", X"9501", X"3407", X"F409", X"C002", 
X"940E", X"0142", X"E000", X"6001", X"3001", 
X"F409", X"C002", X"940E", X"0142", X"6800", 
X"3801", X"F409", X"C002", X"940E", X"0142", 
X"7F0E", X"3800", X"770F", X"F409", X"C002", 
X"940E", X"0142", X"E000", X"9503", X"3001", 
X"F409", X"C002", X"940E", X"0142", X"950A", 
X"F409", X"C002", X"940E", X"0142", X"2300", 
X"F409", X"C002", X"940E", X"0142", X"2700", 
X"F409", X"C002", X"940E", X"0142", X"EF0F", 
X"3F0F", X"F409", X"C002", X"940E", X"0142", 
X"E203", X"9300", X"0021", X"9100", X"0021", 
X"E0A5", X"EFBE", X"930C", X"910C", X"E0C5", 
X"EFDE", X"8308", X"8108", X"E0E5", X"EFFE", 
X"8300", X"8100", X"E209", X"830D", X"2700", 
X"810D", X"9309", X"9309", X"910A", X"E514", 
X"2F01", X"3504", X"F409", X"C002", X"940E", 
X"0142", X"E302", X"3302", X"C002", X"940E", 
X"0142", X"940C", X"00E6", X"940E", X"0142", 
X"9478", X"F017", X"940E", X"0142", X"94F8", 
X"F00F", X"F417", X"940E", X"0142", X"9408", 
X"F010", X"940E", X"0142", X"F010", X"940E", 
X"0142", X"9488", X"F008", X"F410", X"940E", 
X"0142", X"9428", X"F012", X"940E", X"0142", 
X"F012", X"940E", X"0142", X"94A8", X"F00A", 
X"F412", X"940E", X"0142", X"9438", X"F013", 
X"940E", X"0142", X"F013", X"940E", X"0142", 
X"94B8", X"F00B", X"F413", X"940E", X"0142", 
X"F00C", X"F414", X"940E", X"0142", X"9438", 
X"9428", X"9448", X"F40C", X"F014", X"940E", 
X"0142", X"E002", X"E011", X"9408", X"0701", 
X"F409", X"F011", X"940E", X"0142", X"9498", 
X"F009", X"F411", X"940E", X"0142", X"E802", 
X"0F00", X"F010", X"940E", X"0142", X"3004", 
X"F011", X"940E", X"0142", X"9408", X"1F00", 
X"3009", X"F011", X"940E", X"0142", X"E802", 
X"9505", X"3C01", X"F011", X"940E", X"0142", 
X"940E", X"0143", X"CFFF", X"CFFF");


begin


    -- the address has changed - read the new value
    ProgDB <= ROMbits(CONV_INTEGER(ProgAB)) when (CONV_INTEGER(ProgAB) <= ROMbits'high)  else
              X"E0C0";


    -- process to handle Reset
    process(Reset)
    begin

        -- check if Reset is low now
        if  (Reset = '0')  then
            -- reset is active - initialize the ROM (nothing for now)
        end if;

    end process;

end  ROM;
