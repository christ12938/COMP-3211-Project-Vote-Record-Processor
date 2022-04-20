----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2022 01:44:10 AM
-- Design Name: 
-- Module Name: swapper - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity swapper is
  Port ( swapper_start  : in std_logic_vector(2 downto 0);
         control_word   : in std_logic_vector(12 downto 0);
         vote_record    : in std_logic_vector(31 downto 0);
         data_out       : out std_logic_vector(31 downto 0));
end swapper;

architecture Behavioral of swapper is
    signal b1: unsigned(1 downto 0);
    signal b2: unsigned(1 downto 0);
    signal p1: unsigned(2 downto 0);
    signal p2: unsigned(2 downto 0);
    signal s: unsigned(2 downto 0);
    signal record_lc : unsigned(31 downto 0);
    constant mask : unsigned(31 downto 0) := x"FFFFFFFF";
    signal pos_1: unsigned(4 downto 0);
    signal pos_2: unsigned(4 downto 0);
    signal b1_msk: unsigned(31 downto 0);
    signal b2_msk: unsigned(31 downto 0);
    signal b1_bits: unsigned(31 downto 0);
    signal b2_bits: unsigned(31 downto 0);
begin
    -- TODO: add wraparound for s bit
    b1 <= unsigned(control_word(1 downto 0));
    b2 <= unsigned(control_word(3 downto 2));
    p1 <= unsigned(control_word(6 downto 4));
    p2 <= unsigned(control_word(9 downto 7));
    s  <= unsigned(control_word(12 downto 10));
    record_lc <= unsigned(vote_record);
    
    pos_1 <= shift_left(("000" & b1), 3) + p1;
    pos_2 <= shift_left(("000" & b2), 3) + p2;
    
    b1_msk <= shift_left(not(shift_left(mask, to_integer(s))), to_integer(pos_1));
    b2_msk <= shift_left(not(shift_left(mask, to_integer(s))), to_integer(pos_2));
        
    b1_bits <= shift_right((record_lc and b1_msk), to_integer(pos_1));
    b2_bits <= shift_right((record_lc and b2_msk), to_integer(pos_2));   
    
    data_out <= std_logic_vector((((record_lc and not(b2_msk)) or shift_left(b1_bits, to_integer(pos_2))) 
                 or (((record_lc and not(b2_msk)) or shift_left(b1_bits, to_integer(pos_2))) and not(b1_msk))) 
                 or shift_left(b2_bits, to_integer(pos_1)));
    -- load vote record
    
    
    

end Behavioral;
 