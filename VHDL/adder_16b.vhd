---------------------------------------------------------------------------
-- adder_16b.vhd - 16-bit Adder Implementation
--
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity adder_32b is
    port ( alu_mode  : in  std_logic_vector(1 downto 0) ;
           src_a     : in  std_logic_vector(31 downto 0);
           src_b     : in  std_logic_vector(31 downto 0);
           sum       : out std_logic_vector(31 downto 0);
           carry_out : out std_logic );
end adder_32b;

architecture behavioural of adder_32b is

signal sig_result : std_logic_vector(32 downto 0);
signal mul_result : std_logic_vector(64 downto 0);

begin
    mul_result <= std_logic_vector(to_unsigned(to_integer(unsigned(src_a)) * to_integer(unsigned(src_b)), 65));
    
    sig_result <= ('0' & src_a) - ('0' & src_b) when alu_mode = "01" else

                  mul_result(32 downto 0) when alu_mode = "10" else
                  ('0' & src_a) + ('0' & src_b);
    sum        <= sig_result(31 downto 0);
    carry_out  <= sig_result(32);
    
end behavioural;
