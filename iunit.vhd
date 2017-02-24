----------------------------------------------------------------------------
--
--  Atmel AVR Instruction Access Unit
--
--  This is the entity declaration for the Atmel AVR instruction access unit.
--
--  Revision History:
--     2016-01-24     Initial Revision    Harrison Krowas
--
----------------------------------------------------------------------------
--
--
--  DUNIT
--
--  The instruction access unit for the AVR.
--
--  Inputs:
--    IR    -  Instruction register for direct addressing
--    Sel   -  Source select. Also controls direct addressing
--    ZReg  -  Z register
--
--  Outputs:
--    IABus   - Instruction address bus

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library opcodes;
use opcodes.opcodes.all;


entity  IUNIT  is
    port(
        clock  :  in  std_logic;                    -- Clock for the Instruction Access Unit
        load   :  in  std_logic;                    -- Control for direct/relative addressing 
        PC_en  :  in  std_logic;                    -- Enable signal for PC 
        IR     :  in  std_logic_vector(15 downto 0);-- Input from IR 
        Sel    :  in  std_logic_vector( 2 downto 0);-- Select signal for source mux 
        ZReg   :  in  std_logic_vector(15 downto 0);-- Z register from register array 
        ProgDB :  in  std_logic_vector(15 downto 0);-- Program data bus 
		  DataDB :  in  std_logic_vector( 7 downto 0);-- Data data bus
        PC     :  buffer std_logic_vector(15 downto 0); -- Program counter register 
        ProgAB :  out std_logic_vector(15 downto 0) -- Program address bus 
    );

end  IUNIT;

architecture IUNIT_ARCH of IUNIT is

    signal src_mux_out : std_logic_vector(15 downto 0); -- Output of the source mux 
	 signal pc_temp     : std_logic_vector(15 downto 0); -- Temp pc signal used for addition 
    
begin
    
process(clock)
  begin
    if (rising_edge(clock)) then
		for i in 7 downto 0 loop
        if (PC_en = '1') then 
            -- If the enable is high then update the program counter 
            pc_temp(i) <= PC(i) and load;
        end if;
		end loop;
		
		PC <= pc_temp + src_mux_out;
    end if;
end process;

-- Program address bus gets the same value as the program counter 
	LOAD_AND: for i in 7 downto 0 generate
		pc_temp(i) <= PC(i) and load;
	end generate LOAD_AND;
	
	ProgAB <= pc_temp + src_mux_out;

-- Source select mux selects the source based on the Sel control signal 
    with Sel select src_mux_out <=
     x"0001" when "000",
     ProgDB when "001",
     "0000" & IR(11 downto 0) when "010",
     ZReg when "011",
     "000000000" & IR(9 downto 3)  when "100",
     "00000000" & DataDB when "101",
     DataDB & PC(7 downto 0) when "110",
     x"0000" when others;
    
    
 
  
end IUNIT_ARCH;
