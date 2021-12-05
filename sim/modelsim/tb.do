vlog -novopt ../memory_models/MLC_nand_model/nand_model.v ../memory_models/MLC_nand_model/nand_die_model.v ../tb.sv
vcom -novopt ../../hdl/nand_avalon.vhd ../../hdl/onfi_package.vhd ../../hdl/io_unit.vhd ../../latch_unit.vhd ../../nand_master.vhd
vsim -novopt work.tb -do wave.do
run -all