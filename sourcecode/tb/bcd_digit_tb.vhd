
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_digit_tb is
end bcd_digit_tb;


architecture testbench of bcd_digit_tb is

component bcd_digit is
    Port ( 	
			clk	    	: in std_logic;	
			reset 		: in std_logic;
			enable		: in std_logic;
			y	 		: out std_logic_vector(3 downto 0);
			overflow	: out std_logic 
		);
end component;

signal clk				: std_logic := '0';
signal reset			: std_logic := '0';
signal enable		    : std_logic := '0';

signal y				: std_logic_vector(3 downto 0) := "0000";
signal overflow			: std_logic := '0';

constant clk_period: time := 10 ns;		-- simulating a 100 MHz clock

--=============================================================================
--Wire the "Function Generator" and "Digital Oscilloscope" to our design:
--=============================================================================
begin
dut: bcd_digit port map ( 
        clk    		=> clk,
        reset		=> reset,
		enable   	=> enable,
        y			=> y,
        overflow	=> overflow 
);

--=============================================================================
--Clock Generation Process:
--=============================================================================
clkgen_proc: process
begin
    clk <= not(clk);
    wait for clk_period/2;
end process clkgen_proc;

--=============================================================================
--Stimulus Process:
--=============================================================================
stimulus_proc: process
begin
    reset <= '0';
    wait for 5 * clk_period;
    
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--Test the reset functionality:
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    reset <= '1';		-- hold in reset state for a while
    wait for 5*clk_period;
    
    reset <= '0';		-- let it run, but not all the way to the end
	enable <= '1';
    wait for 5*clk_period;  
    
    reset <= '1';		-- reset and start over
    wait for 2*clk_period;
	
    reset <= '0';		-- let it run all the way to tc and beyond
    wait for 23*clk_period;  
	
	enable <= '0';	    -- disable the counter
    wait for 5*clk_period;  

	reset <= '1';		-- reset and start over
    wait for 2*clk_period;
	
	reset <= '0';		-- no inputs
    wait for 2*clk_period;
    wait;
end process stimulus_proc;

end testbench;
