library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Entity declaration for the floating point adder
entity MainCode is
  port(
    InputA      : in  std_logic_vector(31 downto 0);  -- Input A (32-bit floating point)
    InputB      : in  std_logic_vector(31 downto 0);  -- Input B (32-bit floating point)
    Clock       : in  std_logic;                      -- Clock signal
    Reset       : in  std_logic;                      -- Reset signal
    Start       : in  std_logic;                      -- Start signal
    Complete    : out std_logic;                      -- Complete signal (indicates operation is done)
    OutputResult: out std_logic_vector(31 downto 0)   -- Result (32-bit floating point)
  );
end MainCode;

-- Architecture definition for the floating point adder
architecture Behavioral of MainCode is
  -- State machine states definition
  type StateType is (IDLE, ALIGNMENT, ADDITION, NORMALIZATION, DONE);
  signal CurrentState         : StateType := IDLE;  -- Initial state is IDLE
  attribute INIT              : string;
  attribute INIT of CurrentState : signal is "IDLE";

  -- Internal signals
  signal MantissaA, MantissaB : std_logic_vector (24 downto 0);  -- Mantissas of A and B
  signal ExponentA, ExponentB : std_logic_vector (8 downto 0);   -- Exponents of A and B
  signal SignA, SignB         : std_logic;                       -- Signs of A and B
  signal Result               : std_logic_vector (31 downto 0);  -- Register for the result
  signal SumMantissa          : std_logic_vector (24 downto 0);  -- Sum of mantissas

begin
  -- Assign result register to output
  OutputResult <= Result;  
  
  -- State machine process
  ProcessStateMachine : process (Clock, Reset, CurrentState, Start) is
    variable ExponentDifference : signed(8 downto 0);  -- Variable for exponent difference
  begin
    -- Handle reset condition
    if(Reset = '1') then
      CurrentState <= IDLE;
      Complete     <= '0';
    elsif rising_edge(Clock) then
      -- State machine implementation
      case CurrentState is
        -- Idle state, wait for start signal
        when IDLE =>
          if (Start = '1') then
            SignA       <= InputA(31);                   -- Extract sign of InputA
            SignB       <= InputB(31);                   -- Extract sign of InputB
            ExponentA   <= '0' & InputA(30 downto 23);   -- Extract exponent of InputA and extend to 9 bits
            ExponentB   <= '0' & InputB(30 downto 23);   -- Extract exponent of InputB and extend to 9 bits
            MantissaA   <= "01" & InputA(22 downto 0);   -- Extract mantissa of InputA and extend to 25 bits
            MantissaB   <= "01" & InputB(22 downto 0);   -- Extract mantissa of InputB and extend to 25 bits
            CurrentState <= ALIGNMENT;                   -- Move to ALIGNMENT state
          else
            CurrentState <= IDLE;                        -- Remain in IDLE state
          end if;
        
        -- Alignment state, align the mantissas based on exponent difference
        when ALIGNMENT =>
          if unsigned(ExponentA) = unsigned(ExponentB) then
            CurrentState <= ADDITION;                    -- If exponents are equal, move to ADDITION state
          elsif unsigned(ExponentA) > unsigned(ExponentB) then
            ExponentDifference := signed(ExponentA) - signed(ExponentB);  -- Calculate exponent difference
            if ExponentDifference > 23 then
              SumMantissa <= MantissaA;                  -- If difference is too large, take MantissaA as is
              Result(31)  <= SignA;                      -- Set result sign
              CurrentState <= DONE;                      -- Move to DONE state
            else
              MantissaB(24-TO_INTEGER(ExponentDifference) downto 0) <= MantissaB(24 downto TO_INTEGER(ExponentDifference));  -- Shift MantissaB
              MantissaB(24 downto 25-TO_INTEGER(ExponentDifference)) <= (others => '0');  -- Zero out shifted bits
              CurrentState <= ADDITION;                  -- Move to ADDITION state
            end if;
          else
            ExponentDifference := signed(ExponentB) - signed(ExponentA);  -- Calculate exponent difference
            if ExponentDifference > 23 then
              SumMantissa <= MantissaB;                  -- If difference is too large, take MantissaB as is
              Result(31)  <= SignB;                      -- Set result sign
              ExponentA   <= ExponentB;                  -- Adjust exponent
              CurrentState <= DONE;                      -- Move to DONE state
            else
              ExponentA <= ExponentB;                    -- Adjust exponent
              MantissaA(24-TO_INTEGER(ExponentDifference) downto 0) <= MantissaA(24 downto TO_INTEGER(ExponentDifference));  -- Shift MantissaA
              MantissaA(24 downto 25-TO_INTEGER(ExponentDifference)) <= (others => '0');  -- Zero out shifted bits
              CurrentState <= ADDITION;                  -- Move to ADDITION state
            end if;
          end if;
        
        -- Addition state, add or subtract mantissas based on signs
        when ADDITION =>
          CurrentState <= NORMALIZATION;                 -- Move to NORMALIZATION state
          if (SignA xor SignB) = '0' then
            SumMantissa <= std_logic_vector((unsigned(MantissaA) + unsigned(MantissaB)));  -- Add mantissas
            Result(31)  <= SignA;                      -- Set result sign
          elsif unsigned(MantissaA) >= unsigned(MantissaB) then
            SumMantissa <= std_logic_vector((unsigned(MantissaA) - unsigned(MantissaB)));  -- Subtract mantissas
            Result(31)  <= SignA;                      -- Set result sign
          else
            SumMantissa <= std_logic_vector((unsigned(MantissaB) - unsigned(MantissaA)));  -- Subtract mantissas
            Result(31)  <= SignB;                      -- Set result sign
          end if;
        
        -- Normalization state, normalize the mantissa
        when NORMALIZATION =>
          if unsigned(SumMantissa) = to_unsigned(0, 25) then
            SumMantissa <= (others => '0');            -- If sum is zero, zero out mantissa
            ExponentA   <= (others => '0');            -- Zero out exponent
            CurrentState <= DONE;                      -- Move to DONE state
          elsif SumMantissa(24) = '1' then
            SumMantissa <= '0' & SumMantissa(24 downto 1);  -- Normalize mantissa
            ExponentA   <= std_logic_vector((unsigned(ExponentA) + 1));  -- Increment exponent
            CurrentState <= DONE;                      -- Move to DONE state
          elsif SumMantissa(23) = '0' then
            for i in 22 downto 1 loop
              if SumMantissa(i) = '1' then
                SumMantissa(24 downto 23-i) <= SumMantissa(i+1 downto 0);  -- Shift mantissa
                SumMantissa(22-i downto 0)  <= (others => '0');  -- Zero out shifted bits
                ExponentA <= std_logic_vector(unsigned(ExponentA) - 23 + i);  -- Adjust exponent
                exit;
              end if;
            end loop;
            CurrentState <= DONE;                      -- Move to DONE state
          else
            CurrentState <= DONE;                      -- Move to DONE state
          end if;
        
        -- Done state, set the result and wait for the start signal to go low
        when DONE =>
          Result(22 downto 0)  <= SumMantissa(22 downto 0);  -- Set result mantissa
          Result(30 downto 23) <= ExponentA(7 downto 0);     -- Set result exponent
          Complete             <= '1';                      -- Indicate completion
          if (Start = '0') then
            Complete  <= '0';                              -- Clear completion flag
            CurrentState <= IDLE;                          -- Return to IDLE state
          end if;
        when others =>
          CurrentState <= IDLE;                            -- Default state is IDLE
      end case;
    end if;
  end process ProcessStateMachine;

end Behavioral;
