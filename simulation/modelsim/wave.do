onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider MLC_NAND_MODEL
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/uut_0/ResetComplete
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/uut_0/InitReset_Complete
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/uut_0/PowerUp_Complete
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/Wp_n
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/Ce_n
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/Cle
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/Ale
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/Clk_We_n
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/Wr_Re_n
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/Rb_n
add wave -noupdate -expand -group uut_0 /tb/MLC_nand/Dq_Io
add wave -noupdate -divider nand_avalon
add wave -noupdate -label interface_busy {/tb/rdData[0]}
add wave -noupdate -label nand_ready {/tb/rdData[1]}
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/clk
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/resetn
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal -childformat {{/tb/dut/sim_gen/nand_sim0/readdata(31) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(30) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(29) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(28) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(27) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(26) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(25) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(24) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(23) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(22) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(21) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(20) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(19) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(18) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(17) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(16) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(15) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(14) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(13) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(12) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(11) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(10) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(9) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(8) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(7) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(6) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(5) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(4) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(3) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(2) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(1) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/readdata(0) -radix hexadecimal}} -subitemconfig {/tb/dut/sim_gen/nand_sim0/readdata(31) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(30) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(29) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(28) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(27) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(26) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(25) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(24) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(23) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(22) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(21) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(20) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(19) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(18) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(17) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(16) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(15) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(14) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(13) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(12) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(11) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(10) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(9) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(8) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(7) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(6) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(5) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(4) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(3) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(2) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(1) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/readdata(0) {-height 15 -radix hexadecimal}} /tb/dut/sim_gen/nand_sim0/readdata
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/writedata
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/pread
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/pwrite
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/address
add wave -noupdate -expand -group ports_nand_avalon -label command_latch_enable -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_cle
add wave -noupdate -expand -group ports_nand_avalon -label address_latch_enable -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_ale
add wave -noupdate -expand -group ports_nand_avalon -label write_enable -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_nwe
add wave -noupdate -expand -group ports_nand_avalon -label write_protect -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_nwp
add wave -noupdate -expand -group ports_nand_avalon -label chip_enable -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_nce
add wave -noupdate -expand -group ports_nand_avalon -label read_enable -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_nre
add wave -noupdate -expand -group ports_nand_avalon -label ready_busy -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_rnb
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal -childformat {{/tb/dut/sim_gen/nand_sim0/nand_data(15) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(14) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(13) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(12) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(11) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(10) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(9) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(8) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(7) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(6) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(5) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(4) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(3) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(2) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(1) -radix hexadecimal} {/tb/dut/sim_gen/nand_sim0/nand_data(0) -radix hexadecimal}} -subitemconfig {/tb/dut/sim_gen/nand_sim0/nand_data(15) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(14) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(13) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(12) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(11) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(10) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(9) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(8) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(7) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(6) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(5) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(4) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(3) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(2) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(1) {-height 15 -radix hexadecimal} /tb/dut/sim_gen/nand_sim0/nand_data(0) {-height 15 -radix hexadecimal}} /tb/dut/sim_gen/nand_sim0/nand_data
add wave -noupdate -divider nand_master
add wave -noupdate -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/clk
add wave -noupdate -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/enable
add wave -noupdate -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/nreset
add wave -noupdate -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/data_out
add wave -noupdate -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/data_in
add wave -noupdate -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/busy
add wave -noupdate -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/activate
add wave -noupdate -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/cmd_in
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/status
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/state
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/n_state
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/substate
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/delay
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/chip_id
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/page_param
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/io_rd_data_out
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/current_address
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/page_idx
add wave -noupdate -expand -group signals_nand_master /tb/dut/sim_gen/nand_sim0/NANDA/page_data
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/clk
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/io_type
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/activate
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/busy
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/state
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/n_state
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/delay
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/io_ctrl
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/data_in
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/data_reg
add wave -noupdate -group IO_READ /tb/dut/sim_gen/nand_sim0/NANDA/IO_RD/data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {1187280000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 183
configure wave -valuecolwidth 158
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1186929064 ps} {1187597481 ps}
