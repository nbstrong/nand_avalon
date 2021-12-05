onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/clk
add wave -noupdate -radix hexadecimal /tb/resetn
add wave -noupdate -radix hexadecimal /tb/address
add wave -noupdate -radix hexadecimal /tb/readdata
add wave -noupdate -radix hexadecimal /tb/pread
add wave -noupdate -radix hexadecimal /tb/writedata
add wave -noupdate -radix hexadecimal /tb/pwrite
add wave -noupdate -radix hexadecimal /tb/nand_data
add wave -noupdate -radix hexadecimal {/tb/nand_data[7]}
add wave -noupdate -radix hexadecimal {/tb/nand_data[6]}
add wave -noupdate -radix hexadecimal {/tb/nand_data[5]}
add wave -noupdate -radix hexadecimal {/tb/nand_data[4]}
add wave -noupdate -radix hexadecimal {/tb/nand_data[3]}
add wave -noupdate -radix hexadecimal {/tb/nand_data[2]}
add wave -noupdate -radix hexadecimal {/tb/nand_data[1]}
add wave -noupdate -radix hexadecimal {/tb/nand_data[0]}
add wave -noupdate -radix hexadecimal /tb/nand_nwp
add wave -noupdate -radix hexadecimal /tb/nand_nwe
add wave -noupdate -radix hexadecimal /tb/nand_ale
add wave -noupdate -radix hexadecimal /tb/nand_cle
add wave -noupdate -radix hexadecimal /tb/nand_nce
add wave -noupdate -radix hexadecimal /tb/nand_nre
add wave -noupdate -radix hexadecimal /tb/nand_rnb
add wave -noupdate -radix hexadecimal /tb/rdData
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1225702109 ps} 0}
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
WaveRestoreZoom {1220574673 ps} {1231905328 ps}
