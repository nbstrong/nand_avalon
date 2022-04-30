library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--------------------------------------------------------------------------------
-- Extension Module
--------------------------------------------------------------------------------
entity extension_module is
  port (
    clkIn       : in    std_logic;
    resetnIn    : in    std_logic;
    -- Nand Signals
    nand_rnbIn  : in    std_logic;
    -- Registers
    delayIn     : in    std_logic_vector(31 downto 0);
    startIn     : in    std_logic;
    timeOut     :   out std_logic_vector(31 downto 0);
    statOut     :   out std_logic_vector(31 downto 0);
    -- Discretes
    resetCmdOut :   out std_logic
  );
end extension_module;
--------------------------------------------------------------------------------
architecture behav of extension_module is
  -- CONSTANTS -----------------------------------------------------------------
  -- TYPES ---------------------------------------------------------------------
  type state_type is (INIT, DELAY, CMD);
  -- SIGNALS -------------------------------------------------------------------
  signal state          : state_type;
  signal rnbFallingEdge : std_logic;
  signal rnbRisingEdge  : std_logic;
  signal doNotUse       : std_logic;
  signal delayLatched   : unsigned(delayIn'range);
  signal delayUnsign    : unsigned(delayIn'range);
  signal timeUnsign     : unsigned(timeOut'range);
  -- ALIASES -------------------------------------------------------------------
  -- ATTRIBUTES ----------------------------------------------------------------
  -- PROCEDURES ----------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- Flip flop Procedure
  ------------------------------------------------------------------------------
  procedure FF (
    signal clkIn  : in    std_logic;
    signal rstnIn : in    std_logic;
    signal dIn    : in    std_logic;
    signal qOut   :   out std_logic) is
  begin
      if(rstnIn /= '1') then
        qOut <= '0';
      else
        if(rising_edge(clkIn)) then
          qOut <= dIn;
        end if;
      end if;
  end procedure FF;
  ------------------------------------------------------------------------------
  -- Edge Detect Procedure
  ------------------------------------------------------------------------------
  procedure EDGE (
    signal clkIn      : in    std_logic;
    signal rstnIn     : in    std_logic;
    signal sigIn      : in    std_logic;
    signal sigR       : inout std_logic; -- do not use, required because of var/signal incompatibility
    signal risingOut  :   out std_logic;
    signal fallingOut :   out std_logic) is
  begin
    FF(clkIn, rstnIn, sigIn, sigR);
    fallingOut <= not sigIn and sigR;
    risingOut  <= sigIn and not sigR;
  end procedure EDGE;

begin --------------------------------------------------------------------------

  statOut( 1 downto  0) <= std_logic_vector(to_unsigned(state_type'POS(state), 2)); -- Provides state enumeration as status
  statOut(31 downto  2) <= (others => '0');
  delayUnsign           <= unsigned(delayIn);
  timeOut               <= std_logic_vector(timeUnsign);

  ----------------------------------------------------------------------------
  -- Timer Register Counter
  ----------------------------------------------------------------------------
  EDGE(clkIn, resetnIn, nand_rnbIn, doNotUse, rnbRisingEdge, rnbFallingEdge);

  Counter_Proc : process(clkIn, resetnIn)
  begin
    if(resetnIn /= '1') then
      timeUnsign <= (others => '0');
    else
      if(rising_edge(clkIn)) then
        if(rnbFallingEdge = '1') then
          timeUnsign <= (others => '0');
        elsif (nand_rnbIn = '0') then
          timeUnsign <= timeUnsign + 1;
        end if;
      end if;
    end if;
  end process Counter_Proc;

  ----------------------------------------------------------------------------
  -- State Machine
  ----------------------------------------------------------------------------
  FSM_Proc : process(clkIn, resetnIn)
  begin
    if(resetnIn /= '1') then
      state        <= INIT;
      resetCmdOut  <= '0';
      delayLatched <= (others => '0');
    else
      if(rising_edge(clkIn)) then
        case state is
          when INIT =>
            if(startIn = '1') then
              state        <= DELAY;
              delayLatched <= delayUnsign;
            end if;

          when DELAY =>
            if(rnbRisingEdge = '1' or startIn = '0') then
              state <= INIT;
            elsif(delayLatched = timeUnsign) then
              state <= CMD;
              resetCmdOut <= '1';
            end if;

          when CMD =>
              state <= INIT;
              resetCmdOut <= '0';

          when others =>
            state <= INIT;

        end case;
      end if;
    end if;
  end process FSM_Proc;
end architecture behav;