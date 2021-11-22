#ifndef _NAND_H_
#define _NAND_H_

// https://opencores.org/usercontent/doc/1466674234
#define AVALON_NAND_BASE 0xFF200080
#define NAND_DATA_32  ((volatile int*) AVALON_NAND_BASE+0)
#define NAND_CMD_8    ((volatile int*) AVALON_NAND_BASE+1)
#define NAND_STATUS_8 ((volatile int*) AVALON_NAND_BASE+2)

#define INTERNAL_RESET_CMD                00
#define NAND_RESET_CMD                    01
#define NAND_READ_PARAMETER_PAGE_CMD      02
#define NAND_READ_ID_CMD                  03
#define NAND_BLOCK_ERASE_CMD              04
#define NAND_READ_STATUS_CMD              05
#define NAND_READ_PAGE_CMD                06
#define NAND_PAGE_PROGRAM_CMD             07
#define CTRL_GET_STATUS_CMD               08
#define CTRL_CHIP_ENABLE_CMD              09
#define CTRL_CHIP_DISABLE_CMD             10
#define CTRL_WRITE_PROTECT_CMD            11
#define CTRL_WRITE_ENABLE_CMD             12
#define CTRL_RESET_INDEX_CMD              13
#define CTRL_GET_ID_BYTE_CMD              14
#define CTRL_GET_PARAMETER_PAGE_BYTE_CMD  15
#define CTRL_GET_DATA_PAGE_BYTE_CMD       16
#define CTRL_SET_DATA_PAGE_BYTE_CMD       17
#define CTRL_GET_CURRENT_ADDRESS_BYTE_CMD 18
#define CTRL_SET_CURRENT_ADDRESS_BYTE_CMD 19

// Basic functions
void write_data_reg(int data);
void write_command_reg(int data);
int read_status_reg();

int nand_read_id();
int nand_read_paramater_page();
// void nand_read(unsigned int ddr, unsigned int nand, unsigned int length);
// void nand_write(unsigned int ddr, unsigned int nand, unsigned int length);
// void nand_erase(unsigned int nand, unsigned int length);

//void nand_init(void);

#endif	/* _NAND_H_ */
