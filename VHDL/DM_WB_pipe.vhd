----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2022 06:21:27 AM
-- Design Name: 
-- Module Name: DM_WB_pipe - Behavioral
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

entity DM_WB_pipe is
  Port ( Clock          : in std_logic;
         reset          : in std_logic;        
         mem_to_reg_in  : in std_logic;
         reg_write_in   : in std_logic;
         reg_dst_res_in : in std_logic_vector(3 downto 0);
         ex_result_in   : in std_logic_vector(31 downto 0);
         read_data_in   : in std_logic_vector(31 downto 0);
         mem_to_reg_out : out std_logic;
         reg_write_out  : out std_logic;
         reg_dst_res_out: out std_logic_vector(3 downto 0);
         ex_result_out  : out std_logic_vector(31 downto 0);
         read_data_out  : out std_logic_vector(31 downto 0));
end DM_WB_pipe;

architecture Behavioral of DM_WB_pipe is

    component pipeline_register_1bit is
        Port ( d   : IN STD_LOGIC;
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            q   : OUT STD_LOGIC);
    end component;
    
    component pipeline_register_4bit is
        Port (    d   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            q   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
    end component;
    
    component pipeline_register_32bit is
        Port (    d   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            q   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    end component;
    
begin

    mem_to_reg : pipeline_register_1bit
    port map ( d   => mem_to_reg_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => mem_to_reg_out);
               
    reg_write : pipeline_register_1bit
    port map ( d   => reg_write_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => reg_write_out);
               
    reg_dst_res : pipeline_register_4bit
    port map ( d   => reg_dst_res_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => reg_dst_res_out);
               
    ex_result : pipeline_register_32bit
    port map ( d   => ex_result_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => ex_result_out);          
               
    read_data : pipeline_register_32bit
    port map ( d   => read_data_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => read_data_out); 

end Behavioral;
