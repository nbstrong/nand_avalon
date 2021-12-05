vlog ../behav/tb.sv ../behav/memory_models/l72a_nand_model/nand_model.v ../behav/memory_models/l72a_nand_model/nand_die_model.v
vcom ../../hdl/nand_avalon.vhd ../../hdl/onfi_package.vhd ../../hdl/io_unit.vhd ../../hdl/latch_unit.vhd ../../hdl/nand_master.vhd
vsim work.tb -do wave.do
run -all