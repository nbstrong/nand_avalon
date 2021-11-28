#ifndef _NAND_H_
#define _NAND_H_

// https://opencores.org/usercontent/doc/1466674234
#define AVALON_NAND_BASE 0xFF200080
#define NAND_DATA_32  ((volatile int*) AVALON_NAND_BASE+0)
#define NAND_CMD_8    ((volatile int*) AVALON_NAND_BASE+1)
#define NAND_STATUS_8 ((volatile int*) AVALON_NAND_BASE+2)

#define INTERNAL_RESET_CMD                 0
#define NAND_RESET_CMD                     1
#define NAND_READ_PARAMETER_PAGE_CMD       2
#define NAND_READ_ID_CMD                   3
#define NAND_BLOCK_ERASE_CMD               4
#define NAND_READ_STATUS_CMD               5
#define NAND_READ_PAGE_CMD                 6
#define NAND_PAGE_PROGRAM_CMD              7
#define CTRL_GET_STATUS_CMD                8
#define CTRL_CHIP_ENABLE_CMD               9
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
#define NAND_BYPASS_ADDRESS               20
#define NAND_BYPASS_COMMAND               21
#define NAND_BYPASS_DATA_WR               22
#define NAND_BYPASS_DATA_RD               23

int init_nand();
void _poll_busy();
void _wait_nand_powerup();
void _command_write(int cmd);
void _command_write_data(int cmd, int data);
int _command_read(int cmd);
void _write_data_reg(int data);
void _write_command_reg(int data);
int _read_data_reg();
int _read_command_reg();
int _read_status_reg();

#endif	/* _NAND_H_ */
