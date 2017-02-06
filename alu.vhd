----------------------------------------------------------------------------
--
--  Atmel AVR ALU
--
--  This is the entity declaration for the Atmel AVR ALU.
--
--  Revision History:
--     2017-01-23     Initial Revision    Harrison Krowas
--     2017-02-02     Wrote HDL           Torkom Pailevanian
--
----------------------------------------------------------------------------
--
--
--  ALU
--
--  The ALU performs on operation on two inputs and outputs a single output
--  to the register array.
--
--  Inputs:
--    OperandA - first operand to ALU (8 bits) - looks like the output
--               of the register array
--    OperandB - second operand to ALU (8 bits) - looks like the output
--               of the register array
--    AluOp    - 6 bit vector that tells the ALU which operation to perform.
--    StatRegIn- status register input. The status register is used for some
--               ALU operations.
--
--
--  Outputs:
--    Result   - result of the ALU operation selected by the Instruction
--               Register (8 bits)
--    StatReg  - status register. Flags are always output regardless of operation.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all; 

--
--  FullAdder entity declaration (used in n-bit adder)
--
entity  FullAdder  is

    port (
        A, B  :  in  std_logic;       --  addends
        Cin   :  in  std_logic;       --  carry in input
        Sum   :  out  std_logic;      --  sum output
        Cout  :  out  std_logic       --  carry out output
    );

end  FullAdder;

--
--  FullAdder dataflow architecture
--
architecture  dataflow  of  FullAdder  is
begin

    Sum <= A xor B xor Cin;
    Cout <= (A and B) or (A and Cin) or (B and Cin);

end  dataflow;


--
--  n-Bit Adder
--      parameter (bitsize) is the number of bits in the adder
--

library ieee;
use ieee.std_logic_1164.all;

entity  Adder  is
    generic (
        bitsize : integer := 8      -- default width is 8-bits
    );
    port (
        X, Y :  in  std_logic_vector((bitsize - 1) downto 0);     -- addends
        Ci   :  in  std_logic;                                    -- carry in
        S    :  out  std_logic_vector((bitsize - 1) downto 0);    -- sum out
        Co   :  out  std_logic;                                   -- carry out
        Coh  :  out  std_logic;                                   -- half carry out
        Co6  :  out  std_logic                                    -- carry out 6
    );

end  Adder;

architecture  archAdder  of  Adder  is
    component  FullAdder
        port (
            A, B  :  in  std_logic;       --  inputs
            Cin   :  in  std_logic;       --  carry in input
            Sum   :  out  std_logic;      --  sum output
            Cout  :  out  std_logic       --  carry out output
        );
    end  component;
    signal  carry : std_logic_vector(bitsize downto 0);   -- intermediate carries
