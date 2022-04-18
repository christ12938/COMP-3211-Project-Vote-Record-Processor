----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2022 06:21:27 AM
-- Design Name: 
-- Module Name: ID_EX_pipe - Behavioral
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

entity ID_EX_pipe is
  Port ( Clock          : in std_logic;
         reset          : in std_logic;
         mem_to_reg_in  : in std_logic;
         mem_write_in   : in std_logic;
         alu_src_in     : in std_logic;
         reg_write_in   : in std_logic;
         reg_dst_res_in : in std_logic_vector(3 downto 0);
         read_data_1_in : in std_logic_vector(31 downto 0);
         read_data_2_in : in std_logic_vector(31 downto 0);
         immediate_in   : in std_logic_vector(31 downto 0);
         ex_reg_in      : in std_logic_vector(2 downto 0);
         register_rs_in : in std_logic_vector(3 downto 0);
         register_rt_in : in std_logic_vector(3 downto 0);
         mem_read_in    : in std_logic;
         shift_mode_in  : in std_logic;
         alu_mode_in    : in std_logic;
         mem_to_reg_out : out std_logic;
         mem_write_out  : out std_logic;
         alu_src_out    : out std_logic;
         reg_write_out  : out std_logic;
         reg_dst_res_out: out std_logic_vector(3 downto 0);
         read_data_1_out: out std_logic_vector(31 downto 0);
         read_data_2_out: out std_logic_vector(31 downto 0);
         immediate_out  : out std_logic_vector(31 downto 0);
         ex_reg_out     : out std_logic_vector(2 downto 0);
         register_rs_out: out std_logic_vector(3 downto 0);
         register_rt_out: out std_logic_vector(3 downto 0);
         mem_read_out   : out std_logic;
         shift_mode_out : out std_logic;
         alu_mode_out   : out std_logic);
end ID_EX_pipe;

architecture Behavioral of ID_EX_pipe is

    component pipeline_register_1bit is
        Port ( d   : IN STD_LOGIC;
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            q   : OUT STD_LOGIC);
    end component;

    component pipeline_register_3bit is
    Port (    d   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            q   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
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

    mem_write : pipeline_register_1bit
    port map ( d   => mem_write_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => mem_write_out);
               
    alu_src : pipeline_register_1bit
    port map ( d   => alu_src_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => alu_src_out);
               
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
               
    read_data_1 : pipeline_register_32bit
    port map ( d   => read_data_1_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => read_data_1_out);
               
    read_data_2 : pipeline_register_32bit
    port map ( d   => read_data_2_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => read_data_2_out);
               
    immediate : pipeline_register_32bit
    port map ( d   => immediate_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => immediate_out);
               
    ex_reg : pipeline_register_3bit
    port map ( d   => ex_reg_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => ex_reg_out);   
        
    register_rs : pipeline_register_4bit
    port map ( d   => register_rs_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => register_rs_out);
               
    register_rt : pipeline_register_4bit
    port map ( d   => register_rt_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => register_rt_out);
               
    mem_read : pipeline_register_1bit
    port map ( d   => mem_read_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => mem_read_out);
               
    shift_mode : pipeline_register_1bit
    port map ( d   => shift_mode_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => shift_mode_out);
               
    alu_mode : pipeline_register_1bit
    port map ( d   => alu_mode_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               q => alu_mode_out);
end Behavioral;
