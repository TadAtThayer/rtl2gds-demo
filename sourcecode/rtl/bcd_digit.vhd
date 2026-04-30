--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity bcd_digit is
	port(clk   	    : in  std_logic;
    	 reset  	: in  std_logic; --1 to reset
    	 enable 	: in  std_logic; --1 to count, 0 to hold
		 y      	: out std_logic_vector(3 downto 0);
         overflow   : out std_logic );
end entity;

--=============================================================================
--Architecture Type:
--=============================================================================        
architecture behavior of bcd_digit is
--=============================================================================
--Signal Declarations: 
--=============================================================================

--Put your signals here
signal count : unsigned( 3 downto 0 ) := "0000";
signal tc : std_logic;



--=============================================================================
--Processes: 
--=============================================================================
begin

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--BCD Digit Counter:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
process(clk)
begin

    if rising_edge(clk) then 
        if reset = '1' then
           count <= (others => '0');
        elsif enable = '1' then 
           if tc = '1' then 
               count <= (others => '0');
           else
               count <= count + 1;
           end if;
        end if;
    end if;	       
end process;


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--BCD Digit TC:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
process(count)						
begin
	
	--Put your asynchronous terminal count here
    if count = x"9" then 
        tc <= '1';
    else 
        tc <= '0';
    end if;
    
end process;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Mapping:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    y <= std_logic_vector(count);
    overflow <= tc;


end behavior;     


