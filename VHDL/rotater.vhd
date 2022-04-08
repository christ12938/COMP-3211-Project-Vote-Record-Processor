----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2022 06:30:17 PM
-- Design Name: 
-- Module Name: rotater - Behavioral
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
use ieee.numeric_std.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rotater is
  Port ( control_word: in std_logic_vector(11 downto 0);
         vote_record : in std_logic_vector(31 downto 0);
         data_out   : out std_logic_vector(31 downto 0));
end rotater;

architecture Behavioral of rotater is
    signal r0: unsigned(2 downto 0);
    signal r1: unsigned(2 downto 0);
    signal r2: unsigned(2 downto 0);
    signal r3: unsigned(2 downto 0);
begin

    r0 <= unsigned(control_word(2 downto 0));
    r1 <= unsigned(control_word(5 downto 3));
    r2 <= unsigned(control_word(8 downto 6));
    r3 <= unsigned(control_word(11 downto 9));

    data_out(7 downto 0) <= std_logic_vector(rotate_left(unsigned(vote_record(7 downto 0)), to_integer(r0)));
    data_out(15 downto 8) <= std_logic_vector(rotate_left(unsigned(vote_record(15 downto 8)), to_integer(r1)));
    data_out(23 downto 16) <= std_logic_vector(rotate_left(unsigned(vote_record(23 downto 16)), to_integer(r2)));
    data_out(31 downto 24) <= std_logic_vector(rotate_left(unsigned(vote_record(31 downto 24)), to_integer(r3)));
    
end Behavioral;
