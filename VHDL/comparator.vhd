----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2022 05:43:59 AM
-- Design Name: 
-- Module Name: comparator - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity comparator is
    Port ( cmp_mode : std_logic;
           data_a   : in std_logic_vector(31 downto 0);
           data_b   : in std_logic_vector(31 downto 0);
           output   : out std_logic);
end comparator;

architecture Behavioral of comparator is

begin

    output <= '1' when (data_a = data_b and cmp_mode = '1') or (data_a /= data_b and cmp_mode = '0') else
              '0';


end Behavioral;
