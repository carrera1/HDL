library ieee;
use ieee.std_logic_1164.all;

entity lowlevel_dac_intf_tb is
  end lowlevel_dac_intf_tb;

architecture tb of lowlevel_dac_intf_tb is

  component lowlevel_dac_intf
    port (
           s_axis_aclk    : in std_logic;  -- the clock (125 MHz) for all flops in your design 
           s_axis_aresetn : in std_logic;  -- active low asynchronous reset 
           s_axis_tvalid  : in std_logic;  -- ignore this input for now 
           s_axis_tdata   : in std_logic_vector(31 downto 0); -- 32 bit input data 
           s_axis_tready  : out std_logic; -- 1 clk125 wide pulse which indicates when the current        
                                           -- value of data_word has been read by this component                                             
                                           -- (and can be safely changed) 
           sdata : out std_logic; -- serial data out to the DAC 
           lrck  : out std_logic; -- a 50% duty cycle signal aligned as shown below 
           bclk  : out std_logic; -- the dac clocks sdata on the rising edge of this clock 
           mclk  : out std_logic  -- a 12.5MHz clock output with arbitrary phase 
         );
  end component;

  signal reset_in     : std_logic;
  signal clk_in       : std_logic;
  signal ignore_in    : std_logic;
  signal test_data_in : std_logic_vector(31 downto 0);
  signal ready_out    : std_logic;
  signal sdata_out    : std_logic;
  signal lrck_out     : std_logic;
  signal bclk_out     : std_logic;
  signal mclk_out     : std_logic;

  constant TbPeriod : time := 8 ns;
  signal TbClock    : std_logic := '0';

begin
  dut : lowlevel_dac_intf(
  -- inputs
  s_axis_aclk    => clk_in,
  s_axis_aresetn => reset_in,
  s_axis_tvalid  => ignore_in,
  s_axis_tdata   => test_data_in,
  -- outputs
  s_axis_tready  => ready_out,
  sdata => sdata_out,
  lrck  => lrck_out,
  bclk  => bclk_out,
  mclk  => mclk_out 
);

TbClock <= not TbClock after TbPeriod/2;

stimuli : process
begin
  reset <= '0';
  test_data_in <= "00000000000000000000000000000000";
  wait for 200 ns;
  test_data_in <= "10101010101010101010101010101010";
  wait for 10  ns;
  reset <= '1';
  wait;
end process;

end tb;
