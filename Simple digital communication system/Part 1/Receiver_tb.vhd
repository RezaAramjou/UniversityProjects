library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Receiver_tb is
end Receiver_tb;

architecture Behavioral of Receiver_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component Receiver
        Port (
            clk                        : in  STD_LOGIC;
            reset                      : in  STD_LOGIC;
            En                         : in  STD_LOGIC;
            Rx                         : in  STD_LOGIC;
            header_out                 : out STD_LOGIC_VECTOR (7 downto 0);
            encoded_data_out           : out STD_LOGIC_VECTOR (11 downto 0);
            footer_out                 : out STD_LOGIC_VECTOR (7 downto 0);
            ready                      : out STD_LOGIC;
            debug_shift_reg            : out STD_LOGIC_VECTOR (27 downto 0);  -- Debug signal for shift register
            corrected_data_out         : out STD_LOGIC_VECTOR (7 downto 0);  -- Signal for corrected data
            corrected_encoded_data_out : out STD_LOGIC_VECTOR (11 downto 0);  -- Signal for corrected encoded data
            corrupted_bit_out          : out STD_LOGIC_VECTOR (3 downto 0);  -- Signal for corrupted bit
            new_parity_out             : out STD_LOGIC_VECTOR (3 downto 0);  -- Signal for new parity bits
            old_parity_out             : out STD_LOGIC_VECTOR (3 downto 0)   -- Signal for old parity bits
        );
    end component;

    -- Inputs
    signal clk                        : STD_LOGIC := '0';
    signal reset                      : STD_LOGIC := '0';
    signal En                         : STD_LOGIC := '0';
    signal Rx                         : STD_LOGIC := '0';

    -- Outputs
    signal header_out                 : STD_LOGIC_VECTOR (7 downto 0);
    signal encoded_data_out           : STD_LOGIC_VECTOR (11 downto 0);
    signal footer_out                 : STD_LOGIC_VECTOR (7 downto 0);
    signal ready                      : STD_LOGIC;
    signal debug_shift_reg            : STD_LOGIC_VECTOR (27 downto 0);
    signal corrected_data_out         : STD_LOGIC_VECTOR (7 downto 0);
    signal corrected_encoded_data_out : STD_LOGIC_VECTOR (11 downto 0);
    signal corrupted_bit_out          : STD_LOGIC_VECTOR (3 downto 0);
    signal new_parity_out             : STD_LOGIC_VECTOR (3 downto 0);
    signal old_parity_out             : STD_LOGIC_VECTOR (3 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: Receiver Port map (
            clk => clk,
            reset => reset,
            En => En,
            Rx => Rx,
            header_out => header_out,
            encoded_data_out => encoded_data_out,
            footer_out => footer_out,
            ready => ready,
            debug_shift_reg => debug_shift_reg,
            corrected_data_out => corrected_data_out,
            corrected_encoded_data_out => corrected_encoded_data_out,
            corrupted_bit_out => corrupted_bit_out,
            new_parity_out => new_parity_out,
            old_parity_out => old_parity_out
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        reset <= '1';
        En <= '0';
        wait for clk_period*3.5;
        
        reset <= '0';
        wait for clk_period*4;

        En <= '1';
        wait for clk_period*4;

        -- Send 28 bits (header, encoded_data, footer)
        Rx <= '1'; wait for clk_period;  -- Start bit (or any bit)
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        
        -- Encoded data (example)
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        
        -- Footer
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;

        -- Wait for output to be ready
        wait for clk_period*4;

        -- Apply reset before the second test case
        reset <= '1';
        En <= '0';
        wait for clk_period*4;
        
        reset <= '0';
        wait for clk_period*4;
        
        En <= '1';
        wait for clk_period*2;
        
        -- Send another 28 bits
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        
        -- Encoded data (example)
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        
        -- Footer
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '0'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;
        Rx <= '1'; wait for clk_period;

        -- Wait for the second output to be ready
        wait for clk_period*4;

        -- Stop simulation
        wait;
    end process;

end Behavioral;