begin
    carry(0) <= Ci;                         -- put carry in into our carry vector

    Adders:  for i in  X'range  generate    -- generate bitsize full adders
    begin

        FAx: FullAdder  port map  (X(i), Y(i), carry(i), S(i), carry(i + 1));

    end generate;
    
    Coh <= carry(3);                         -- carry out of bit 3 into bit 4
    Co6 <= carry(7);                         -- carry out of bit 6 into bit 7
    Co <= carry(carry'high);                 -- carry out is from carry vector
end  archAdder;

---------------------------------------------------------------------
-- ALU Implementation 
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;


entity  ALU  is
    port(
        OperandA  :  in  std_logic_vector(7 downto 0);    -- first operand
        OperandB  :  in  std_logic_vector(7 downto 0);    -- second operand
        AluOp     :  in  std_logic_vector(5 downto 0);    -- ALU operation to perform
        StatRegIn :  in  std_logic_vector(7 downto 0);
        Result    :  out std_logic_vector(7 downto 0);    -- ALU result
        StatRegOut:  out std_logic_vector(7 downto 0)     -- status register
    );
end  ALU;

architecture ALU_ARCH of ALU is


  type result_array is array(3 downto 0) of std_logic_vector(7 downto 0);
  signal results  :  result_array;
  
  type flag_array is array(3 downto 0) of std_logic_vector(7 downto 0);
  signal flags : flag_array;
  
  component  Adder
		  generic (
				bitsize : integer := 8      -- default width is 8-bits
		  );
        port (
            X, Y :  in  std_logic_vector((bitsize - 1) downto 0);     -- addends
            Ci   :  in  std_logic;                                    -- carry in
            S    :  out  std_logic_vector((bitsize - 1) downto 0);    -- sum out
            Co   :  out  std_logic;                                   -- carry out
				Coh  :  out  std_logic;                                   -- half carry out
				Co6  :  out  std_logic                                    -- carry out 6
        );
  end  component;
  
  signal tempB : std_logic_vector(7 downto 0);    -- OperandB xor with sub/add
  signal tempC : std_logic;                       -- Carry flag xor with sub/add
    
  signal temp_co6 : std_logic;                    -- Carry out of bit 6 
    
begin
  ---------------------------------------------------------------------
  -- ALU F Block 
  ---------------------------------------------------------------------
  -- This for generates the F-block of the ALU using combinational logic 
  process (results(0), AluOp, OperandA, OperandB)
  begin
	  for i in  results(0)'range loop
        results(0)(i)  <=   (AluOp(2) and (not OperandA(i)) and  (not OperandB(i))) or
                            (AluOp(3) and (not OperandA(i)) and       OperandB(i) ) or
                            (AluOp(4) and      OperandA(i)  and  (not OperandB(i))) or
                            (AluOp(5) and      OperandA(i)  and       OperandB(i) );
	  end loop;
  end process;
  
  flags(0)(0) <= '1';                                        -- C Flag 
  flags(0)(1) <= NOR_REDUCE(results(0));                     -- Z Flag 
  flags(0)(2) <= results(0)(7);                					 -- N flag 
  flags(0)(3) <= '0';                                        -- V Flag 
  flags(0)(4) <=  (results(0)(7)) xor '0';       				 -- S Flag 
  flags(0)(5) <= '0';                                        -- H Flag 
  flags(0)(6) <= '0';                                        -- T Flag
  flags(0)(7) <= '0';                                        -- I Flag 
  
  ---------------------------------------------------------------------
  -- ALU Add/Sub Block 
  ---------------------------------------------------------------------
  -- generate the tempB signal by xor all bits by the add/sub signal in alu op 
  process (OperandB, AluOp, tempB)
  begin
	  for i in OperandB'range loop
			tempB(i) <= OperandB(i) xor AluOp(2);
	  end loop;
  end process;
  
  -- generate the tempC signal by xor the carry flag and the add/sub signal
  -- carry flag is and with the AluOp indicating if carry is used in operation   
  tempC <= (StatRegIn(0) and AluOp(3)) xor AluOp(2);
  
  -- Create a full adder subtractor using the Adder entity 
  --  Add/Sub changes the carry and half carry flags 
  AddSub: Adder port map (OperandA, tempB, tempC, results(1), flags(1)(0), flags(1)(5), temp_co6);
  
  -- flags for Shift Rotate Block 
  flags(1)(1) <= NOR_REDUCE(results(1));                     -- Z Flag 
  flags(1)(2) <= results(1)(results(1)'high);                  -- N flag 
  flags(1)(3) <= flags(1)(0) xor temp_co6;                  -- V Flag 
  flags(1)(4) <= results(1)(results(1)'high) xor flags(1)(0) xor temp_co6; -- S Flag 
  flags(1)(6) <= '0';                                        -- T Flag
  flags(1)(7) <= '0';                                        -- I Flag 
  
  ---------------------------------------------------------------------
  -- ALU Shift/Rotate Block 
  ---------------------------------------------------------------------
  process (results(2), OperandA)
  begin
	  for i in 6 downto 0 loop
			  results(2)(i)  <=   OperandA(i+1);
	  end loop;
  end process;
  -- take care of the high bit
  results(2)(results(2)'high)  <=   (AluOp(2) and OperandA(OperandA'high)) or
                                    (AluOp(3) and OperandA(0)) or
                                    (AluOp(4) and '0');
                      
  -- flags for Shift Rotate Block 
  flags(2)(0) <= OperandA(0);                                -- C Flag 
  flags(2)(1) <= NOR_REDUCE(results(2));                     -- Z Flag 
  flags(2)(2) <= results(2)(results(2)'high);                  -- N flag 
  flags(2)(3) <= results(2)(results(2)'high) xor OperandA(0);  -- V Flag 
  flags(2)(4) <= NOR_REDUCE(results(2)) xor results(2)(results(2)'high) xor OperandA(0); -- S Flag 
  flags(2)(5) <= '0';                                        -- H Flag 
  flags(2)(6) <= '0';                                        -- T Flag
  flags(2)(7) <= '0';                                        -- I Flag 
  
  ---------------------------------------------------------------------
  -- ALU Bitwise Operations Block 
  ---------------------------------------------------------------------
  process(AluOp, StatRegIn, OperandA)
  begin
    if (std_match(AluOp(5 downto 2), "0001")) then
        -- SWAP nibbles of the operand 
        results(3)(7 downto 4) <= OperandA(3 downto 0);
        results(3)(3 downto 0) <= OperandA(7 downto 4);
        -- no flags are changed in this operation
		  flags(3) <= "00000000";
		  
    end if;
    if (std_match(AluOp(5 downto 2), "0010")) then
        -- BLD 
        -- Rd(b) = T
		  results(3) <= OperandA;
        results(3)(to_integer(unsigned(OperandB(2 downto 0)))) <= StatRegIn(6);

        -- no flags are changed in this operation
		  flags(3) <= "00000000";
		  
    end if;
    if (std_match(AluOp(5 downto 2), "0100")) then
        -- BSET
        -- SREG(s) = 1
		  results(3) <= "00000001";
		  
		  flags(3) <= "11111111";
		          
    end if;
    if (std_match(AluOp(5 downto 2), "1000")) then
        -- BCLR
        -- SREG(s) = 0
		  results(3) <= "00000000";

        flags(3) <= "00000000";
		          
    end if;
    if (std_match(AluOp(5 downto 2), "0000")) then
        -- BST
        -- T = Rr(b)
		  results(3) <= (0 => flags(3)(6), others => '0');
		  
		   flags(3) <= (6 => OperandA(to_integer(unsigned(OperandB(2 downto 0)))), others => '0');
       
    end if;
    
  end process;
  
  ---------------------------------------------------------------------
  -- Result and Flag Mux 
  ---------------------------------------------------------------------
  process(AluOp, StatRegIn, OperandA, results, flags)
  begin
    if (std_match(AluOp(1 downto 0), "00")) then
        -- use result of the F block 
        Result <= results(0); 
        
        -- use flags from the F block 
        StatRegOut <= flags(0);
        
    end if;
    if (std_match(AluOp(1 downto 0), "01")) then
        -- use result of the Add/Sub block 
        Result <= results(1); 
        
        -- use flags from the Add/Sub block
        StatRegOut <= flags(1);
        
    end if;
    if (std_match(AluOp(1 downto 0), "10")) then
        -- use result of the shift rotate block 
        Result <= results(2); 
        
        -- use flags from the shift rotate block 
        StatRegOut <= flags(2);
        
    end if;
    if (std_match(AluOp(1 downto 0), "11")) then
        -- use result from the bitwise operations block 
        Result <= results(3); 
        
        -- use flags from the bitwise operations block 
        StatRegOut <= flags(3);
        
    end if;
   
  end process;
 
end ALU_ARCH;
