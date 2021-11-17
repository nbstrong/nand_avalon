onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TB
add wave -noupdate -radix unsigned /tb/clk
add wave -noupdate -radix unsigned /tb/rst
add wave -noupdate -radix unsigned /tb/rd
add wave -noupdate -radix unsigned /tb/wr
add wave -noupdate -radix unsigned /tb/cs
add wave -noupdate -radix unsigned /tb/addr
add wave -noupdate -radix unsigned /tb/be
add wave -noupdate -radix unsigned /tb/wrData
add wave -noupdate -radix unsigned /tb/rdData
add wave -noupdate -divider DUT
add wave -noupdate -radix unsigned -childformat {{{/tb/DUT/from_reg[0]} -radix unsigned} {{/tb/DUT/from_reg[1]} -radix unsigned} {{/tb/DUT/from_reg[2]} -radix unsigned} {{/tb/DUT/from_reg[3]} -radix unsigned}} -expand -subitemconfig {{/tb/DUT/from_reg[0]} {-height 15 -radix unsigned} {/tb/DUT/from_reg[1]} {-height 15 -radix unsigned} {/tb/DUT/from_reg[2]} {-height 15 -radix unsigned} {/tb/DUT/from_reg[3]} {-height 15 -radix unsigned}} /tb/DUT/from_reg
add wave -noupdate -divider GCD
add wave -noupdate -radix unsigned /tb/DUT/GCD/clk
add wave -noupdate -radix unsigned /tb/DUT/GCD/clk_en
add wave -noupdate -radix unsigned /tb/DUT/GCD/reset
add wave -noupdate -radix unsigned /tb/DUT/GCD/start
add wave -noupdate -radix unsigned /tb/DUT/GCD/dataa
add wave -noupdate -radix unsigned /tb/DUT/GCD/datab
add wave -noupdate -radix unsigned /tb/DUT/GCD/a
add wave -noupdate -radix unsigned /tb/DUT/GCD/b
add wave -noupdate -radix unsigned /tb/DUT/GCD/result
add wave -noupdate -radix unsigned /tb/DUT/GCD/done_internal
add wave -noupdate -radix unsigned /tb/DUT/GCD/done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {419 ps}
