onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/resetn
add wave -noupdate /tb/address
add wave -noupdate /tb/readdata
add wave -noupdate /tb/pread
add wave -noupdate /tb/writedata
add wave -noupdate /tb/pwrite
add wave -noupdate /tb/nand_data
add wave -noupdate {/tb/nand_data[7]}
add wave -noupdate {/tb/nand_data[6]}
add wave -noupdate {/tb/nand_data[5]}
add wave -noupdate {/tb/nand_data[4]}
add wave -noupdate {/tb/nand_data[3]}
add wave -noupdate {/tb/nand_data[2]}
add wave -noupdate {/tb/nand_data[1]}
add wave -noupdate {/tb/nand_data[0]}
add wave -noupdate /tb/nand_nwp
add wave -noupdate /tb/nand_nwe
add wave -noupdate /tb/nand_ale
add wave -noupdate /tb/nand_cle
add wave -noupdate /tb/nand_nce
add wave -noupdate /tb/nand_nre
add wave -noupdate /tb/nand_rnb
add wave -noupdate /tb/rdData
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {344 ps} 0}
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
WaveRestoreZoom {0 ps} {1 ns}
