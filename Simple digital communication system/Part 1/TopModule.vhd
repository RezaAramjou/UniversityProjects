library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopModule is
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
end TopModule;

architecture Behavioral of TopModule is

    signal Tx                        : STD_LOGIC;
    signal Rx                        : STD_LOGIC;
    signal ready_tx                  : STD_LOGIC;

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
            debug_shift_reg            : out STD_LOGIC_VECTOR (27 downto 0);
            corrected_data_out         : out STD_LOGIC_VECTOR (7 downto 0);
            corrected_encoded_data_out : out STD_LOGIC_VECTOR (11 downto 0);
            corrupted_bit_out          : out STD_LOGIC_VECTOR (3 downto 0);
            new_parity_out             : out STD_LOGIC_VECTOR (3 downto 0);
            old_parity_out             : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

begin

    -- Instantiate the Transmitter
    U1: Transmitter
        Port map (
            clk        => clk,
            reset      => reset,
            En         => En,
            ready      => ready_tx,
            header_in  => header_in,
            data_in    => data_in,
            footer_in  => footer_in,
            Tx         => Tx,
            noise_bit  => noise_bit
        );

    -- Connect the transmitted signal to the receiver input
    process(clk, reset)
    begin
        if reset = '1' then
            Rx <= '1';
        elsif rising_edge(clk) then
            if ready_tx = '1' then
                Rx <= Tx;
            end if;
        end if;
    end process;

    -- Instantiate the Receiver
    U2: Receiver
        Port map (
            clk                        => clk,
            reset                      => reset,
            En                         => En,
            Rx                         => Rx,
            header_out                 => header_out,
            encoded_data_out           => encoded_data_out,
            footer_out                 => footer_out,
            ready                      => ready,
            debug_shift_reg            => open,  -- Not connected as per your design
            corrected_data_out         => corrected_data_out,
            corrected_encoded_data_out => corrected_encoded_data_out,
            corrupted_bit_out          => corrupted_bit_out,
            new_parity_out             => new_parity_out,
            old_parity_out             => old_parity_out
        );

end Behavioral;