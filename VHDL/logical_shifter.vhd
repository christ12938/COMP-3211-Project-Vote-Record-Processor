----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2022 06:41:57 AM
-- Design Name: 
-- Module Name: logical_shifter - Behavioral
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

entity logical_shifter is
  Port ( shift_mode : in std_logic;
         data_in    : in std_logic_vector(31 downto 0);
         bits       : in std_logic_vector(4 downto 0);
         data_out   : out std_logic_vector(31 downto 0));
end logical_shifter;

architecture Behavioral of logical_shifter is

begin

    data_out <= std_logic_vector(shift_left(unsigned(data_in), to_integer(unsigned(bits)))) when shift_mode = '0' else
                std_logic_vector(shift_right(unsigned(data_in), to_integer(unsigned(bits))));

end Behavioral;
