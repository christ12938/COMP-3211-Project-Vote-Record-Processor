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
           start_signal    : in  std_logic;
           vote_record     : in  std_logic_vector(31 downto 0);
           tag             : in  std_logic_vector(7 downto 0);
           busy            : out std_logic);
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
           ex_reg     : out std_logic_vector(2 downto 0);
           cmp_mode   : out std_logic;
           branch_jmp : out std_logic_vector(1 downto 0);
           mem_read   : out std_logic;
           shift_mode : out std_logic;
           alu_mode   : out std_logic_vector(1 downto 0));
end component;

component register_file is
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           start_signal    : in  std_logic;
           vote_record     : in  std_logic_vector(31 downto 0);
           tag             : in  std_logic_vector(7 downto 0);
           read_register_a : in  std_logic_vector(3 downto 0);
           read_register_b : in  std_logic_vector(3 downto 0);
           write_enable    : in  std_logic;
           write_register  : in  std_logic_vector(3 downto 0);
           write_data      : in  std_logic_vector(31 downto 0);
           read_data_a     : out std_logic_vector(31 downto 0);
           read_data_b     : out std_logic_vector(31 downto 0);
           busy            : out std_logic );
end component;

component adder_8b is
    port ( src_a     : in  std_logic_vector(7 downto 0);
           src_b     : in  std_logic_vector(7 downto 0);
           stall     : in std_logic;
           sum       : out std_logic_vector(7 downto 0);
           carry_out : out std_logic );
end component;

component adder_32b is
    port ( alu_mode  : in  std_logic_vector(1 downto 0) ;
           src_a     : in  std_logic_vector(31 downto 0);
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

component mux_8to1_32b is
    port ( mux_select : in  std_logic_vector(2 downto 0);
           data_a     : in  std_logic_vector(31 downto 0);
           data_b     : in  std_logic_vector(31 downto 0);
           data_c     : in  std_logic_vector(31 downto 0);
           data_d     : in  std_logic_vector(31 downto 0);
           data_e     : in  std_logic_vector(31 downto 0);
           data_out   : out std_logic_vector(31 downto 0) );
end component;

component rotater is
  Port ( control_word: in std_logic_vector(11 downto 0);
         vote_record : in std_logic_vector(31 downto 0);
         data_out   : out std_logic_vector(31 downto 0));
end component;

component swapper is
  Port ( swapper_start  : in std_logic_vector(2 downto 0);
         control_word   : in std_logic_vector(12 downto 0);
         vote_record    : in std_logic_vector(31 downto 0);
         data_out       : out std_logic_vector(31 downto 0));
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

component IF_ID_pipe is
  Port ( Clock : IN STD_LOGIC;
         reset : IN STD_LOGIC;
         flush : IN STD_LOGIC;
         instruction_in: IN STD_LOGIC_VECTOR(23 DOWNTO 0);
         instruction_out: OUT STD_LOGIC_VECTOR(23 DOWNTO 0));
end component;

component ID_EX_pipe is
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
         alu_mode_in    : in std_logic_vector(1 downto 0);
         cmp_mode_in    : in  std_logic;
         branch_jmp_in  : in  std_logic_vector(1 downto 0);
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
         alu_mode_out   : out std_logic_vector(1 downto 0);
         cmp_mode_out   : out std_logic;
         branch_jmp_out : out std_logic_vector(1 downto 0));
end component;

component EX_DM_pipe is
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
end component;

component DM_WB_pipe is
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
end component;

component hazard_detection_unit is
  Port ( ID_EX_compare_output : in  std_logic;
         ID_EX_branch_jmp     : in  std_logic_vector(1 downto 0);
         EX_DM_compare_output : in  std_logic;
         EX_DM_branch_jmp     : in  std_logic_vector(1 downto 0);
         ID_EX_mem_read : in std_logic;
         ID_EX_reg_rt   : in std_logic_vector(3 downto 0);
         IF_ID_reg_rs   : in std_logic_vector(3 downto 0);
         IF_ID_reg_rt   : in std_logic_vector(3 downto 0);
         stall          : out std_logic;
         flush          : out std_logic);
