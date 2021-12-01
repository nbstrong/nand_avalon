vlog -novopt ../../DE1_SoC_Computer.v ../../hdl/behav/MLC_nand_model/nand_model.v ../../hdl/behav/MLC_nand_model/nand_die_model.v ../../hdl/behav/tb.sv
vcom -novopt ../../hdl/rtl/nand_controller/trunk/VHDL/nand_avalon.vhd ../../hdl/rtl/nand_controller/trunk/VHDL/onfi_package.vhd ../../hdl/rtl/nand_controller/trunk/VHDL/io_unit.vhd ../..//hdl/rtl/nand_controller/trunk/VHDL/latch_unit.vhd ../..//hdl/rtl/nand_controller/trunk/VHDL/nand_master.vhd
vsim -novopt work.tb -do wave.do
run -all