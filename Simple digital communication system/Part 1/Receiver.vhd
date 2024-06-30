library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- Use only IEEE.NUMERIC_STD for type conversions

entity Receiver is
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
end Receiver;

architecture Behavioral of Receiver is
    -- State type definition
    type state_type is (IDLE, RECEIVE, DONE, CHECK, CHECK2, CORRECTION);
    signal state                       : state_type := IDLE;  -- Current state
    signal bit_count                   : integer range 0 to 30 := 0;  -- Bit counter
    signal shift_reg                   : STD_LOGIC_VECTOR (27 downto 0) := (others => '0');  -- Shift register to hold received data
    signal corrupted_bit               : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');  -- Corrupted bit location
    signal new_parity                  : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');  -- New parity bits
    signal old_parity                  : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');  -- Old parity bits
    signal encoded_data_internal       : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');  -- Internal encoded data
    signal corrected_data_internal     : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');  -- Internal corrected data
    signal corrected_encoded_data_internal : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');  -- Internal corrected encoded data

    -- Function to calculate parity bits
    function calculate_parity(d: STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable p: STD_LOGIC_VECTOR(3 downto 0);
    begin
        p(0) := d(7) xor d(6) xor d(4) xor d(3) xor d(1);
        p(1) := d(7) xor d(5) xor d(4) xor d(2) xor d(1);
        p(2) := d(6) xor d(5) xor d(4) xor d(0);
        p(3) := d(3) xor d(2) xor d(1) xor d(0);
        return p;
    end function;

begin
    -- Assign debug signals
    debug_shift_reg <= shift_reg;
    encoded_data_out <= encoded_data_internal;
    corrected_data_out <= corrected_data_internal;
    corrected_encoded_data_out <= corrected_encoded_data_internal;
    corrupted_bit_out <= corrupted_bit;
    new_parity_out <= new_parity;
    old_parity_out <= old_parity;

    -- Main process
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset all signals
            state <= IDLE;
            bit_count <= 0;
            shift_reg <= (others => '0');
            header_out <= (others => '0');
            encoded_data_internal <= (others => '0');
            corrected_data_internal <= (others => '0');
            corrected_encoded_data_internal <= (others => '0');
            footer_out <= (others => '0');
            ready <= '0';
            corrupted_bit <= "0000";
            new_parity <= (others => '0');
            old_parity <= (others => '0');
        elsif rising_edge(clk) then
            if En = '1' then
                case state is
                    when IDLE =>
                        ready <= '0';
                        if Rx = '1' or Rx = '0' then  -- Start receiving on any change on Rx
                            state <= RECEIVE;
                            bit_count <= 0;
                            ready <= '0';
                        end if;

                    when RECEIVE =>
                        -- Shift in received bits
                        shift_reg <= shift_reg(26 downto 0) & Rx;
                        bit_count <= bit_count + 1;
                        if bit_count = 30 then
                            state <= DONE;
                        end if;

                    when DONE =>
                        -- Transmission complete
                        ready <= '0';
                        header_out <= shift_reg(27 downto 20);
                        encoded_data_internal <= shift_reg(19 downto 8);
                        corrected_encoded_data_internal <= shift_reg(19 downto 8);
                        corrected_data_internal <= shift_reg(17) & shift_reg(15 downto 13) & shift_reg(11 downto 8);
                        footer_out <= shift_reg(7 downto 0);
                        old_parity <= shift_reg(12) & shift_reg(16) & shift_reg(18) & shift_reg(19);
                        state <= CHECK;

                    when CHECK =>
                        ready <= '0';
                        new_parity <= calculate_parity(corrected_data_internal);
                        corrupted_bit <= "0000";
                        state <= CHECK2;
						
						  when CHECK2 =>
								ready <= '0';
								corrupted_bit <= new_parity xor old_parity;
                        state <= CORRECTION;

                    when CORRECTION =>
                        ready <= '1';
                        corrupted_bit <= new_parity xor old_parity;
                        if corrupted_bit /= "0000" then
                            corrected_encoded_data_internal(12 - to_integer(unsigned(corrupted_bit))) <= not corrected_encoded_data_internal(12 - to_integer(unsigned(corrupted_bit)));
                            corrected_data_internal <= corrected_encoded_data_internal(9) & corrected_encoded_data_internal(7 downto 5) & corrected_encoded_data_internal(3 downto 0);
                        end if;
                        state <= IDLE;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end Behavioral;