# NAND Controller (ONFI compliant)

This is work done to improve the nand_controller listed at:
https://opencores.org/projects/nand_controller

## To run simulation tests with Modelsim:
`cd sim/modelsim/`  

GUI:  
`vsim -do sim.do`  

CLI:  
`vsim -c`  
`do sim.do`  

BATCH:  
`vsim -batch -do sim.do`  
* Batch is current broken. See issue [#5](https://github.com/nbstrong/nand_avalon/issues/5)

## Branches

master - Only includes ONFI controller

extension_module - Includes ONFI Controller + Extension Module design

## System Project
For hardware testing, this controller has been integrated into the current project here:  
https://github.com/nbstrong/DE1_SoC_Computer

## Quartus II 18.2 Platform Builder Component Editor
![image](https://user-images.githubusercontent.com/13934837/144723870-f4b7d36e-4f36-4077-a9e0-a76d7d994393.png)

## Compatability
This design has been tested on hardware successfully with the following NAND chips:  
* MT29F256G08CBCBB  
