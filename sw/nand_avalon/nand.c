#include <nand.h>

// Basic functions
void write_data_reg(int data){
    *(volatile int*) NAND_DATA_32 = data;
}

int write_data_reg(){
    *(volatile int*) NAND_DATA_32 = data;
}

// The interface will likely throw away everything
// but the lower byte.
void write_command_reg(int data){
    *(volatile int*) NAND_CMD_8 = data;
}

int read_status_reg(){
    return *(volatile int*) NAND_STATUS_8;
}

// extern void nand_init(void) {

// }
int nand_read_id() {
    write_command_reg(NAND_READ_ID_CMD);
}
// extern void nand_read_paramater_page(void) {

// }
// extern void nand_read(unsigned int ddr, unsigned int nand, unsigned int length) {

// }
// extern void nand_write(unsigned int ddr, unsigned int nand, unsigned int length) {

// }
// extern void nand_erase(unsigned int nand, unsigned int length) {

// }