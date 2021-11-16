onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/rst
add wave -noupdate /tb/rd
add wave -noupdate /tb/wr
add wave -noupdate /tb/addr
add wave -noupdate /tb/be
add wave -noupdate -radix unsigned /tb/a
add wave -noupdate -radix unsigned -childformat {{{/tb/b[31]} -radix unsigned} {{/tb/b[30]} -radix unsigned} {{/tb/b[29]} -radix unsigned} {{/tb/b[28]} -radix unsigned} {{/tb/b[27]} -radix unsigned} {{/tb/b[26]} -radix unsigned} {{/tb/b[25]} -radix unsigned} {{/tb/b[24]} -radix unsigned} {{/tb/b[23]} -radix unsigned} {{/tb/b[22]} -radix unsigned} {{/tb/b[21]} -radix unsigned} {{/tb/b[20]} -radix unsigned} {{/tb/b[19]} -radix unsigned} {{/tb/b[18]} -radix unsigned} {{/tb/b[17]} -radix unsigned} {{/tb/b[16]} -radix unsigned} {{/tb/b[15]} -radix unsigned} {{/tb/b[14]} -radix unsigned} {{/tb/b[13]} -radix unsigned} {{/tb/b[12]} -radix unsigned} {{/tb/b[11]} -radix unsigned} {{/tb/b[10]} -radix unsigned} {{/tb/b[9]} -radix unsigned} {{/tb/b[8]} -radix unsigned} {{/tb/b[7]} -radix unsigned} {{/tb/b[6]} -radix unsigned} {{/tb/b[5]} -radix unsigned} {{/tb/b[4]} -radix unsigned} {{/tb/b[3]} -radix unsigned} {{/tb/b[2]} -radix unsigned} {{/tb/b[1]} -radix unsigned} {{/tb/b[0]} -radix unsigned}} -subitemconfig {{/tb/b[31]} {-radix unsigned} {/tb/b[30]} {-radix unsigned} {/tb/b[29]} {-radix unsigned} {/tb/b[28]} {-radix unsigned} {/tb/b[27]} {-radix unsigned} {/tb/b[26]} {-radix unsigned} {/tb/b[25]} {-radix unsigned} {/tb/b[24]} {-radix unsigned} {/tb/b[23]} {-radix unsigned} {/tb/b[22]} {-radix unsigned} {/tb/b[21]} {-radix unsigned} {/tb/b[20]} {-radix unsigned} {/tb/b[19]} {-radix unsigned} {/tb/b[18]} {-radix unsigned} {/tb/b[17]} {-radix unsigned} {/tb/b[16]} {-radix unsigned} {/tb/b[15]} {-radix unsigned} {/tb/b[14]} {-radix unsigned} {/tb/b[13]} {-radix unsigned} {/tb/b[12]} {-radix unsigned} {/tb/b[11]} {-radix unsigned} {/tb/b[10]} {-radix unsigned} {/tb/b[9]} {-radix unsigned} {/tb/b[8]} {-radix unsigned} {/tb/b[7]} {-radix unsigned} {/tb/b[6]} {-radix unsigned} {/tb/b[5]} {-radix unsigned} {/tb/b[4]} {-radix unsigned} {/tb/b[3]} {-radix unsigned} {/tb/b[2]} {-radix unsigned} {/tb/b[1]} {-radix unsigned} {/tb/b[0]} {-radix unsigned}} /tb/b
add wave -noupdate -radix unsigned /tb/c
add wave -noupdate /tb/GCD/clock
add wave -noupdate /tb/GCD/resetn
add wave -noupdate /tb/GCD/read
add wave -noupdate /tb/GCD/write
add wave -noupdate /tb/GCD/chipselect
add wave -noupdate /tb/GCD/address
add wave -noupdate /tb/GCD/byteenable
add wave -noupdate -radix unsigned /tb/GCD/writedata
add wave -noupdate -radix unsigned /tb/GCD/readdata
add wave -noupdate -radix unsigned -childformat {{{/tb/GCD/wrData[0]} -radix unsigned} {{/tb/GCD/wrData[1]} -radix unsigned} {{/tb/GCD/wrData[2]} -radix unsigned} {{/tb/GCD/wrData[3]} -radix unsigned}} -subitemconfig {{/tb/GCD/wrData[0]} {-radix unsigned} {/tb/GCD/wrData[1]} {-radix unsigned} {/tb/GCD/wrData[2]} {-radix unsigned} {/tb/GCD/wrData[3]} {-radix unsigned}} /tb/GCD/wrData
add wave -noupdate -radix unsigned -childformat {{{/tb/GCD/rdData[0]} -radix unsigned} {{/tb/GCD/rdData[1]} -radix unsigned} {{/tb/GCD/rdData[2]} -radix unsigned} {{/tb/GCD/rdData[3]} -radix unsigned}} -expand -subitemconfig {{/tb/GCD/rdData[0]} {-height 15 -radix unsigned} {/tb/GCD/rdData[1]} {-height 15 -radix unsigned} {/tb/GCD/rdData[2]} {-height 15 -radix unsigned} {/tb/GCD/rdData[3]} {-height 15 -radix unsigned}} /tb/GCD/rdData
add wave -noupdate -radix unsigned /tb/GCD/result
add wave -noupdate -radix hexadecimal /tb/GCD/status
add wave -noupdate -radix hexadecimal /tb/GCD/be
add wave -noupdate /tb/GCD/byteenable_internal
add wave -noupdate /tb/GCD/wrInt
add wave -noupdate /tb/GCD/done
add wave -noupdate /tb/GCD/doneSB
add wave -noupdate /tb/GCD/GCD/clk
add wave -noupdate /tb/GCD/GCD/reset
add wave -noupdate /tb/GCD/GCD/clk_en
add wave -noupdate /tb/GCD/GCD/start
add wave -noupdate -radix unsigned /tb/GCD/GCD/dataa
add wave -noupdate -radix unsigned /tb/GCD/GCD/datab
add wave -noupdate /tb/GCD/GCD/done
add wave -noupdate -radix unsigned /tb/GCD/GCD/result
add wave -noupdate -radix unsigned /tb/GCD/GCD/a
add wave -noupdate -radix unsigned /tb/GCD/GCD/b
add wave -noupdate /tb/GCD/GCD/done_internal
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {91 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {374 ps}
