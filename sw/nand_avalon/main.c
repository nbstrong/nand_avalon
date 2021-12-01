#include <stdio.h>
#include "address_map_arm.h"
#include "nand.h"

#define PRINT_PASSES 0 // Whether to print passing compare results
#define N 100          // How many addresses to test

void compare(int a, int b);
void print_chip_id();
void print_status();

int fails, compares = 0;

int main(void) {
    int rdData, i;

    init_nand();

    print_chip_id();
    print_status();

    // Verify NAND's Initial State
    _command_write(NAND_READ_PAGE_CMD);
    _command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i++) {
        rdData = _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD);
        compare(rdData, 0xFF);
    }

    // Write controller pages with known sequence
    _command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) {
        _command_write_data(CTRL_SET_DATA_PAGE_BYTE_CMD, i);
    }
    // Write controller pages to NAND
    _command_write(NAND_PAGE_PROGRAM_CMD);

    // Write controller pages with known different sequence
    _command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) {
        _command_write_data(CTRL_SET_DATA_PAGE_BYTE_CMD, 0x1);
    }
    // Verify controller page is different from nand
    _command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) {
        rdData = _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD);
        compare(rdData, 0x1);
    }

    // Read previously written page from NAND
    _command_write(NAND_READ_PAGE_CMD);
    _command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) {
        rdData = _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD);
        compare(rdData, i);
    }

    // Erase chip
    _command_write(NAND_BLOCK_ERASE_CMD);
    // Verify chip is erased
    _command_write(NAND_READ_PAGE_CMD);
    _command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) {
        rdData = _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD);
        compare(rdData, 0xFF);
    }

    printf("\n\n[Compares:Fails] %i:%i", compares, fails);
    printf("\nFin.");
    while(1) {}
    return 0;
}

void compare(int a, int b) {
    compares++;
    if(a == b) {
        if(PRINT_PASSES) {
            printf("[PASS] : %x == %x", a, b);
        }
    }
    else {
        printf("[FAIL] : %x != %x", a, b);
        fails++;
    }
}

void print_chip_id() {
    _command_write(CTRL_RESET_INDEX_CMD);
    for(int i = 0; i < 5; i++) {
        int id = 0;
        id = _command_read(CTRL_GET_ID_BYTE_CMD);
        printf("\nID Byte %i : %x", i, id);
    }
}

void print_status() {
    int status = 0;
    status = _command_read(CTRL_GET_STATUS_CMD);
    printf("\n\n%x : is ONFI compliant          ", ((status >> 0) & 1));
    printf("\n%x : bus width (0 - x8 / 1 - x16) ", ((status >> 1) & 1));
    printf("\n%x : is chip enabled              ", ((status >> 2) & 1));
    printf("\n%x : is chip write protected      ", ((status >> 3) & 1));
    printf("\n%x : array pointer out of bounds  ", ((status >> 4) & 1));
}
