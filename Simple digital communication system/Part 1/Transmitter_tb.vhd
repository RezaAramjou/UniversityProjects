library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Transmitter_tb is
end Transmitter_tb;

architecture Behavioral of Transmitter_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component Transmitter
        Port (
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            En         : in  STD_LOGIC;
            ready      : out STD_LOGIC;
            header_in  : in  STD_LOGIC_VECTOR (7 downto 0);
            data_in    : in  STD_LOGIC_VECTOR (7 downto 0);
            footer_in  : in  STD_LOGIC_VECTOR (7 downto 0);
            Tx         : out STD_LOGIC;
            noise_bit  : in  integer range 0 to 11
        );
    end component;

    -- Inputs
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal En        : STD_LOGIC := '0';
    signal header_in : STD_LOGIC_VECTOR (7 downto 0) := "10101010";
    signal data_in   : STD_LOGIC_VECTOR (7 downto 0) := "10011110";
    signal footer_in : STD_LOGIC_VECTOR (7 downto 0) := "01010101" ;
    signal noise_bit : integer range 0 to 11;

    -- Outputs
    signal ready            : STD_LOGIC;
    signal Tx               : STD_LOGIC;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: Transmitter Port map (
            clk => clk,
            reset => reset,
            En => En,
            ready => ready,
            header_in => header_in,
            data_in => data_in,
            footer_in => footer_in,
            Tx => Tx,
            noise_bit => noise_bit
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
        wait for clk_period*1.5;
        
        reset <= '0';
        wait for clk_period*2;
        
        -- First Test Case
        noise_bit <= 2;
        wait for clk_period*2;
        header_in <= "10101010";
        data_in <= "10011110";
        footer_in <= "01010101";
        wait for clk_period*4;
        En <= '1';
        

        -- Wait for the first transmission to complete
        wait for clk_period*30;
        
        En <= '0';

        -- Apply reset before the second test case
        reset <= '1';
		  noise_bit <= 0;
        wait for clk_period*2;
        
        reset <= '0';
        wait for clk_period*2;
        
        -- Second Test Case
        noise_bit <= 2;
        wait for clk_period*2;
        header_in <= "11110000";
        data_in <= "01100110";
        footer_in <= "00001111";
        wait for clk_period*4;
        En <= '1';
        

        -- Wait for the Second transmission to complete
        wait for clk_period*30;
        
        En <= '0';

        -- Stop simulation
        wait;
    end process;

end Behavioral;
