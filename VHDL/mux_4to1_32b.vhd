----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2022 03:43:34 AM
-- Design Name: 
-- Module Name: mux_4to1_32b - Behavioral
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

entity mux_8to1_32b is
    port ( mux_select : in  std_logic_vector(2 downto 0);
           data_a     : in  std_logic_vector(31 downto 0);
           data_b     : in  std_logic_vector(31 downto 0);
           data_c     : in  std_logic_vector(31 downto 0);
           data_d     : in  std_logic_vector(31 downto 0);
           data_e     : in  std_logic_vector(31 downto 0);
           data_out   : out std_logic_vector(31 downto 0) );
end mux_8to1_32b;

architecture Behavioral of mux_8to1_32b is
begin

    data_out <= data_a when mux_select = "000" else
                data_b when mux_select = "001" else
                data_c when mux_select = "010" else
                data_d when mux_select = "011" else
                data_e when mux_select = "100" else
                data_a;
    
end Behavioral;
