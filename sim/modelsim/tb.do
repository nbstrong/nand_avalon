vlog ../behav/memory_models/MLC_nand_model/nand_model.v ../behav/memory_models/MLC_nand_model/nand_die_model.v ../behav/tb.sv
vcom ../../hdl/nand_avalon.vhd ../../hdl/onfi_package.vhd ../../hdl/io_unit.vhd ../../hdl/latch_unit.vhd ../../hdl/nand_master.vhd
vsim work.tb -do wave.do
run -all