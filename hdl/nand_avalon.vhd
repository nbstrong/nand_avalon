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
        address    : in    std_logic_vector( 1 downto 0);
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
            clk, enable, nand_rnb, nreset, activate : in std_logic;
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

    signal nreset       : std_logic;
    signal n_data_out   : std_logic_vector(7 downto 0);
    signal n_data_in    : std_logic_vector(7 downto 0);
    signal n_busy       : std_logic;
    signal n_activate   : std_logic;
    signal n_cmd_in     : std_logic_vector(7 downto 0);
    signal prev_pwrite  : std_logic;
    signal prev_address : std_logic_vector(1 downto 0);
    signal rnb          : std_logic;
    signal delay_slv    : std_logic_vector(15 downto 0);
    signal state_slv    : std_logic_vector(5 downto 0);
    signal substate_slv : std_logic_vector(3 downto 0);
    signal cle_busy     : std_logic;
    signal ale_busy     : std_logic;
    signal io_rd_busy   : std_logic;
    signal io_wr_busy   : std_logic;
    signal nand_rnb_r   : std_logic;
    signal nand_rnb_rr  : std_logic;
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
        delay_slv    => delay_slv,
        state_slv    => state_slv,
        substate_slv => substate_slv,
        cle_busy     => cle_busy,
        ale_busy     => ale_busy,
        io_rd_busy   => io_rd_busy,
        io_wr_busy   => io_wr_busy
    );

    -- Registers:
    -- 0x00:        Data IO
    -- 0x04:        Command input
    -- 0x08:        Status output
    readdata <= X"000000"&n_data_out          when address = "00" else
      delay_slv&state_slv&substate_slv&cle_busy&ale_busy&io_rd_busy&io_wr_busy&rnb&n_busy when address = "10" else
                            X"00000000";

    n_activate <= '1' when (prev_address = "01" and prev_pwrite = '0' and pwrite = '1' and n_busy = '0') else
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
            n_data_in <= "00000000";
            n_cmd_in  <= "00000000";
        else
            if(rising_edge(clk))then
                if(pwrite = '0' and address = "00")then
                    n_data_in <= writedata(7 downto 0);
                elsif(pwrite = '0' and address = "01")Then
                    n_cmd_in  <= writedata(7 downto 0);
                end if;
            end if;
        end if;
    end process;

    TRACK_ADDRESS:process(clk, resetn)
    begin
      if(resetn /= '1') then
          prev_address <= "00";
          prev_pwrite  <=  '0';
      else
          if(rising_edge(clk))then
              prev_address <= address;
              prev_pwrite  <= pwrite;
          end if;
      end if;
    end process;
end action;
