----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2022 06:33:00 PM
-- Design Name: 
-- Module Name: register - Behavioral
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

entity pipeline_register_24bit is
  Port (    d   : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            ld  : IN STD_LOGIC; -- load/enable.
            reset : IN STD_LOGIC; -- async. clear.
            Clock : IN STD_LOGIC; -- clock.
            flush : IN STD_LOGIC;
            q   : OUT STD_LOGIC_VECTOR(23 DOWNTO 0));
end pipeline_register_24bit;

architecture Behavioral of pipeline_register_24bit is
begin
    process(Clock, reset)
        begin
            if reset = '1' then
                q <= x"000000";
            elsif rising_edge(Clock) then
                if ld = '1' then
                    if flush = '1' then
                        q <= x"000000";
                    else
                        q <= d;
                    end if;
                end if;
            end if;
    end process;
end Behavioral;
