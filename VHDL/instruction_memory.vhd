---------------------------------------------------------------------------
-- instruction_memory.vhd - Implementation of A Single-Port, 16 x 16-bit
--                          Instruction Memory.
-- 
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
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

entity instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(7 downto 0);
           insn_out : out std_logic_vector(23 downto 0) );
end instruction_memory;

architecture behavioral of instruction_memory is

type mem_array is array(0 to 255) of std_logic_vector(23 downto 0);
signal sig_insn_mem : mem_array;

begin
    mem_process: process ( clk,
                           addr_in ) is
  
    variable var_insn_mem : mem_array;
    variable var_addr     : integer;
  
    begin
        if (reset = '1') then
            -- initial values of the instruction memory :
            --  insn_0 : load  $1, $0, 0   - load data 0($0) into $1
            --  insn_1 : load  $2, $0, 1   - load data 1($0) into $2
            --  insn_2 : add   $3, $0, $1  - $3 <- $0 + $1
            --  insn_3 : add   $4, $1, $2  - $4 <- $1 + $2
            --  insn_4 : store $3, $0, 2   - store data $3 into 2($0)
            --  insn_5 : store $4, $0, 3   - store data $4 into 3($0)
            --  insn_6 - insn_15 : noop    - end of program

            --original instructions:
            --var_insn_mem(0)  := X"1010";
            --var_insn_mem(1)  := X"1021";
            --var_insn_mem(2)  := X"8013";
            --var_insn_mem(3)  := X"8124";
            --var_insn_mem(4)  := X"3032";
            --var_insn_mem(5)  := X"3043";
            
            var_insn_mem := (others => X"000000");
            --105001
            

           var_insn_mem(0 ) := X"A0500C"; -- 27  li        $t0, CTRL_WORD
            var_insn_mem(1 ) := X"A0F184"; -- 27  li        $t0, CTRL_WORD
            var_insn_mem(2 ) := X"BF500F"; -- 27  li        $t0, CTRL_WORD
            var_insn_mem(3 ) := X"AFF294"; -- 27  li        $t0, CTRL_WORD
            var_insn_mem(4 ) := X"A05004"; -- 27  li        $t0, CTRL_WORD
            var_insn_mem(5 ) := X"BF500F"; -- 27  li        $t0, CTRL_WORD
            var_insn_mem(6 ) := X"AF5009"; -- 27  li        $t0, CTRL_WORD
            var_insn_mem(7 ) := X"205210"; -- 27  sw        $t0, CTRL_WORD
            var_insn_mem(8) := X"A05001"; -- 39  li		$t0, 1 - C
            var_insn_mem(9) := X"852008"; -- 40  bne		$send, $t0, main_if_send_eq_1_f
            var_insn_mem(10) := X"A54000"; -- 41  move	$busy, $t0
            var_insn_mem(11) := X"A1B000"; -- 43  move	$a0, $rec
            var_insn_mem(12) := X"A3C000"; -- 44  move	$a1, $tag
            var_insn_mem(13) := X"105210"; -- 175 lw	  $t0, ctrl_word
            var_insn_mem(14) := X"000000"; -- 176 noop
            var_insn_mem(15) := X"3B5006"; -- 176 swap    $t1, $a0, $t0
            var_insn_mem(16) := X"465006"; -- 177 rolb    $t1, $t1, $t0
            var_insn_mem(17) := X"56500E"; -- 178 xorb    $v0, $t1, $t0
            var_insn_mem(18) := X"AE5000"; -- 103 move	$t0, $v0
            var_insn_mem(19) := X"8C5008"; -- 105 bne	$t0, $a1, not_process_record_if_tag_not_valid_t
            var_insn_mem(20) := X"A06000"; -- 109 li		$t1, 0
            var_insn_mem(21) := X"A07000"; -- 110 li		$t2, 0
            var_insn_mem(22) := X"A08000"; -- 111 li		$t3, 0
            var_insn_mem(23) := X"A09017"; -- 114 li		$t4, CANDT_ID_OFF
            var_insn_mem(24) := X"CB9006"; -- 115 srlv	$t1, $a0, $t4
            var_insn_mem(25) := X"A0901C"; -- 116 li		$t4, CANDT_ID_MSK
            var_insn_mem(26) := X"B69007"; -- 119 li		$t4, DISTR_ID_OFF
            var_insn_mem(27) := X"C79007"; -- 120 srlv	$t2, $a0, $t4
            var_insn_mem(28) := X"A09004"; -- 121 li		$t4, DISTR_ID_MSK
            var_insn_mem(29) := X"C69008"; -- 125 srlv	$t3, $a0, $t4
            var_insn_mem(30) := X"A09009"; -- 121 li		$t4, DISTR_ID_MSK
            var_insn_mem(31) := X"BB9006"; -- 119 li		$t4, DISTR_ID_OFF
            var_insn_mem(32) := X"C69006"; -- 119 li		$t4, DISTR_ID_OFF
            var_insn_mem(33) := X"A6B000"; -- 129 move	$a0, $t1
            var_insn_mem(34) := X"A7C000"; -- 130 move	$a1, $t2
            var_insn_mem(35) := X"A8D000"; -- 131 move	$a2, $t3
            var_insn_mem(36) := X"E78009"; -- 156 mul		$t4, $t2, $t3 
            var_insn_mem(37) := X"698009"; -- 156 add		$t3, $t4, $t3 
            var_insn_mem(38) := X"195000"; -- 158 lw		$t0, vote_count_table($t3)
            var_insn_mem(39) := X"29B000"; -- 159 sw		$a2, vote_count_table($t3)
            var_insn_mem(40) := X"DB5006"; -- 161 sub		$t1, $a2, $t0
            var_insn_mem(41) := X"1C7200"; -- 162 lw		$t2, vote_count_totals($t4)
            var_insn_mem(42) := X"000000"; -- 176 noop
            var_insn_mem(43) := X"676007"; -- 163 add		$t2, $t2, $t1
            var_insn_mem(44) := X"2C7200"; -- 164 sw		$t2, vote_count_totals($t4)
            var_insn_mem(45) := X"700008"; -- 134 j		process_record_rtn
      
        elsif (rising_edge(clk)) then
            -- read instructions on the rising clock edge
            var_addr := conv_integer(addr_in);
            insn_out <= var_insn_mem(var_addr);
        end if;

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;

    end process;
  
end behavioral;
