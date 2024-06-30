LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_MainCode IS
END tb_MainCode;

ARCHITECTURE behavior OF tb_MainCode IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT MainCode
    PORT(
         InputA       : IN  std_logic_vector(31 downto 0);
         InputB       : IN  std_logic_vector(31 downto 0);
         Clock        : IN  std_logic;
         Reset        : IN  std_logic;
         Start        : IN  std_logic;
         Complete     : OUT std_logic;
         OutputResult : OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;
   
    -- Inputs
    signal InputA : std_logic_vector(31 downto 0) := (others => '0');
    signal InputB : std_logic_vector(31 downto 0) := (others => '0');
    signal Clock : std_logic := '0';
    signal Reset : std_logic := '0';
    signal Start : std_logic := '0';

    -- Outputs
    signal Complete : std_logic;
    signal OutputResult : std_logic_vector(31 downto 0);

    -- Clock period definitions
    constant ClockPeriod : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: COMPONENT MainCode
        PORT MAP (
            InputA => InputA,
            InputB => InputB,
            Clock => Clock,
            Reset => Reset,
            Start => Start,
            Complete => Complete,
            OutputResult => OutputResult
        );

    -- Clock process definitions
    ClockProcess : process
    begin
        Clock <= '0';
        wait for ClockPeriod/2;
        Clock <= '1';
        wait for ClockPeriod/2;
    end process;

    -- Stimulus process
    StimulusProcess: process
    begin        
        -- Hold reset state for 100 ns
        Reset <= '1';
        wait for 100 ns; 
        Reset <= '0';

        -- Initialize Inputs
        InputA <= x"40400000";  -- 3.0
        InputB <= x"40800000";  -- 4.0
        Start <= '1';
        wait for ClockPeriod*10;

        -- Add more stimulus here
        Start <= '0';
        wait for 100 ns;
        
        -- Change Inputs
        InputA <= x"3F800000";  -- 1.0
        InputB <= x"C0400000";  -- -3.0
        Start <= '1';
        wait for ClockPeriod*10;

        -- Wait for results
        wait;
    end process;

END behavior;
