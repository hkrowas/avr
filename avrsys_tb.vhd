----------------------------------------------------------------------------
--
--  Atmel Testbench With RAM AND ROM
--
--  This is the testbench for the Atmel
--
--  Revision History:
--     2017-02-23     Initial Revision    Torkom Pailevanian
--
----------------------------------------------------------------------------
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library opcodes;
use opcodes.opcodes.all;


entity  avrsys_tb  is
end  avrsys_tb;

architecture avrsys_tb_ARCH of avrsys_tb is

  component AVR_CPU
  port (
        ProgDB  :  in     std_logic_vector(15 downto 0);   -- program memory data bus
        Reset   :  in     std_logic;                       -- reset signal (active low)
        INT0    :  in     std_logic;                       -- interrupt signal (active low)
        INT1    :  in     std_logic;                       -- interrupt signal (active low)
        clock   :  in     std_logic;                       -- system clock
        ProgAB  :  out    std_logic_vector(15 downto 0);   -- program memory address bus
        DataAB  :  out    std_logic_vector(15 downto 0);   -- data memory address bus
        DataWr  :  out    std_logic;                       -- data memory write enable (active low)
        DataRd  :  out    std_logic;                       -- data memory read enable (active low)
        DataDB  :  inout  std_logic_vector(7 downto 0)     -- data memory data bus
    );
    end component;

    component PROG_MEMORY

    port (
        ProgAB  :  in   std_logic_vector(15 downto 0);  -- program address bus
        Reset   :  in   std_logic;                      -- system reset
        ProgDB  :  out  std_logic_vector(15 downto 0)   -- program data bus
    );

    end  component PROG_MEMORY;

    component DATA_MEMORY

    port (
        RE      : in     std_logic;             	-- read enable (active low)
        WE      : in     std_logic;		        -- write enable (active low)
        DataAB  : in     std_logic_vector(15 downto 0); -- memory address bus
        DataDB  : inout  std_logic_vector(7 downto 0)   -- memory data bus
    );

    end  component DATA_MEMORY;

    signal ProgAB  :  std_logic_vector(15 downto 0);  -- program address bus
    signal ProgDB  :  std_logic_vector(15 downto 0);   -- program data bus
    signal RE      :  std_logic;             	-- read enable (active low)
    signal WE      :  std_logic;		        -- write enable (active low)
    signal DataAB  :  std_logic_vector(15 downto 0); -- memory address bus
    signal DataDB  :  std_logic_vector(7 downto 0);   -- memory data bus

    signal clock   :  std_logic;    -- clock for the entire system
    signal reset   :  std_logic;    -- system reset

    signal END_SIM : BOOLEAN := FALSE;

begin

    avrcpu : AVR_CPU
    port map (
      ProgDB    => ProgDB,
      Reset     => reset,
      clock     => clock,
      ProgAB    => ProgAB,
      DataAB    => DataAB,
      DataWr    => WE,
      DataRd    => RE,
      DataDB    => DataDB,

		INT0    	 => '1',
      INT1 		 => '1'
    );

    ram : DATA_MEMORY
    port map(
      RE        => RE,
      WE        => WE,
      DataAB    => DataAB,
      DataDB    => DataDB
    );

    rom : PROG_MEMORY
    port map(
      ProgAB    => ProgAB,
      Reset     => reset,
      ProgDB    => ProgDB
    );

	process
	  begin
		 reset <= '0';   -- Reset the system and initialize everything
		 wait for 40 ns;
		 reset <= '1';
		 wait for 10000 ns;
		 END_SIM <= TRUE;
	end process;


    CLOCK_CLK : process

    begin

      -- this process generates a 20 ns period, 50% duty cycle clock

      -- only generate clock if still simulating

      if END_SIM = FALSE then
          clock <= '0';
          wait for 10 ns;
      else
          wait;
      end if;

      if END_SIM = FALSE then
          clock <= '1';
          wait for 10 ns;
      else
          wait;
      end if;

    end process;

end avrsys_tb_ARCH;
