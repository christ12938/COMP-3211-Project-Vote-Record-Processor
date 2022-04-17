
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


entity VoteCountSim is
end VoteCountSim;


architecture behave of VoteCountSim is
 
    -- 1 GHz = 2 nanoseconds period
    constant c_CLOCK_PERIOD : time      := 2 ns;
    constant record_source  : string    := "records.txt";
    constant control_word   : string    := "";


    signal r_CLOCK     : std_logic := '0';
    signal r_reset     : std_logic := '0';
 

    -- Component declaration for the Unit Under Test (UUT)
    component single_cycle_core is
        port ( reset  : in  std_logic;
           clk    : in  std_logic
            );
    end component ;
          
    begin
        -- Instantiate the Unit Under Test (UUT)
        -- NOTES: 
        --      -  
        UUT : single_cycle_core port map (
            reset    => r_reset,
            clk     => r_CLOCK 
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
            variable vote_record : integer; -- std_logic_vector(31 downto 0);
            variable busy : boolean;
        begin
            -- directly load control word from here
            -- read file
            file_open(read_file, record_source, read_mode);
            while not endfile(read_file) loop
                busy := false;
                if busy then
                    wait for 100ns;
                else 
                    readline(read_file, line_v);
                    read(line_v, vote_record); -- turn txt to usable binary value
                    
                    -- TODO: send signal to input of processor
                    
                    
                    -- TODO: enable send instruction
                    
                    wait for 10ns ;
                    
                    -- TODO: disable send instruction
                end if;
            end loop;
            
            file_close(read_file);  
            
--            r_reset <= '0';
       
--            wait for 2*c_CLOCK_PERIOD ;
--            r_reset <= '1';
           
--            wait for 2*c_CLOCK_PERIOD ;
--            r_reset <= '0';         
          
--            wait for 2 sec;
           
        end process;
         
end architecture;