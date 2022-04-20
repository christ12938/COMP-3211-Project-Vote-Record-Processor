
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;


entity VoteCountSim is
end VoteCountSim;


architecture behave of VoteCountSim is
 
    -- 1 GHz = 2 nanoseconds period
    constant c_CLOCK_PERIOD : time      := 2 ns;
    constant record_source      : string                        := "voterecords.txt";
    -- constant control_word_source: std_logic_vector(24 downto 0) := "1100001000010100101000110";


    signal r_CLOCK     : std_logic := '0';
    signal r_reset     : std_logic := '0';
    signal r_start_signal: std_logic := '0';
    -- signal r_control_word: std_logic_vector(24 downto 0) := control_word_source;
    signal r_vote_record : std_logic_vector(31 downto 0) := (others => '0');
    signal r_busy: std_logic;
    
    
    -- Component declaration for the Unit Under Test (UUT)
    component single_cycle_core is
        port ( reset  : in  std_logic;
           clk    : in  std_logic;
           start_signal    : in  std_logic;
           vote_record     : in  std_logic_vector(31 downto 0);
           tag             : in  std_logic_vector(7 downto 0);
           busy            : out std_logic);
    end component ;
          
    begin
        -- Instantiate the Unit Under Test (UUT)
        -- NOTES: 
        --      -  
        UUT : single_cycle_core port map (
            reset    => r_reset,
            clk     => r_CLOCK,
            start_signal => r_start_signal,
            vote_record => r_vote_record,
            tag            => X"92",
            busy           => r_busy
        );
       
        p_CLK_GEN : process is
        begin
            wait for c_CLOCK_PERIOD/2;
            r_CLOCK <= not r_CLOCK;
        end process p_CLK_GEN; 
         
      
      
        
        process is                            -- main testing
            -- initialise reading text file
            variable line_v : line;
            file read_file : text;
            variable line_data: std_logic_vector(31 downto 0); 
            
        begin
            r_reset <= '1';
            wait for 20ns;
            r_reset <= '0';
            
            -- directly load control word from here
            -- none
            
            -- read file
            file_open(read_file, record_source, read_mode); 
            
            while not endfile(read_file) loop
                
                
                if r_busy = '1' then
                    wait for 100ns;
                else
                    readline(read_file, line_v);
                    
                    -- turn txt to usable binary value
                    read(line_v, line_data);
                    
                    -- send signal to input of processor
                    r_vote_record <= line_data;
                    
                    -- enable send instruction
                    r_start_signal <= '1';
                    wait until r_busy <= '1';
                    r_start_signal <= '0';
                   
                    
                end if;
            end loop;
            
            file_close(read_file);  
            
            wait;
--            r_reset <= '0';
       
--            wait for 2*c_CLOCK_PERIOD ;
--            r_reset <= '1';
           
--            wait for 2*c_CLOCK_PERIOD ;
--            r_reset <= '0';         
          
--            wait for 2 sec;
           
        end process;
         
end architecture;