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
  Port ( control_word   : in std_logic_vector(12 downto 0);
         vote_record    : in std_logic_vector(31 downto 0);
         data_out       : out std_logic_vector(31 downto 0));
end swapper;

architecture Behavioral of swapper is
    signal b1: unsigned(1 downto 0);
    signal b2: unsigned(1 downto 0);
    signal p1: unsigned(2 downto 0);
    signal p2: unsigned(2 downto 0);
    signal s: unsigned(2 downto 0);
    signal data : unsigned(31 downto 0);
    
begin
    -- TODO: add wraparound for s bit
    b1 <= unsigned(control_word(1 downto 0));
    b2 <= unsigned(control_word(3 downto 2));
    p1 <= unsigned(control_word(6 downto 4));
    p2 <= unsigned(control_word(9 downto 7));
    s <= unsigned(control_word(12 downto 10));
    
    -- load vote record
    data <= unsigned(vote_record);
    
    -- load part 2 (b2, p2) into position of part 1
    data((TO_INTEGER(b1) * 8 + TO_INTEGER(p1)) downto (TO_INTEGER(b1) * 8 + TO_INTEGER(p1) - TO_INTEGER(s) + 1)) <= unsigned(vote_record((TO_INTEGER(b2) * 8 + TO_INTEGER(p2)) downto (TO_INTEGER(b2) * 8 + TO_INTEGER(p2) - TO_INTEGER(s) + 1)));
    -- load part 1 (b1, p1) into position of part 2
    data((TO_INTEGER(b2) * 8 + TO_INTEGER(p2)) downto (TO_INTEGER(b2) * 8 + TO_INTEGER(p2) - TO_INTEGER(s) + 1)) <= unsigned(vote_record((TO_INTEGER(b1) * 8 + TO_INTEGER(p1)) downto (TO_INTEGER(b1) * 8 + TO_INTEGER(p1) - TO_INTEGER(s) + 1)));
    
    -- assign to data out
    data_out <= std_logic_vector(data);

end Behavioral;
 