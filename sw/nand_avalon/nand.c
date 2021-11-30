#include "nand.h"

// Initializes NAND controller, reads status ID.
// Reads parameter page.
// Returns 1 if initialization was successful and
// chip supports ONFI.
// Returns 0 if chip doesn't support ONFI.
// Likely to stall if unsuccessful.
int init_nand() {
    _command_write(INTERNAL_RESET_CMD);
    _command_write(CTRL_CHIP_ENABLE_CMD);
    _wait_nand_powerup();
    _command_write(NAND_RESET_CMD);
    _command_write(NAND_READ_ID_CMD);
    _command_write(NAND_READ_PARAMETER_PAGE_CMD);
    _command_write(CTRL_RESET_INDEX_CMD);
    return (_command_read(CTRL_GET_STATUS_CMD) & 1);
}

void _poll_busy(){
    int status;
    status = _read_status_reg();
    while((status & (1 << 0)) == 1 && (status & (1 << 1)) == 0) {status = _read_status_reg();}
}

void _wait_nand_powerup(){
    for(int i=0;i<5000;i++);	//100 us max
}

// The below _command functions should eventually be
// abstracted away so the user doesn't have to input
// a command manually.
void _command_write(int cmd) {
    _write_command_reg(cmd);
    _poll_busy();
}

void _command_write_data(int cmd, int data) {
    _write_data_reg(data);
    _write_command_reg(cmd);
    _poll_busy();
}

int _command_read(int cmd) {
    _write_command_reg(cmd);
    _poll_busy();
    return _read_data_reg();
}

// Primitives
void _write_data_reg(int data) {
    *(volatile int*) NAND_DATA_32 = data;
}

void _write_command_reg(int data) {
    *(volatile int*) NAND_CMD_8 = data;
}

int _read_data_reg() {
    return *(volatile int*) NAND_DATA_32;
}

int _read_command_reg() {
    return *(volatile int*) NAND_CMD_8;
}

int _read_status_reg() {
    return *(volatile int*) NAND_STATUS_8;
}