end component;

component mux_2to1_24b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(23 downto 0);
           data_b     : in  std_logic_vector(23 downto 0);
           data_out   : out std_logic_vector(23 downto 0) );
end component;

component stalling_ctrl_unit is
  Port ( stall_sel      : in  std_logic;
         reg_write_in   : in  std_logic;
         alu_src_in     : in  std_logic;
         mem_write_in   : in  std_logic;
         mem_to_reg_in  : in  std_logic;
         ex_reg_in      : in  std_logic_vector(2 downto 0);
         mem_read_in    : in  std_logic;
         shift_mode_in  : in  std_logic;
         alu_mode_in    : in  std_logic_vector(1 downto 0);
         cmp_mode_in    : in  std_logic;
         branch_jmp_in  : in  std_logic_vector(1 downto 0);
         reg_write_out  : out std_logic;
         alu_src_out    : out std_logic;
         mem_write_out  : out std_logic;
         mem_to_reg_out : out std_logic;
         ex_reg_out     : out std_logic_vector(2 downto 0);
         mem_read_out   : out std_logic;
         shift_mode_out : out std_logic;
         alu_mode_out   : out std_logic_vector(1 downto 0);
         cmp_mode_out   : out std_logic;
         branch_jmp_out : out std_logic_vector(1 downto 0));  
end component;

component forwarding_unit is
  Port ( DM_WB_reg_write: in std_logic;
         EX_DM_reg_write: in std_logic;
         DM_WB_Rd       : in std_logic_vector(3 downto 0);
         EX_DM_Rd       : in std_logic_vector(3 downto 0);
         ID_EX_Rs       : in std_logic_vector(3 downto 0);
         ID_EX_Rt       : in std_logic_vector(3 downto 0);
         ID_EX_mem_write: in std_logic;
         EX_DM_mem_write: in std_logic;
         alu_mux_1      : out std_logic;
         alu_mux_2      : out std_logic;
         alu_mux_3      : out std_logic;
         alu_mux_4      : out std_logic;
         dm_data_mux    : out std_logic;
         ex_data_mux    : out std_logic);
end component;

