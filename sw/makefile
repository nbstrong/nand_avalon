# Created by the Intel FPGA Monitor Program
# DO NOT MODIFY

############################################
# Global Defines
DEFINE_COMMA	:= ,

############################################
# Compilation Targets

# Programs
AS		:= arm-altera-eabi-as
CC		:= arm-altera-eabi-gcc
LD		:= arm-altera-eabi-ld
OC		:= arm-altera-eabi-objcopy
RM		:= rm -f

# Flags
USERCCFLAGS	:= -g -O1
ARCHASFLAGS	:= -mfloat-abi=soft -march=armv7-a -mcpu=cortex-a9 --gstabs -I "$$GNU_ARM_TOOL_ROOTDIR/arm-altera-eabi/include/"
ARCHCCFLAGS	:= -mfloat-abi=soft -march=armv7-a -mtune=cortex-a9 -mcpu=cortex-a9
ARCHLDFLAGS	:= --defsym arm_program_mem=0x0 --defsym arm_available_mem_size=0x3ffffff8 --defsym __cs3_stack=0x3ffffff8
ARCHLDSCRIPT	:= -T"Z:/intelFPGA_lite/18.1/University_Program/Monitor_Program/build/altera-socfpga-hosted.ld"
ASFLAGS		:= $(ARCHASFLAGS)
CCFLAGS		:= -Wall -c $(USERCCFLAGS) $(ARCHCCFLAGS)
LDFLAGS		:= $(patsubst %, -Wl$(DEFINE_COMMA)%, $(ARCHLDFLAGS)) $(ARCHLDSCRIPT)
OCFLAGS		:= -O srec

# Files
HDRS		:= address_map_arm.h
SRCS		:= main.c
OBJS		:= $(patsubst %, %.o, $(SRCS))

# Targets
COMPILE: main.srec

main.srec: main.axf
	$(RM) $@
	$(OC) $(OCFLAGS) $< $@

main.axf: $(OBJS)
	$(RM) $@
	$(CC) $(LDFLAGS) $(OBJS) -o $@

%.c.o: %.c $(HDRS)
	$(RM) $@
	$(CC) $(CCFLAGS) $< -o $@

%.s.o: %.s $(HDRS)
	$(RM) $@
	$(AS) $(ASFLAGS) $< -o $@

CLEAN: 
	$(RM) main.srec main.axf $(OBJS)

