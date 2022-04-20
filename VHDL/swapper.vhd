----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2022 01:44:10 AM
-- Design Name: 
-- Module Name: swapper - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity swapper is
  Port ( swapper_start  : in std_logic_vector(2 downto 0);
         control_word   : in std_logic_vector(12 downto 0);
         vote_record    : in std_logic_vector(31 downto 0);
         data_out       : out std_logic_vector(31 downto 0));
end swapper;

architecture Behavioral of swapper is
    signal b1: unsigned(1 downto 0);
    signal b2: unsigned(1 downto 0);
    signal p1: unsigned(2 downto 0);
    signal p2: unsigned(2 downto 0);
    signal s: unsigned(2 downto 0);
    signal data : unsigned(31 downto 0);
    
    signal block1start: integer := 0;
    signal block1end: integer := 0;
    signal block2start: integer := 0;
    signal block2end: integer := 0;
    
    signal block1wrap: integer := 0;
    signal block2wrap: integer := 0;
    
    signal block1: unsigned(7 downto 0);
    signal block2: unsigned(7 downto 0);
    signal shift_amount: integer := 0;
    signal block1mask: unsigned(31 downto 0);
    signal block2mask: unsigned(31 downto 0);
begin
    -- TODO: add wraparound for s bit
    b1 <= unsigned(control_word(1 downto 0));
    b2 <= unsigned(control_word(3 downto 2));
    p1 <= unsigned(control_word(6 downto 4));
    p2 <= unsigned(control_word(9 downto 7));
    s  <= unsigned(control_word(12 downto 10));
    
    -- load vote record
    data <= unsigned(vote_record);

    block1 <= unsigned(
        vote_record(
            ((TO_INTEGER(b1) + 1) * 8 - 1) 
            downto 
            (TO_INTEGER(b1)) * 8));
            
    block2 <= unsigned(                   
        vote_record(                      
            ((TO_INTEGER(b2) + 1) * 8 - 1)
            downto                        
            (TO_INTEGER(b2)) * 8));       
    
    shift_amount <= TO_INTEGER(p2) - TO_INTEGER(p1) + (TO_INTEGER(b2)- TO_INTEGER(b1)) * 8;
    
    block1 <= block1 ror shift_amount;
    block2 <= block2 rol shift_amount; 
    
    block1start <= ((TO_INTEGER(b1) + 1) * 8 - TO_INTEGER(p1) - 1);
    block2start <= ((TO_INTEGER(b2) + 1) * 8 - TO_INTEGER(p2) - 1);
    
    block1wrap  <= (block1start - TO_INTEGER(s) + 1) - (TO_INTEGER(b1) * 8);
    block2wrap  <= (block2start - TO_INTEGER(s) + 1) - (TO_INTEGER(b2) * 8);
    
    block1end   <= block1start - TO_INTEGER(s) + 1
                    WHEN block1wrap > 0
                    ELSE TO_INTEGER(b1) * 8;
                    
    block2end   <= block2start - TO_INTEGER(s) + 1
                    WHEN block2wrap > 0
                    ELSE TO_INTEGER(b1) * 8;
    
    
    -- mask
    block1mask(block1start downto block1end) <= (others => '1');
    block2mask(block2start downto block2end) <= (others => '1');
    
    -- wrap around
    block1mask(
        ((TO_INTEGER(b1) + 1) * 8 - 1) 
        downto 
        ((TO_INTEGER(b1) + 1) * 8 + block1wrap)
    ) <= (others => '1') WHEN block1wrap < 0;
    
    block2mask(
        ((TO_INTEGER(b2) + 1) * 8 - 1) 
        downto 
        ((TO_INTEGER(b2) + 1) * 8 + block2wrap)
    ) <= (others => '1') WHEN block2wrap < 0;
    
    -- substitute new blocks in
    data(
        ((TO_INTEGER(b1) + 1) * 8 - 1) 
        downto 
        (TO_INTEGER(b1) * 8)
    ) <= data(
        ((TO_INTEGER(b1) + 1) * 8 - 1) 
        downto 
        (TO_INTEGER(b1) * 8)
    ) or (block1 and block1mask(
            ((TO_INTEGER(b1) + 1) * 8 - 1) 
            downto 
            (TO_INTEGER(b1) * 8 )
        ));
    
    data(
        ((TO_INTEGER(b2) + 1) * 8 - 1) 
        downto 
        (TO_INTEGER(b2) * 8)
    ) <= data(
            ((TO_INTEGER(b2) + 1) * 8 - 1) 
            downto 
            (TO_INTEGER(b2) * 8)
        ) or (block2 and block2mask(
                ((TO_INTEGER(b2) + 1) * 8 - 1) 
                downto 
                (TO_INTEGER(b2) * 8 )
            ));
 
    
    -- assign to data out
    data_out <= std_logic_vector(data);
    
    
    

end Behavioral;
 