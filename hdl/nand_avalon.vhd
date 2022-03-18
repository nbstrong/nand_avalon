-- altera vhdl_input_version vhdl_2008
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Title   : ONFI compliant NAND interface
-- File    : nand_avalon.vhd
-- Author  : Alexey Lyashko <pradd@opencores.org>
-- Author  : Nicholas Strong <nicholasbstrong@gmail.com>
-- License : LGPL
-------------------------------------------------------------------------------------------------
-- Description:
-- The nand_avalon is an Avalon protocol compliant wrapper around the nand_master controller.
-- Active low rd/wr, HOLD = 1
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nand_avalon is
    port
    (
        clk        : in    std_logic                      := '0';
        resetn     : in    std_logic                      := '0';
        readdata   : out   std_logic_vector(31 downto 0);
        writedata  : in    std_logic_vector(31 downto 0)  := x"00000000";
        pread      : in    std_logic                      := '1';
        pwrite     : in    std_logic                      := '1';
        address    : in    std_logic_vector( 2 downto 0);
        -- NAND chip control hardware interface. These signals should be bound to physical pins.
        nand_cle   : out   std_logic                      := '0';
        nand_ale   : out   std_logic                      := '0';
        nand_nwe   : out   std_logic                      := '1';
        nand_nwp   : out   std_logic                      := '0';
        nand_nce   : out   std_logic                      := '1';
        nand_nre   : out   std_logic                      := '1';
        nand_rnb   : in    std_logic;
        -- NAND chip data hardware interface. These signals should be boiund to physical pins.
        nand_data  : inout std_logic_vector(15 downto 0)
    );
end nand_avalon;

architecture action of nand_avalon is
    component nand_master
        port
        (
            nand_cle, nand_ale, nand_nwe, nand_nwp, nand_nce, nand_nre, busy: out std_logic;
            clk, enable, nand_rnb, nreset, activate, force_reset_cmd : in std_logic;
            data_out : out std_logic_vector(7 downto 0);
            data_in, cmd_in : in std_logic_vector(7 downto 0);
            nand_data : inout std_logic_vector(15 downto 0);
            delay_slv    : out std_logic_vector(15 downto 0);
            state_slv    : out std_logic_vector(5 downto 0);
            substate_slv : out std_logic_vector(3 downto 0);
            cle_busy     : out std_logic;
            ale_busy     : out std_logic;
            io_rd_busy   : out std_logic;
            io_wr_busy   : out std_logic
        );
    end component;

    component extension_module
        port
        (
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
    end component;

    signal nreset                : std_logic;
    signal n_data_out            : std_logic_vector(7 downto 0);
    signal n_data_in             : std_logic_vector(7 downto 0);
    signal n_busy                : std_logic;
    signal n_activate            : std_logic;
    signal n_cmd_in              : std_logic_vector(7 downto 0);
    signal prev_pwrite           : std_logic;
    signal prev_address          : std_logic_vector(address'range);
    signal rnb                   : std_logic;
    signal delay_slv             : std_logic_vector(15 downto 0);
    signal state_slv             : std_logic_vector(5 downto 0);
    signal substate_slv          : std_logic_vector(3 downto 0);
    signal cle_busy              : std_logic;
    signal ale_busy              : std_logic;
    signal io_rd_busy            : std_logic;
    signal io_wr_busy            : std_logic;
    signal nand_rnb_r            : std_logic;
    signal nand_rnb_rr           : std_logic;
    signal extension_delay       : std_logic_vector(31 downto 0);
    signal extension_cntrl_write : std_logic_vector(31 downto 0);
    signal extension_time        : std_logic_vector(31 downto 0);
    signal extension_cntrl_read  : std_logic_vector(31 downto 0);
    signal extension_stat        : std_logic_vector(31 downto 0);
    signal force_reset_cmd       : std_logic;
begin
    NANDA: nand_master
    port map
    (
        clk       => clk,
        nreset    => resetn,
        enable    => '0',
        data_out  => n_data_out,
        data_in   => n_data_in,
        busy      => n_busy,
        cmd_in    => n_cmd_in,
        activate  => n_activate,
        nand_data => nand_data,
        nand_cle  => nand_cle,
        nand_ale  => nand_ale,
        nand_nwe  => nand_nwe,
        nand_nwp  => nand_nwp,
        nand_nce  => nand_nce,
        nand_nre  => nand_nre,
        nand_rnb  => nand_rnb_rr,
        force_reset_cmd => force_reset_cmd,
        delay_slv    => delay_slv,
        state_slv    => state_slv,
        substate_slv => substate_slv,
        cle_busy     => cle_busy,
        ale_busy     => ale_busy,
        io_rd_busy   => io_rd_busy,
        io_wr_busy   => io_wr_busy
    );

    EXTENSION: extension_module
    port map
    (
      clkIn       => clk,
      resetnIn    => resetn,
      -- Nand Signals
      nand_rnbIn  => nand_rnb_rr,
      -- Registers
      delayIn     => extension_delay,
      startIn     => extension_cntrl_write(0),
      timeOut     => extension_time,
      statOut     => extension_stat,
      -- Discretes
      resetCmdOut => force_reset_cmd
    );

    -- Registers:
    -- 0x00:        Data IO
    -- 0x04:        Command input
    -- 0x08:        Status output
    readdata <= X"000000"&n_data_out                                                                when address = "000" else
                delay_slv&state_slv&substate_slv&cle_busy&ale_busy&io_rd_busy&io_wr_busy&rnb&n_busy when address = "010" else
                extension_time                                                                      when address = "011" else
                extension_cntrl_read                                                                when address = "100" else
                extension_stat                                                                      when address = "101" else
                extension_delay                                                                     when address = "110" else
                X"00000000";

    n_activate <= '1' when (prev_address = "001" and prev_pwrite = '0' and pwrite = '1' and n_busy = '0') else
                  '0';

    rnb <= '0' when nand_rnb = '0' else '1';

    -- Metastability Flop
    FF_Proc: process(clk, resetn)
    begin
      if(resetn /= '1') then
        nand_rnb_r  <= '0';
        nand_rnb_rr <= '0';
      else
        if(rising_edge(clk)) then
          nand_rnb_r  <= nand_rnb;
          nand_rnb_rr <= nand_rnb_r;
        end if;
      end if;
    end process;

    CONTROL_INPUTS:process(clk, resetn)
    begin
        if(resetn /= '1') then
            n_data_in             <= (others => '0');
            n_cmd_in              <= (others => '0');
            extension_cntrl_write <= (others => '0');
            extension_delay       <= (others => '0');
        else
            if(rising_edge(clk))then
                extension_cntrl_write <= (others => '0');

                if   (pwrite = '0' and address = "000")then
                    n_data_in <= writedata(7 downto 0);

                elsif(pwrite = '0' and address = "001")then
                    n_cmd_in  <= writedata(7 downto 0);

                elsif(pwrite = '0' and address = "100")then
                    extension_cntrl_write <= writedata(31 downto 0);

                elsif(pwrite = '0' and address = "110")then
                    extension_delay <= writedata(31 downto 0);

                end if;
            end if;
        end if;
    end process;

    TRACK_ADDRESS:process(clk, resetn)
    begin
      if(resetn /= '1') then
          prev_address <= "000";
          prev_pwrite  <=  '0';
      else
          if(rising_edge(clk))then
              prev_address <= address;
              prev_pwrite  <= pwrite;
          end if;
      end if;
    end process;
end action;
