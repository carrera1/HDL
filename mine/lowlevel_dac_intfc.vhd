-- TODO add logic for s_axis_tready
-- TODO adjust clock dividers for reasonable testbench period
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lowlevel_dac_intfc is  
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
end lowlevel_dac_intfc; 

architecture behavioral of lowlevel_dac_intfc is
  -- signal definitations
  signal reset_inv      : std_logic; -- active high reset
  signal lrck_pulse     : std_logic;
  signal lrck_internal  : std_logic;
  signal bclk_pulse     : std_logic;
  signal bclk_internal  : std_logic;
  signal mclk_pulse     : std_logic;
  signal mclk_internal  : std_logic;
  signal bit_select     : natural range 0 to 31;

  -- Component declarations here
  component clkdivider is
    generic(divideby :natural:=2);
    port(  
          clk      : in  std_logic;
          reset    : in  std_logic;          
          pulseout : out std_logic
        );
  end component;

begin

  -- logic goes here
  reset_inv <= not s_axis_aresetn; -- Modules active high reset
  lrck      <=     lrck_internal;
  bclk      <=     bclk_internal;
  mclk      <=     mclk_internal;

  -- process to handle bit_select logic for sdata
  bit_select_proc : process(s_axis_aclk, reset_inv)
  begin
    if reset_inv = '1' then
      bit_select     <= 31;
    elsif rising_edge(s_axis_aclk) then
      if bclk_internal = '1' then
        if bit_select = 0 then
          bit_select <= 31;
        else
          bit_select <= bit_select - 1;
        end if;
      end if;
    end if;
  end process;

  -- process to handle internal logic for module outputs
  sdata_proc : process(s_axis_aclk, reset_inv, s_axis_tdata)
  begin
    if reset_inv = '1' then
      sdata <= '0';
    elsif rising_edge(s_axis_aclk) then
      sdata <= s_axis_tdata(bit_select); -- TODO see if this works as a mux
    end if;
  end process;

  lrck_proc : process(s_axis_aclk, reset_inv)
  begin
    if reset_inv = '1' then
      lrck_internal <= '0';
    elsif rising_edge(s_axis_aclk) then
      if lrck_pulse = '1' then
        lrck_internal <= not lrck_internal;
      end if;
    end if;
  end process;

  bclk_proc : process(s_axis_aclk, reset_inv)
  begin
    if reset_inv = '1' then
      bclk_internal <= '0';
    elsif rising_edge(s_axis_aclk) then
      if bclk_pulse = '1' then
        bclk_internal <= not bclk_internal;
      end if;
    end if;
  end process;
  
  mclk_proc : process(s_axis_aclk, reset_inv)
  begin
    if reset_inv = '1' then
      mclk_internal <= '0';
    elsif rising_edge(s_axis_aclk) then
      if mclk_pulse = '1' then
        mclk_internal <= not mclk_internal;
      end if;
    end if;
  end process;

  lrck_gen : clkdivider
  generic map(divideby => 2560)
  port map(
            clk     => s_axis_aclk,
            reset   => reset_inv,
            pulseout => lrck_pulse
          );

  bclk_gen : clkdivider
  generic map(divideby => 80)
  port map(
            clk     => s_axis_aclk,
            reset   => reset_inv,
            pulseout => bclk_pulse
          );

  mclk_gen : clkdivider
  generic map(divideby => 10)
  port map(
            clk     => s_axis_aclk,
            reset   => reset_inv,
            pulseout => mclk_pulse
          );

end behavioral;
