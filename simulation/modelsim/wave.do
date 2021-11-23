quietly WaveActivateNextPane {} 0
add wave -noupdate -divider nand_avalon
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/clk
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/resetn
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/readdata
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/writedata
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/pread
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/pwrite
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/address
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_cle
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_ale
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_nwe
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_nwp
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_nce
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_nre
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_rnb
add wave -noupdate -expand -group ports_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/nand_data
add wave -noupdate -expand -group signals_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/prev_address
add wave -noupdate -expand -group signals_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/prev_pwrite
add wave -noupdate -expand -group signals_nand_avalon -radix hexadecimal /tb/dut/sim_gen/nand_sim0/n_busy
add wave -noupdate -divider nand_master
add wave -noupdate -expand -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/clk
add wave -noupdate -expand -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/enable
add wave -noupdate -expand -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/nreset
add wave -noupdate -expand -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/data_out
add wave -noupdate -expand -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/data_in
add wave -noupdate -expand -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/busy
add wave -noupdate -expand -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/activate
add wave -noupdate -expand -group ports_nand_master -radix hexadecimal /tb/dut/sim_gen/nand_sim0/NANDA/cmd_in
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ns} {273 ns}
