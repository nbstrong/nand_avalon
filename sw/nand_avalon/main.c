#include "address_map_arm.h"

// https://opencores.org/usercontent/doc/1466674234
#define AVALON_NAND_BASE 0xFF200080
#define NAND_DATA_32  ((volatile int*) AVALON_NAND_BASE+0)
#define NAND_CMD_8    ((volatile int*) AVALON_NAND_BASE+1)
#define NAND_STATUS_8 ((volatile int*) AVALON_NAND_BASE+2)

#define INTERNAL_RESET                00
#define NAND_RESET                    01
#define NAND_READ_PARAMETER_PAGE      02
#define NAND_READ_ID                  03
#define NAND_BLOCK_ERASE              04
#define NAND_READ_STATUS              05
#define NAND_READ_PAGE                06
#define NAND_PAGE_PROGRAM             07
#define CTRL_GET_STATUS               08
#define CTRL_CHIP_ENABLE              09
#define CTRL_CHIP_DISABLE             10
#define CTRL_WRITE_PROTECT            11
#define CTRL_WRITE_ENABLE             12
#define CTRL_RESET_INDEX              13
#define CTRL_GET_ID_BYTE              14
#define CTRL_GET_PARAMETER_PAGE_BYTE  15
#define CTRL_GET_DATA_PAGE_BYTE       16
#define CTRL_SET_DATA_PAGE_BYTE       17
#define CTRL_GET_CURRENT_ADDRESS_BYTE 18
#define CTRL_SET_CURRENT_ADDRESS_BYTE 19

int main(void) {

    printf("\nFin.");
    return 0;
}
