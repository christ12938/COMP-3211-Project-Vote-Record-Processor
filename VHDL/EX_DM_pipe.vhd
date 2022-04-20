----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2022 06:21:27 AM
-- Design Name: 
-- Module Name: EX_DM_pipe - Behavioral
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

entity EX_DM_pipe is
  Port ( Clock          : in std_logic;
         reset          : in std_logic;        
         mem_to_reg_in  : in std_logic;
         mem_write_in   : in std_logic;
         reg_write_in   : in std_logic;
         reg_dst_res_in : in std_logic_vector(3 downto 0);
         ex_result_in   : in std_logic_vector(31 downto 0);
         address_in     : in std_logic_vector(9 downto 0);
         write_data_in  : in std_logic_vector(31 downto 0);
         compare_output_in : in std_logic;
         branch_jmp_in  : in std_logic_vector(1 downto 0);         
         mem_to_reg_out : out std_logic;
         mem_write_out  : out std_logic;
         reg_write_out  : out std_logic;
         reg_dst_res_out: out std_logic_vector(3 downto 0);
         ex_result_out  : out std_logic_vector(31 downto 0);
         address_out    : out std_logic_vector(9 downto 0);
         write_data_out : out std_logic_vector(31 downto 0);
         compare_output_out : out std_logic;
         branch_jmp_out  : out std_logic_vector(1 downto 0));
end EX_DM_pipe;

architecture Behavioral of EX_DM_pipe is

    component pipeline_register_1bit is
        Port ( d   : IN STD_LOGIC;
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            q   : OUT STD_LOGIC);
    end component;
    
    component pipeline_register_2bit is
        Port (    d   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            q   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
    end component;
    
    component pipeline_register_4bit is
        Port (    d   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            q   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
    end component;
    
    component pipeline_register_10bit is
        Port (    d   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            q   : OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
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

    mem_write : pipeline_register_1bit
    port map ( d   => mem_write_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => mem_write_out);
               
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
               
    address : pipeline_register_10bit
    port map ( d   => address_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => address_out);
               
    write_data : pipeline_register_32bit
    port map ( d   => write_data_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => write_data_out);
                   
    compare_output : pipeline_register_1bit
    port map ( d   => compare_output_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => compare_output_out); 
                          
    branch_jmp: pipeline_register_2bit
    port map ( d   => branch_jmp_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => branch_jmp_out);   
                  
end Behavioral;
