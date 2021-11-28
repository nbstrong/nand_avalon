#include <stdio.h>
#include "address_map_arm.h"
#include "nand.h"

#define PRINT_PASSES 0
#define N 100 // How many addresses to test

void compare(int a, int b);

int fails, compares = 0;

int main(void) {
    int rdData, i;

    init_nand();

    _command_write(CTRL_WRITE_ENABLE_CMD);

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

    printf("\n[Compares:Fails] %u:%u", compares, fails);
    printf("\nFin.");
    return 0;
}

void compare(int a, int b) {
    compares++;
    if(a == b) {
        if(PRINT_PASSES) {
            printf("\n[PASS] : %u == %u", a, b);
        }
    }
    else {
        printf("\n[FAIL] : %u != %u", a, b);
        fails++;
    }
}
