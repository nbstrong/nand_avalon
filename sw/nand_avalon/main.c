#include <stdio.h>
#include "address_map_arm.h"
#include "nand.h"

int main(void) {
    //nand_init();

    printf("\n%x", *(volatile int*) NAND_STATUS_8);
    write_command_reg(NAND_READ_PARAMETER_PAGE_CMD);
    printf("\n%x", *(volatile int*) NAND_STATUS_8);

    //nand_read();

    //nand_write();

    //nand_read();

    printf("\nFin.");
    return 0;
}
