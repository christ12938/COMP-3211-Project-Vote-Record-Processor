---------------------------------------------------------------------------
-- data_memory.vhd - Implementation of A Single-Port, 16 x 16-bit Data
--                   Memory.
-- 
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           write_data   : in  std_logic_vector(31 downto 0);
           read_mode    : in  std_logic;
           ldsr_ctrl    : in  std_logic;
           lrb_ctrl     : in  std_logic;
           addr_in      : in  std_logic_vector(3 downto 0);
           vote_record  : in  std_logic_vector(31 downto 0);
           data_out     : out std_logic_vector(31 downto 0) );
end data_memory;

architecture behavioral of data_memory is

constant control_word : std_logic_vector(24 downto 0) := "1100001000010100101000110";

-- fix above line and make control word programmable

type vote_record_array is array(0 to 3) of std_logic_vector(7 downto 0);
signal vote_record_list: vote_record_array;

type mem_array is array(0 to 15) of std_logic_vector(31 downto 0);
signal sig_data_mem : mem_array;

begin
    
    vote_record_list(0) <= vote_record(7 downto 0);
    vote_record_list(1) <= vote_record(15 downto 8);
    vote_record_list(2) <= vote_record(23 downto 16);
    vote_record_list(3) <= vote_record(31 downto 24);

    mem_process: process ( clk,
                           write_enable,
                           write_data,
                           addr_in,
                           ldsr_ctrl) is
  
    variable var_data_mem : mem_array;
    variable var_addr     : integer;
    
    begin
        var_addr := conv_integer(addr_in);
        
        if (reset = '1') then
            -- initial values of the data memory : reset to zero 
            var_data_mem(0)  := X"0000000A";
            var_data_mem(1)  := X"0000000B";
            var_data_mem(2)  := X"00000000";
            var_data_mem(3)  := X"00000000";
            var_data_mem(4)  := X"00000000";
            var_data_mem(5)  := X"00000000";
            var_data_mem(6)  := X"00000000";
            var_data_mem(7)  := X"00000000";
            var_data_mem(8)  := X"00000000";
            var_data_mem(9)  := X"00000000";
            var_data_mem(10) := X"00000000";
            var_data_mem(11) := X"00000000";
            var_data_mem(12) := X"00000000";
            var_data_mem(13) := X"00000000";
            var_data_mem(14) := X"00000000";
            var_data_mem(15) := X"00000000";

        elsif (falling_edge(clk) and write_enable = '1') then
            -- memory writes on the falling clock edge
            var_data_mem(var_addr) := write_data;
        end if;
       
        -- continuous read of the memory location given by var_addr 
        if ldsr_ctrl = '1' then
            data_out <= "0000000" & control_word;
        elsif lrb_ctrl = '1' then
            data_out <= x"000000" & vote_record_list(var_addr);
        else
            data_out <= var_data_mem(var_addr);
        end if;
 
        -- the following are probe signals (for simulation purpose) 
        sig_data_mem <= var_data_mem;

    end process;
  
end behavioral;
