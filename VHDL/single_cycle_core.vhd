---------------------------------------------------------------------------
-- single_cycle_core.vhd - A Single-Cycle Processor Implementation
--
-- Notes : 
--
-- See single_cycle_core.pdf for the block diagram of this single
-- cycle processor core.
--
-- Instruction Set Architecture (ISA) for the single-cycle-core:
--   Each instruction is 16-bit wide, with four 4-bit fields.
--
--     noop      
--        # no operation or to signal end of program
--        # format:  | opcode = 0 |  0   |  0   |   0    | 
--
--     load  rt, rs, offset     
--        # load data at memory location (rs + offset) into rt
--        # format:  | opcode = 1 |  rs  |  rt  | offset |
--
--     store rt, rs, offset
--        # store data rt into memory location (rs + offset)
--        # format:  | opcode = 3 |  rs  |  rt  | offset |
--
--     add   rd, rs, rt
--        # rd <- rs + rt
--        # format:  | opcode = 8 |  rs  |  rt  |   rd   |
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

entity single_cycle_core is
    port ( reset  : in  std_logic;
           clk    : in  std_logic;
           control_word    : in  std_logic_vector(24 downto 0);
           start_signal    : in  std_logic;
           vote_record     : in  std_logic_vector(31 downto 0));
end single_cycle_core;

architecture structural of single_cycle_core is

component program_counter is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(7 downto 0);
           addr_out : out std_logic_vector(7 downto 0) );
end component;

component instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(7 downto 0);
           insn_out : out std_logic_vector(23 downto 0) );
end component;

component sign_extend_12to32 is
    port ( data_in  : in  std_logic_vector(11 downto 0);
           data_out : out std_logic_vector(31 downto 0) );
end component;

component mux_2to1_4b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(3 downto 0);
           data_b     : in  std_logic_vector(3 downto 0);
           data_out   : out std_logic_vector(3 downto 0) );
end component;

component mux_2to1_32b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(31 downto 0);
           data_b     : in  std_logic_vector(31 downto 0);
           data_out   : out std_logic_vector(31 downto 0) );
end component;

component control_unit is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
           mem_write  : out std_logic;
           mem_to_reg : out std_logic;
           ex_reg     : out std_logic_vector(1 downto 0);
           cmp_mode   : out std_logic;
           branch_jmp : out std_logic_vector(1 downto 0));
end component;

component register_file is
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           control_word    : in  std_logic_vector(24 downto 0);
           start_signal    : in  std_logic;
           vote_record     : in  std_logic_vector(31 downto 0);
           read_register_a : in  std_logic_vector(3 downto 0);
           read_register_b : in  std_logic_vector(3 downto 0);
           write_enable    : in  std_logic;
           write_register  : in  std_logic_vector(3 downto 0);
           write_data      : in  std_logic_vector(31 downto 0);
           read_data_a     : out std_logic_vector(31 downto 0);
           read_data_b     : out std_logic_vector(31 downto 0) );
end component;

component adder_8b is
    port ( src_a     : in  std_logic_vector(7 downto 0);
           src_b     : in  std_logic_vector(7 downto 0);
           sum       : out std_logic_vector(7 downto 0);
           carry_out : out std_logic );
end component;

component adder_32b is
    port ( src_a     : in  std_logic_vector(31 downto 0);
           src_b     : in  std_logic_vector(31 downto 0);
           sum       : out std_logic_vector(31 downto 0);
           carry_out : out std_logic );
end component;

component data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           write_data   : in  std_logic_vector(31 downto 0);
           addr_in      : in  std_logic_vector(9 downto 0);
           data_out     : out std_logic_vector(31 downto 0) );
end component;

component mux_4to1_32b is
    port ( mux_select : in  std_logic_vector(1 downto 0);
           data_a     : in  std_logic_vector(31 downto 0);
           data_b     : in  std_logic_vector(31 downto 0);
           data_c     : in  std_logic_vector(31 downto 0);
           data_d     : in  std_logic_vector(31 downto 0);
           data_out   : out std_logic_vector(31 downto 0) );
end component;

component rotater is
  Port ( control_word: in std_logic_vector(11 downto 0);
         vote_record : in std_logic_vector(31 downto 0);
         data_out   : out std_logic_vector(31 downto 0));
end component;

component swapper is
  Port ( control_word: in std_logic_vector(12 downto 0);
         vote_record : in std_logic_vector(31 downto 0);
         data_out   : out std_logic_vector(31 downto 0));
end component;

component xor_module is
    Port (  vote_record : in std_logic_vector(31 downto 0);
            data_out    : out std_logic_vector(31 downto 0));
end component;

component comparator is
    Port ( cmp_mode : std_logic;
           data_a   : in std_logic_vector(31 downto 0);
           data_b   : in std_logic_vector(31 downto 0);
           output   : out std_logic);
end component;

component mux_2to1_8b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(7 downto 0);
           data_b     : in  std_logic_vector(7 downto 0);
           data_out   : out std_logic_vector(7 downto 0) );
end component;

component mux_4to1_8b is
    port ( mux_select : in  std_logic_vector(1 downto 0);
           data_a     : in  std_logic_vector(7 downto 0);
           data_b     : in  std_logic_vector(7 downto 0);
           data_c     : in  std_logic_vector(7 downto 0);
           data_d     : in  std_logic_vector(7 downto 0);
           data_out   : out std_logic_vector(7 downto 0) );
end component;