component logical_shifter is
  Port ( shift_mode : in std_logic;
         data_in    : in std_logic_vector(31 downto 0);
         bits       : in std_logic_vector(4 downto 0);
         data_out   : out std_logic_vector(31 downto 0));
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
signal sig_exec_to_memreg       : std_logic_vector(2 downto 0);
signal sig_compare_output       : std_logic;
signal sig_branch_addr          : std_logic_vector(7 downto 0);
signal sig_cmp_mode             : std_logic;
signal sig_branch_jmp           : std_logic_vector(1 downto 0);
signal IF_ID_instruction        : std_logic_vector(23 downto 0);
signal ID_EX_mem_to_reg         : std_logic;
signal ID_EX_mem_write          : std_logic;
signal ID_EX_alu_src            : std_logic;
signal ID_EX_reg_write          : std_logic;
signal ID_EX_reg_dst_res        : std_logic_vector(3 downto 0);
signal ID_EX_read_data_1        : std_logic_vector(31 downto 0);
signal ID_EX_read_data_2        : std_logic_vector(31 downto 0);
signal ID_EX_immediate          : std_logic_vector(31 downto 0);
signal ID_EX_ex_reg             : std_logic_vector(2 downto 0);
signal ID_EX_mem_read           : std_logic;
signal ID_EX_register_rt        : std_logic_vector(3 downto 0);
signal EX_DM_mem_to_reg         : std_logic;
signal EX_DM_mem_write          : std_logic;
signal EX_DM_reg_write          : std_logic;
signal EX_DM_reg_dst_res        : std_logic_vector(3 downto 0);
signal EX_DM_ex_reg_result      : std_logic_vector(31 downto 0);
signal EX_DM_alu_result         : std_logic_vector(31 downto 0);
signal DM_WB_mem_to_reg         : std_logic;
signal DM_WB_reg_write          : std_logic;
signal DM_WB_reg_dst_res        : std_logic_vector(3 downto 0);
signal DM_WB_ex_result          : std_logic_vector(31 downto 0);
signal DM_WB_read_data          : std_logic_vector(31 downto 0);
signal sig_dm_addr              : std_logic_vector(9 downto 0);
signal sig_dm_write_data        : std_logic_vector(31 downto 0);
signal sig_flush                : std_logic;
signal sig_stall                : std_logic;
signal sig_instr_hazard_in      : std_logic_vector(23 downto 0);
signal sig_mem_read             : std_logic;
signal sig_register_rs          : std_logic_vector(3 downto 0);
signal sig_register_rt          : std_logic_vector(3 downto 0);
signal stall_reg_write          : std_logic;
signal stall_alu_src            : std_logic;
signal stall_mem_to_reg         : std_logic;
signal stall_mem_write          : std_logic;
signal stall_ex_reg             : std_logic_vector(2 downto 0);
signal stall_mem_read           : std_logic;
signal sig_alu_mux_1            : std_logic;
signal sig_alu_mux_2            : std_logic;
signal forwarding_read_data_1   : std_logic_vector(31 downto 0);
signal forwarding_read_data_2   : std_logic_vector(31 downto 0);
signal ID_EX_shift_mode         : std_logic;
signal sig_shift_mode           : std_logic;
signal stall_shift_mode         : std_logic;
signal sig_shifter_out          : std_logic_vector(31 downto 0);
signal stall_alu_mode           : std_logic_vector(1 downto 0);
signal ID_EX_alu_mode           : std_logic_vector(1 downto 0);
signal sig_alu_mode             : std_logic_vector(1 downto 0);
signal stall_cmp_mode           : std_logic;
signal stall_branch_jmp         : std_logic_vector(1 downto 0);
signal ID_EX_cmp_mode           : std_logic;
signal ID_EX_branch_jmp         : std_logic_vector(1 downto 0);
signal sig_stall_sel            : std_logic;
signal sig_dm_data_mux          : std_logic;
signal sig_ex_data_mux          : std_logic;
signal sig_dm_write_data_mux    : std_logic_vector(31 downto 0);
signal EX_DM_dm_write_data      : std_logic_vector(31 downto 0);
signal sig_alu_src_3            : std_logic_vector(31 downto 0);
signal sig_alu_src_4            : std_logic_vector(31 downto 0);
signal sig_alu_mux_3            : std_logic;
signal sig_alu_mux_4            : std_logic;
signal EX_DM_compare_output_out : std_logic;
signal EX_DM_branch_jmp_out     : std_logic_vector(1 downto 0);

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
               stall     => sig_stall,
               sum       => sig_next_normal_pc,   
               carry_out => sig_pc_carry_out );
    
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_curr_pc,
               insn_out => sig_instr_hazard_in);

    instruction_stall_mux: mux_2to1_24b
    port map ( mux_select => sig_stall,
               data_a     => sig_instr_hazard_in,
               data_b     => sig_insn,
               data_out   => IF_ID_instruction);

    hazard_detection: hazard_detection_unit
    port map ( ID_EX_compare_output  => sig_compare_output,
               ID_EX_branch_jmp      => sig_branch_jmp,
               EX_DM_compare_output  => EX_DM_compare_output_out,
               EX_DM_branch_jmp      => EX_DM_branch_jmp_out,
               ID_EX_mem_read  => sig_mem_read,
               ID_EX_reg_rt    => sig_register_rt,
               IF_ID_reg_rs    => sig_insn(19 downto 16),
               IF_ID_reg_rt    => sig_insn(15 downto 12),
               stall           => sig_stall,
               flush           => sig_flush);

    IF_ID_pipeline: IF_ID_pipe
    port map( Clock => clk,
              reset => reset,
              flush => sig_flush,
              instruction_in => IF_ID_instruction,
              instruction_out => sig_insn);
              
    compare_module : comparator
    port map ( cmp_mode => sig_cmp_mode,
               data_a   => sig_read_data_a,
               data_b   => sig_read_data_b,
               output   => sig_compare_output); 
    
    mux_beq_bne : mux_2to1_8b
    port map ( mux_select => sig_compare_output,
               data_a     => sig_next_normal_pc,
               data_b     => sig_sign_extended_offset(7 downto 0),
               data_out   => sig_branch_addr); 
    
    jump_branch_mux: mux_4to1_8b
    port map ( mux_select => sig_branch_jmp,
               data_a     => sig_next_normal_pc,
               data_b     => sig_sign_extended_offset(7 downto 0),
               data_c     => sig_branch_addr,
               data_d     => sig_next_normal_pc,
               data_out   => sig_next_pc);
                                
    sign_extend : sign_extend_12to32 
    port map ( data_in  => sig_insn(11 downto 0),
               data_out => ID_EX_immediate);

    ctrl_unit : control_unit 
    port map ( opcode     => sig_insn(23 downto 20),
               reg_dst    => sig_reg_dst,
               reg_write  => stall_reg_write,
               alu_src    => stall_alu_src,
               mem_write  => stall_mem_write,
               mem_to_reg => stall_mem_to_reg,
               ex_reg     => stall_ex_reg,
               cmp_mode   => stall_cmp_mode,
               branch_jmp => stall_branch_jmp,
               mem_read   => stall_mem_read,
               shift_mode => stall_shift_mode,
               alu_mode   => stall_alu_mode);

    sig_stall_sel <= sig_stall or sig_flush;
    
    stalling_unit: stalling_ctrl_unit
    port map ( stall_sel      => sig_stall_sel,
               reg_write_in   => stall_reg_write,
               alu_src_in     => stall_alu_src,
               mem_write_in   => stall_mem_write,
               mem_to_reg_in  => stall_mem_to_reg,
               ex_reg_in      => stall_ex_reg,
               mem_read_in    => stall_mem_read,
               shift_mode_in  => stall_shift_mode,
               alu_mode_in    => stall_alu_mode,
               cmp_mode_in    => stall_cmp_mode,
               branch_jmp_in  => stall_branch_jmp,
               reg_write_out  => ID_EX_reg_write,
               alu_src_out    => ID_EX_alu_src,
               mem_write_out  => ID_EX_mem_write,
               mem_to_reg_out => ID_EX_mem_to_reg,
               ex_reg_out     => ID_EX_ex_reg,
               mem_read_out   => ID_EX_mem_read,
               shift_mode_out => ID_EX_shift_mode,
               alu_mode_out   => ID_EX_alu_mode,
               cmp_mode_out   => ID_EX_cmp_mode,
               branch_jmp_out => ID_EX_branch_jmp);
               
    ID_EX_pipeline: ID_EX_pipe
    port map ( Clock           => clk,
               reset           => reset,
               mem_to_reg_in   => ID_EX_mem_to_reg,
               mem_write_in    => ID_EX_mem_write,
               alu_src_in      => ID_EX_alu_src,
               reg_write_in    => ID_EX_reg_write,
               reg_dst_res_in  => ID_EX_reg_dst_res,
               read_data_1_in  => ID_EX_read_data_1,
               read_data_2_in  => ID_EX_read_data_2,
               immediate_in    => ID_EX_immediate,
               ex_reg_in       => ID_EX_ex_reg,
               register_rs_in  => sig_insn(19 downto 16),
               register_rt_in  => sig_insn(15 downto 12),
               mem_read_in     => ID_EX_mem_read,
               shift_mode_in   => ID_EX_shift_mode,
               alu_mode_in     => ID_EX_alu_mode,
               cmp_mode_in     => ID_EX_cmp_mode,
               branch_jmp_in   => ID_EX_branch_jmp,
               mem_to_reg_out  => EX_DM_mem_to_reg,
               mem_write_out   => EX_DM_mem_write,
               alu_src_out     => sig_alu_src,
               reg_write_out   => EX_DM_reg_write,
               reg_dst_res_out => EX_DM_reg_dst_res,
               read_data_1_out => forwarding_read_data_1,
               read_data_2_out => forwarding_read_data_2,
               immediate_out   => sig_sign_extended_offset,
               ex_reg_out      => sig_exec_to_memreg,
               register_rs_out => sig_register_rs,
               register_rt_out => sig_register_rt,
               mem_read_out    => sig_mem_read,
               shift_mode_out  => sig_shift_mode,
               alu_mode_out    => sig_alu_mode,
               cmp_mode_out    => sig_cmp_mode,
               branch_jmp_out  => sig_branch_jmp);
    
    mux_reg_dst : mux_2to1_4b 
    port map ( mux_select => sig_reg_dst,
               data_a     => sig_insn(15 downto 12),
               data_b     => sig_insn(3 downto 0),
               data_out   => ID_EX_reg_dst_res);

    reg_file : register_file 
    port map ( reset           => reset, 
               clk             => clk,
               start_signal    => start_signal,
               vote_record     => vote_record,
               tag             => tag,
               read_register_a => sig_insn(19 downto 16),
               read_register_b => sig_insn(15 downto 12),
               write_enable    => sig_reg_write,
               write_register  => sig_write_register,
               write_data      => sig_write_data,
               read_data_a     => ID_EX_read_data_1,
               read_data_b     => ID_EX_read_data_2,
               busy            => busy);
    
    mux_alu_src : mux_2to1_32b 
    port map ( mux_select => sig_alu_src,
               data_a     => sig_read_data_b,
               data_b     => sig_sign_extended_offset,
               data_out   => sig_alu_src_b );

    mux_alu_src_1: mux_2to1_32b
    port map ( mux_select => sig_alu_mux_1,
               data_a     => forwarding_read_data_1,
               data_b     => sig_write_data,
               data_out   => sig_alu_src_3);
       
    mux_alu_src_2: mux_2to1_32b
    port map ( mux_select => sig_alu_mux_2,
               data_a     => forwarding_read_data_2,
               data_b     => sig_write_data,
               data_out   => sig_alu_src_4);
           
    mux_alu_src_3: mux_2to1_32b
    port map ( mux_select => sig_alu_mux_3,
               data_a     => sig_alu_src_3,
               data_b     => DM_WB_ex_result,
               data_out   => sig_read_data_a);

    mux_alu_src_4: mux_2to1_32b
    port map ( mux_select => sig_alu_mux_4,
               data_a     => sig_alu_src_4,
               data_b     => DM_WB_ex_result,
               data_out   => sig_read_data_b);
                                      
    alu : adder_32b 
    port map ( alu_mode  => sig_alu_mode,
               src_a     => sig_read_data_a,
               src_b     => sig_alu_src_b,
               sum       => EX_DM_alu_result,
               carry_out => sig_alu_carry_out );
        
    forwarding: forwarding_unit       
    port map (   DM_WB_reg_write => sig_reg_write,
                 EX_DM_reg_write => DM_WB_reg_write,
                 DM_WB_Rd        => sig_write_register,
                 EX_DM_Rd        => DM_WB_reg_dst_res,
                 ID_EX_Rs        => sig_register_rs,
                 ID_EX_Rt        => sig_register_rt,
                 ID_EX_mem_write => EX_DM_mem_write,
                 EX_DM_mem_write => sig_mem_write,
                 alu_mux_1       => sig_alu_mux_1,
                 alu_mux_2       => sig_alu_mux_2,
                 alu_mux_3       => sig_alu_mux_3,
                 alu_mux_4       => sig_alu_mux_4,
                 dm_data_mux     => sig_dm_data_mux,
                 ex_data_mux     => sig_ex_data_mux);

    dm_data_mux : mux_2to1_32b 
    port map ( mux_select => sig_dm_data_mux,
               data_a     => sig_dm_write_data_mux,
               data_b     => sig_write_data,
               data_out   => sig_dm_write_data);
    
    ex_data_mux : mux_2to1_32b 
    port map ( mux_select => sig_ex_data_mux,
               data_a     => sig_read_data_b,
               data_b     => sig_write_data,
               data_out   => EX_DM_dm_write_data);
               
    EX_DM_pipeline: EX_DM_pipe
    port map (  Clock           => clk,
                reset           => reset,       
                mem_to_reg_in   => EX_DM_mem_to_reg,
                mem_write_in    => EX_DM_mem_write,
                reg_write_in    => EX_DM_reg_write,
                reg_dst_res_in  => EX_DM_reg_dst_res,
                ex_result_in    => EX_DM_ex_reg_result,
                address_in      => EX_DM_alu_result(9 downto 0),
                write_data_in   => EX_DM_dm_write_data,
                compare_output_in => sig_compare_output,
                branch_jmp_in   => sig_branch_jmp,
                mem_to_reg_out  => DM_WB_mem_to_reg,
                mem_write_out   => sig_mem_write,
                reg_write_out   => DM_WB_reg_write,
                reg_dst_res_out => DM_WB_reg_dst_res,
                ex_result_out   => DM_WB_ex_result,
                address_out     => sig_dm_addr,
                write_data_out  => sig_dm_write_data_mux,
                compare_output_out    => EX_DM_compare_output_out,
                branch_jmp_out  => EX_DM_branch_jmp_out);

    data_mem : data_memory 
    port map ( reset        => reset,
               clk          => clk,
               write_enable => sig_mem_write,
               write_data   => sig_dm_write_data,
               addr_in      => sig_dm_addr,
               data_out     => DM_WB_read_data);
               
    DM_WB_pipeline: DM_WB_pipe
    port map ( Clock           => clk,
               reset           => reset,    
               mem_to_reg_in   => DM_WB_mem_to_reg,
               reg_write_in    => DM_WB_reg_write,
               reg_dst_res_in  => DM_WB_reg_dst_res,
               ex_result_in    => DM_WB_ex_result,
               read_data_in    => DM_WB_read_data,
               mem_to_reg_out  => sig_mem_to_reg,
               reg_write_out   => sig_reg_write,
               reg_dst_res_out => sig_write_register,
               ex_result_out   => sig_exec_mux_out,
               read_data_out   => sig_data_mem_out);      
    
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
    port map ( swapper_start => sig_exec_to_memreg,
               control_word => sig_read_data_b(12 downto 0),
               vote_record  => sig_read_data_a,
               data_out     => sig_swapper_out);

    xorr_module: xor_module
    port map ( vote_record  => sig_read_data_a,
               data_out     => sig_xor_out);
    
    exec_mux: mux_8to1_32b
    port map ( mux_select => sig_exec_to_memreg,
               data_a     => EX_DM_alu_result,
               data_b     => sig_rotater_out,
               data_c     => sig_swapper_out,
               data_d     => sig_xor_out,
               data_e     => sig_shifter_out,
               data_out   => EX_DM_ex_reg_result);
               
     shifter: logical_shifter
     port map ( shift_mode => sig_shift_mode,
                data_in    => sig_read_data_a,
                bits       => sig_read_data_b(4 downto 0),
                data_out   => sig_shifter_out);         
end structural;
