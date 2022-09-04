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
  -- Determine best way to instantiate module. Component vs Entity
  -- TODO Instantiate clkdivider components for clock outputs
  -- TODO Create & connect signals

  lrck_gen : clkdivider
  generic map(divideby => 2560)
  port map(
            clk      => sig1,
            reset    => sig2,
            pulseout => sig3
          );

  bclk_gen : clkdivider
  generic map(divideby => 80)
  port map(
            clk      => sig4,
            reset    => sig5,
            pulseout => sig6
          );

  mclk_gen : clkdivider
  generic map(divideby => 10)
  port map(
            clk      => sig7,
            reset    => sig8,
            pulseout => sig9
          );


end behavioral;
