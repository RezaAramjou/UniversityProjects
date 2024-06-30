library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TopModule_tb is
end TopModule_tb;

architecture Behavioral of TopModule_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component TopModule
        Port (
            clk                        : in  STD_LOGIC;
            reset                      : in  STD_LOGIC;
            En                         : in  STD_LOGIC;
            header_in                  : in  STD_LOGIC_VECTOR (7 downto 0);
            data_in                    : in  STD_LOGIC_VECTOR (7 downto 0);
            footer_in                  : in  STD_LOGIC_VECTOR (7 downto 0);
            noise_bit                  : in  integer range 0 to 11;
            ready                      : out STD_LOGIC;
            header_out                 : out STD_LOGIC_VECTOR (7 downto 0);
            encoded_data_out           : out STD_LOGIC_VECTOR (11 downto 0);
            footer_out                 : out STD_LOGIC_VECTOR (7 downto 0);
            corrected_data_out         : out STD_LOGIC_VECTOR (7 downto 0);
            corrected_encoded_data_out : out STD_LOGIC_VECTOR (11 downto 0);
            corrupted_bit_out          : out STD_LOGIC_VECTOR (3 downto 0);
            new_parity_out             : out STD_LOGIC_VECTOR (3 downto 0);
            old_parity_out             : out STD_LOGIC_VECTOR (3 downto 0)
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
    signal ready                      : STD_LOGIC;
    signal header_out                 : STD_LOGIC_VECTOR (7 downto 0);
    signal encoded_data_out           : STD_LOGIC_VECTOR (11 downto 0);
    signal footer_out                 : STD_LOGIC_VECTOR (7 downto 0);
    signal corrected_data_out         : STD_LOGIC_VECTOR (7 downto 0);
    signal corrected_encoded_data_out : STD_LOGIC_VECTOR (11 downto 0);
    signal corrupted_bit_out          : STD_LOGIC_VECTOR (3 downto 0);
    signal new_parity_out             : STD_LOGIC_VECTOR (3 downto 0);
    signal old_parity_out             : STD_LOGIC_VECTOR (3 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: TopModule Port map (
            clk                        => clk,
            reset                      => reset,
            En                         => En,
            header_in                  => header_in,
            data_in                    => data_in,
            footer_in                  => footer_in,
            noise_bit                  => noise_bit,
            ready                      => ready,
            header_out                 => header_out,
            encoded_data_out           => encoded_data_out,
            footer_out                 => footer_out,
            corrected_data_out         => corrected_data_out,
            corrected_encoded_data_out => corrected_encoded_data_out,
            corrupted_bit_out          => corrupted_bit_out,
            new_parity_out             => new_parity_out,
            old_parity_out             => old_parity_out
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
        wait for clk_period*40;
        
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
        wait for clk_period*40;
        
        En <= '0';

        -- Stop simulation
        wait;
    end process;

end Behavioral;