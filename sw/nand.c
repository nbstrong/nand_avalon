#include <stdio.h>
#include "nand.h"

// Initializes NAND controller, reads status ID.
// Reads parameter page_buf.
// Returns 1 if initialization was successful and
// chip supports ONFI.
// Returns 0 if chip doesn't support ONFI.
int init_nand() {
    _command_write(INTERNAL_RESET_CMD);
    _command_write(CTRL_CHIP_ENABLE_CMD);
    _wait_nand_powerup();
    _command_write(NAND_RESET_CMD);
    _command_write(NAND_READ_ID_CMD);
    for (volatile int i = 0; i < 200;i++) {}; // 200 cycle delay to make up for hardware t_RHW violation
    _command_write(NAND_READ_PARAMETER_PAGE_CMD);
    _command_write(CTRL_RESET_INDEX_CMD);
    _command_write(CTRL_WRITE_ENABLE_CMD);
    return (_command_read(CTRL_GET_STATUS_CMD) & 1);
}

void _set_address(int addr) {
    _command_write(CTRL_RESET_INDEX_CMD);
    for(int i = 0; i < 5;i++){
        _command_write_data(CTRL_SET_CURRENT_ADDRESS_BYTE_CMD, ((addr >> (i*8)) & 0xFF));
    }
}

int _get_address() {
    int addr = 0;
    _command_write(CTRL_RESET_INDEX_CMD);
    for(int i = 0; i < 5;i++){
        addr |= _command_read(CTRL_GET_CURRENT_ADDRESS_BYTE_CMD) << (i*8);
    }
    return addr;
}

uint64_t gen_address(uint16_t block_idx, uint16_t page_idx, uint16_t col_idx) {
    return block_idx << 24 | page_idx << 16 | col_idx;
}

void write_page(uint8_t *page_buf, uint64_t address) {
    _set_address(address);
    _write_page(page_buf);
}

void _write_page(uint8_t *page_buf) {
    // Writes an entire page

    _command_write(CTRL_RESET_INDEX_CMD);
    for(uint16_t col_addr = 0; col_addr < PAGELEN; col_addr++) {
        _command_write_data(CTRL_SET_DATA_PAGE_BYTE_CMD, page_buf[col_addr]);
    }
    _command_write(NAND_PAGE_PROGRAM_CMD);
}

void read_page(uint8_t *page_buf, uint64_t address) {
    _set_address(address);
    _read_page(page_buf);
}

void _read_page(uint8_t *page_buf) {
    // Reads an entire page

    _command_write(NAND_READ_PAGE_CMD);
    _command_write(CTRL_RESET_INDEX_CMD);
    for(uint16_t col_addr = 0; col_addr < PAGELEN; col_addr++) {
        page_buf[col_addr] = _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD);
    }
}

void print_status() {
    uint8_t status = 0;
    status = _command_read(CTRL_GET_STATUS_CMD);
    printf("\n\n%hhx : is ONFI compliant          ", ((status >> 0) & 1));
    printf("\n%hhx : bus width (0 - x8 / 1 - x16) ", ((status >> 1) & 1));
    printf("\n%hhx : is chip enabled              ", ((status >> 2) & 1));
    printf("\n%hhx : is chip write protected      ", ((status >> 3) & 1));
    printf("\n%hhx : array pointer out of bounds  ", ((status >> 4) & 1));
}

void print_page_buffer(uint8_t *page_buf, uint8_t num_cols) {
    printf("\n");
    for(uint8_t i = 0; i < num_cols; i++) {
        if(i % 8 == 0){
            printf("\n");
        }
        printf("%x ", page_buf[i]);
    }
    printf("\n");
}

void _poll_busy(){
    long int status = 0;
    int n_busy = 1;
    int rnb = 0;
    do {
        status = _read_status_reg();
        n_busy = (status >> 0) & 1;
        rnb = (status >> 1) & 1;

        if (DEBUG) {
            if(n_busy == 1){
                printf("\n%lx Controller Busy", status);
            }
            if(rnb == 0) {
                printf("\n%lx NAND Busy", status);
            }
        }
    } while(n_busy == 1 || rnb == 0);
}

// A timer would make this more accurate but
// less system agnostic.
void _wait_nand_powerup(){
    for(volatile int i=0;i<10000;i++); {}
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