signal sig_next_pc              : std_logic_vector(7 downto 0);
signal sig_next_normal_pc       : std_logic_vector(7 downto 0);
signal sig_curr_pc              : std_logic_vector(7 downto 0);
signal sig_one_8b               : std_logic_vector(7 downto 0);
signal sig_pc_carry_out         : std_logic;
signal sig_insn                 : std_logic_vector(23 downto 0);
signal sig_sign_extended_offset : std_logic_vector(31 downto 0);
signal sig_reg_dst              : std_logic;
signal sig_reg_write            : std_logic;
signal sig_alu_src              : std_logic;
signal sig_mem_write            : std_logic;
signal sig_mem_to_reg           : std_logic;
signal sig_write_register       : std_logic_vector(3 downto 0);
signal sig_write_data           : std_logic_vector(31 downto 0);
signal sig_read_data_a          : std_logic_vector(31 downto 0);
signal sig_read_data_b          : std_logic_vector(31 downto 0);
signal sig_alu_src_b            : std_logic_vector(31 downto 0);
signal sig_alu_result           : std_logic_vector(31 downto 0); 
signal sig_alu_carry_out        : std_logic;
signal sig_data_mem_out         : std_logic_vector(31 downto 0);
signal sig_rotater_out          : std_logic_vector(31 downto 0);
signal sig_swapper_out          : std_logic_vector(31 downto 0);
signal sig_xor_out              : std_logic_vector(31 downto 0);
signal sig_exec_mux_out         : std_logic_vector(31 downto 0);
signal sig_exec_to_memreg       : std_logic_vector(1 downto 0);
signal sig_compare_output       : std_logic;
signal sig_branch_addr          : std_logic_vector(7 downto 0);
signal sig_cmp_mode             : std_logic;
signal sig_branch_jmp          : std_logic_vector(1 downto 0);

begin

    sig_one_8b <= X"01";

    pc : program_counter
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_next_pc,
               addr_out => sig_curr_pc ); 

    next_pc : adder_8b 
    port map ( src_a     => sig_curr_pc, 
               src_b     => sig_one_8b,
               sum       => sig_next_normal_pc,   
               carry_out => sig_pc_carry_out );
    
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_curr_pc,
               insn_out => sig_insn );

    compare_module : comparator
    port map ( cmp_mode => sig_cmp_mode,
               data_a   => sig_read_data_a,
               data_b   => sig_read_data_b,
               output   => sig_compare_output); 
    
    mux_branch_jump : mux_2to1_8b
    port map ( mux_select => sig_compare_output,
               data_a     => sig_next_normal_pc,
               data_b     => sig_insn(7 downto 0),
               data_out   => sig_branch_addr); 
    
    jump_branch_mux: mux_4to1_8b
    port map ( mux_select => sig_branch_jmp,
               data_a     => sig_next_normal_pc,
               data_b     => sig_insn(7 downto 0),
               data_c     => sig_branch_addr,
               data_d     => sig_next_normal_pc,
               data_out   => sig_next_pc);
                                
    sign_extend : sign_extend_12to32 
    port map ( data_in  => sig_insn(11 downto 0),
               data_out => sig_sign_extended_offset );

    ctrl_unit : control_unit 
    port map ( opcode     => sig_insn(23 downto 20),
               reg_dst    => sig_reg_dst,
               reg_write  => sig_reg_write,
               alu_src    => sig_alu_src,
               mem_write  => sig_mem_write,
               mem_to_reg => sig_mem_to_reg,
               ex_reg     => sig_exec_to_memreg,
               cmp_mode   => sig_cmp_mode,
               branch_jmp => sig_branch_jmp);

    mux_reg_dst : mux_2to1_4b 
    port map ( mux_select => sig_reg_dst,
               data_a     => sig_insn(15 downto 12),
               data_b     => sig_insn(3 downto 0),
               data_out   => sig_write_register );

    reg_file : register_file 
    port map ( reset           => reset, 
               clk             => clk,
               control_word    => control_word,
               start_signal    => start_signal,
               vote_record     => vote_record,
               read_register_a => sig_insn(19 downto 16),
               read_register_b => sig_insn(15 downto 12),
               write_enable    => sig_reg_write,
               write_register  => sig_write_register,
               write_data      => sig_write_data,
               read_data_a     => sig_read_data_a,
               read_data_b     => sig_read_data_b );
    
    mux_alu_src : mux_2to1_32b 
    port map ( mux_select => sig_alu_src,
               data_a     => sig_read_data_b,
               data_b     => sig_sign_extended_offset,
               data_out   => sig_alu_src_b );

    alu : adder_32b 
    port map ( src_a     => sig_read_data_a,
               src_b     => sig_alu_src_b,
               sum       => sig_alu_result,
               carry_out => sig_alu_carry_out );

    data_mem : data_memory 
    port map ( reset        => reset,
               clk          => clk,
               write_enable => sig_mem_write,
               write_data   => sig_read_data_b,
               addr_in      => sig_alu_result(9 downto 0),
               data_out     => sig_data_mem_out );
               
    mux_mem_to_reg : mux_2to1_32b 
    port map ( mux_select => sig_mem_to_reg,
               data_a     => sig_exec_mux_out,
               data_b     => sig_data_mem_out,
               data_out   => sig_write_data );
    
    rotate_module: rotater
    port map ( control_word => sig_read_data_b(24 downto 13),
               vote_record  => sig_read_data_a,
               data_out     => sig_rotater_out);

    swapper_module: swapper
    port map ( control_word => sig_read_data_b(12 downto 0),
               vote_record  => sig_read_data_a,
               data_out     => sig_swapper_out);

    xorr_module: xor_module
    port map ( vote_record  => sig_read_data_a,
               data_out     => sig_xor_out);
    
    exec_mux: mux_4to1_32b
    port map ( mux_select => sig_exec_to_memreg,
               data_a     => sig_alu_result,
               data_b     => sig_rotater_out,
               data_c     => sig_swapper_out,
               data_d     => sig_xor_out,
               data_out   => sig_exec_mux_out);
               
end structural;
