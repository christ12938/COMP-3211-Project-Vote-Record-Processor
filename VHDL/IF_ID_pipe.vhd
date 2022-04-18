----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2022 06:21:27 AM
-- Design Name: 
-- Module Name: IF_ID_pipe - Behavioral
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

entity IF_ID_pipe is
  Port ( Clock : IN STD_LOGIC;
         reset : IN STD_LOGIC;
         flush : IN STD_LOGIC;
         instruction_in: IN STD_LOGIC_VECTOR(23 DOWNTO 0);
         instruction_out: OUT STD_LOGIC_VECTOR(23 DOWNTO 0));
end IF_ID_pipe;

architecture Behavioral of IF_ID_pipe is

    component pipeline_register_24bit is
  Port (    d   : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            flush : IN STD_LOGIC;
            q   : OUT STD_LOGIC_VECTOR(23 DOWNTO 0));
    end component;
    
begin
    flushable_insn_reg : pipeline_register_24bit
    port map ( d   => instruction_in,
               ld      => '1',
               reset  => reset,
               Clock => Clock,
               flush =>  flush,
               q => instruction_out);

end Behavioral;
