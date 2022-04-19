----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2022 03:56:38 AM
-- Design Name: 
-- Module Name: stalling_ctrl_unit - Behavioral
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

entity stalling_ctrl_unit is
  Port ( stall_sel      : in  std_logic;
         reg_write_in   : in  std_logic;
         alu_src_in     : in  std_logic;
         mem_write_in   : in  std_logic;
         mem_to_reg_in  : in  std_logic;
         ex_reg_in      : in  std_logic_vector(2 downto 0);
         mem_read_in    : in  std_logic;
         shift_mode_in  : in  std_logic;
         alu_mode_in    : in  std_logic;
         cmp_mode_in    : in  std_logic;
         branch_jmp_in  : in  std_logic_vector(1 downto 0);
         reg_write_out  : out std_logic;
         alu_src_out    : out std_logic;
         mem_write_out  : out std_logic;
         mem_to_reg_out : out std_logic;
         ex_reg_out     : out std_logic_vector(2 downto 0);
         mem_read_out   : out std_logic;
         shift_mode_out : out std_logic;
         alu_mode_out   : out std_logic;
         cmp_mode_out   : out std_logic;
         branch_jmp_out : out  std_logic_vector(1 downto 0));     
end stalling_ctrl_unit;

architecture Behavioral of stalling_ctrl_unit is

begin

    reg_write_out  <= reg_write_in when stall_sel = '0' else
                     '0';
    alu_src_out    <= alu_src_in when stall_sel = '0' else
                     '0';
    mem_write_out  <= mem_write_in when stall_sel = '0' else
                     '0';
    mem_to_reg_out <= mem_to_reg_in when stall_sel = '0' else
                     '0';
    ex_reg_out     <= ex_reg_in when stall_sel = '0' else
                     "000";
    mem_read_out   <= mem_read_in when stall_sel = '0' else
                     '0';
    shift_mode_out <= shift_mode_in when stall_sel = '0' else
                     '0';    
    alu_mode_out   <= alu_mode_in when stall_sel = '0' else
                     '0'; 
    cmp_mode_out <= cmp_mode_in when stall_sel = '0' else
                     '0';          
    branch_jmp_out <= branch_jmp_in when stall_sel = '0' else
                     "00";          
                                   
end Behavioral;
