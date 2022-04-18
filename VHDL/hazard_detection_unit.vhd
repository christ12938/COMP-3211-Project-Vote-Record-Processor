----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2022 01:38:46 AM
-- Design Name: 
-- Module Name: hazard_detection_unit - Behavioral
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

entity hazard_detection_unit is
  Port ( compare_output : in  std_logic;
         branch_jmp     : in  std_logic_vector(1 downto 0);
         ID_EX_mem_read : in std_logic;
         ID_EX_reg_rt   : in std_logic_vector(3 downto 0);
         IF_ID_reg_rs   : in std_logic_vector(3 downto 0);
         IF_ID_reg_rt   : in std_logic_vector(3 downto 0);
         stall          : out std_logic;
         flush          : out std_logic);
end hazard_detection_unit;

architecture Behavioral of hazard_detection_unit is

begin

    flush <= '1' when branch_jmp = "01" or (compare_output = '1' and branch_jmp = "10") else
             '0';
             
    stall <= '1' when ID_EX_mem_read = '1' and (ID_EX_reg_rt = IF_ID_reg_rs or ID_EX_reg_rt = IF_ID_reg_rt) else
             '0';

end Behavioral;
