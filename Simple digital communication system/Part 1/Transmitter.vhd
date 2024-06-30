library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Transmitter is
    Port (
        clk            : in  STD_LOGIC;
        reset          : in  STD_LOGIC;
        En             : in  STD_LOGIC;
        ready          : out STD_LOGIC;
        header_in      : in  STD_LOGIC_VECTOR (7 downto 0);
        data_in        : in  STD_LOGIC_VECTOR (7 downto 0);
        footer_in      : in  STD_LOGIC_VECTOR (7 downto 0);
        Tx             : out STD_LOGIC;
        noise_bit      : in  integer range 0 to 11
    );
end Transmitter;

architecture Behavioral of Transmitter is
    -- State type definition
    type state_type is (IDLE, Noise, TRANSMIT, DONE);
    signal state        : state_type := IDLE;  -- Current state
    signal bit_count    : integer range 0 to 27 := 0;  -- Bit counter
    signal shift_reg    : STD_LOGIC_VECTOR (27 downto 0) := (others => '0');  -- Shift register to hold the data
    signal encoded_data : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');  -- 12-bit encoded data

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

    -- Main process
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset all signals
            state <= IDLE;
            bit_count <= 0;
            shift_reg <= (others => '0');
            encoded_data <= (others => '0');
            ready <= '0';
            Tx <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    ready <= '0';
                    Tx <= '0';
                    -- Calculate parity bits and encode data
                    encoded_data(11) <= calculate_parity(data_in)(0);
                    encoded_data(10) <= calculate_parity(data_in)(1);
                    encoded_data(9)  <= data_in(7);
                    encoded_data(8)  <= calculate_parity(data_in)(2);
                    encoded_data(7)  <= data_in(6);
                    encoded_data(6)  <= data_in(5);
                    encoded_data(5)  <= data_in(4);
                    encoded_data(4)  <= calculate_parity(data_in)(3);
                    encoded_data(3)  <= data_in(3);
                    encoded_data(2)  <= data_in(2);
                    encoded_data(1)  <= data_in(1);
                    encoded_data(0)  <= data_in(0);
                    encoded_data(noise_bit) <= not encoded_data(noise_bit);
                    if En = '1' then
                        -- Concatenate header, encoded data, and footer
                        shift_reg <= header_in & encoded_data & footer_in;
                        bit_count <= 0;
                        ready <= '0';
                        state <= Noise;
                    end if;

                when Noise =>
                    -- Add noise bit
                    shift_reg(8 + noise_bit) <= not shift_reg(8 + noise_bit);
                    state <= TRANSMIT;

                when TRANSMIT =>
                    -- Transmit the data bit by bit
                    ready <= '1';
                    Tx <= shift_reg(27);
                    shift_reg <= shift_reg(26 downto 0) & '0';
                    bit_count <= bit_count + 1;
                    if bit_count = 27 then
                        state <= DONE;
                    end if;

                when DONE =>
                    -- Transmission complete
                    Tx <= '0';
                    ready <= '0';
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end Behavioral;