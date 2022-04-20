----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2022 10:29:46 AM
-- Design Name: 
-- Module Name: forwarding_unit - Behavioral
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

entity forwarding_unit is
  Port ( DM_WB_reg_write: in std_logic;
         EX_DM_reg_write: in std_logic;
         DM_WB_Rd       : in std_logic_vector(3 downto 0);
         EX_DM_Rd       : in std_logic_vector(3 downto 0);
         ID_EX_Rs       : in std_logic_vector(3 downto 0);
         ID_EX_Rt       : in std_logic_vector(3 downto 0);
         ID_EX_mem_write: in std_logic;
         EX_DM_mem_write: in std_logic;
         alu_mux_1      : out std_logic;
         alu_mux_2      : out std_logic;
         alu_mux_3      : out std_logic;
         alu_mux_4      : out std_logic;
         dm_data_mux    : out std_logic;
         ex_data_mux    : out std_logic);
end forwarding_unit;

architecture Behavioral of forwarding_unit is

begin

     alu_mux_1 <= '1' when (DM_WB_reg_write = '1' and DM_WB_Rd /= x"0" and DM_WB_Rd = ID_EX_Rs and (EX_DM_reg_write = '0' or EX_DM_Rd /= ID_EX_Rs)) else
                  '0';       
     alu_mux_2 <= '1' when (DM_WB_reg_write = '1' and DM_WB_Rd /= x"0" and DM_WB_Rd = ID_EX_Rt and (EX_DM_reg_write = '0' or EX_DM_Rd /= ID_EX_Rt)) else
                  '0';
     alu_mux_3 <= '1' when (EX_DM_reg_write = '1' and EX_DM_Rd /= x"0" and EX_DM_Rd = ID_EX_Rs) else
                  '0';
     alu_mux_4 <= '1' when (EX_DM_reg_write = '1' and EX_DM_Rd /= x"0" and EX_DM_Rd = ID_EX_Rt) else
                  '0';             
     dm_data_mux <= '1' when (DM_WB_reg_write = '1' and DM_WB_Rd /= x"0" and EX_DM_mem_write = '1' and DM_WB_Rd = EX_DM_Rd) else
                    '0';
     ex_data_mux <= '1' when (DM_WB_reg_write = '1' and DM_WB_Rd /= x"0" and ID_EX_mem_write = '1' and DM_WB_Rd = ID_EX_Rt) else
                    '0';
end Behavioral;
