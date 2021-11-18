#include <stdio.h>
#include "address_map_arm.h"
#include "defines.h"
#include "interrupt_ID.h"
/* This file:
 * 1. defines exception vectors for the A9 processor
 * 2. provides code that sets the IRQ mode stack, and that dis/enables
 * interrupts
 * 3. provides code that initializes the generic interrupt controller
 * 4. defines ISRs
*/

extern volatile int gcd_done;
extern volatile int tick;
extern volatile int key_dir;
extern volatile int pattern;

void config_interrupt(int N, int CPU_target);
void GCD_Avalon_ISR(void);
void HPS_timer_ISR(void);
void interval_timer_ISR(void);
void pushbutton_ISR(void);

// Define the IRQ exception handler
void __attribute__((interrupt)) __cs3_isr_irq(void)
{
    // Read the ICCIAR from the processor interface
    int address = MPCORE_GIC_CPUIF + ICCIAR;
    int int_ID  = *((int *)address);

    if (int_ID == GCD_AVALON_IRQ) // check if interrupt is from the GCD Avalon
        GCD_Avalon_ISR();
    else if (int_ID == HPS_TIMER0_IRQ) // check if interrupt is from the HPS timer
        HPS_timer_ISR();
    else if (int_ID ==
             INTERVAL_TIMER_IRQ) // check if interrupt is from the Altera timer
        interval_timer_ISR();
    else if (int_ID == KEYS_IRQ) // check if interrupt is from the KEYs
        pushbutton_ISR();
    else
        while (1)
            ; // if unexpected, then stay here

    // Write to the End of Interrupt Register (ICCEOIR)
    address           = MPCORE_GIC_CPUIF + ICCEOIR;
    *((int *)address) = int_ID;

    return;
}

// Define the remaining exception handlers
void __attribute__((interrupt)) __cs3_reset(void)
{
    while (1)
        ;
}

void __attribute__((interrupt)) __cs3_isr_undef(void)
{
    while (1)
        ;
}

void __attribute__((interrupt)) __cs3_isr_swi(void)
{
    while (1)
        ;
}

void __attribute__((interrupt)) __cs3_isr_pabort(void)
{
    while (1)
        ;
}

void __attribute__((interrupt)) __cs3_isr_dabort(void)
{
    while (1)
        ;
}

void __attribute__((interrupt)) __cs3_isr_fiq(void)
{
    while (1)
        ;
}

/*
 * Initialize the banked stack pointer register for IRQ mode
*/
void set_A9_IRQ_stack(void)
{
    int stack, mode;
    stack = A9_ONCHIP_END - 7; // top of A9 onchip memory, aligned to 8 bytes
    /* change processor to IRQ mode with interrupts disabled */
    mode = INT_DISABLE | IRQ_MODE;
    asm("msr cpsr, %[ps]" : : [ps] "r"(mode));
    /* set banked stack pointer */
    asm("mov sp, %[ps]" : : [ps] "r"(stack));

    /* go back to SVC mode before executing subroutine return! */
    mode = INT_DISABLE | SVC_MODE;
    asm("msr cpsr, %[ps]" : : [ps] "r"(mode));
}

/*
 * Turn on interrupts in the ARM processor
*/
void enable_A9_interrupts(void)
{
    int status = SVC_MODE | INT_ENABLE;
    asm("msr cpsr, %[ps]" : : [ps] "r"(status));
}

/*
 * Configure the Generic Interrupt Controller (GIC)
*/
void config_GIC(void)
{
    int address; // used to calculate register addresses

    /* configure the HPS timer interrupt */
    config_interrupt(HPS_TIMER0_IRQ, 1);

    /* configure the FPGA interval timer and KEYs interrupts */
    config_interrupt(INTERVAL_TIMER_IRQ, 1);
    config_interrupt(KEYS_IRQ, 1);

    /* configure GCD_Avalon */
    config_interrupt(GCD_AVALON_IRQ, 1);

    // Set Interrupt Priority Mask Register (ICCPMR). Enable interrupts of all
    // priorities
    address           = MPCORE_GIC_CPUIF + ICCPMR;
    *((int *)address) = 0xFFFF;

    // Set CPU Interface Control Register (ICCICR). Enable signaling of
    // interrupts
    address           = MPCORE_GIC_CPUIF + ICCICR;
    *((int *)address) = ENABLE;

    // Configure the Distributor Control Register (ICDDCR) to send pending
    // interrupts to CPUs
    address           = MPCORE_GIC_DIST + ICDDCR;
    *((int *)address) = ENABLE;
}

/*
* Configure Set Enable Registers (ICDISERn) and Interrupt Processor Target
* Registers (ICDIPTRn). The default (reset) values are used for other registers
* in the GIC.
*/
void config_interrupt(int N, int CPU_target) {
	int reg_offset, index, value, address;
	/* Configure the Interrupt Set-Enable Registers (ICDISERn).
	* reg_offset = (integer_div(N / 32) * 4
	* value = 1 << (N mod 32) */
	reg_offset = (N >> 3) & 0xFFFFFFFC;
	index = N & 0x1F;
	value = 0x1 << index;
	address = 0xFFFED100 + reg_offset;
	/* Now that we know the register address and value, set the appropriate bit */
	*(int *)address |= value;

	/* Configure the Interrupt Processor Targets Register (ICDIPTRn)
	* reg_offset = integer_div(N / 4) * 4
	* index = N mod 4 */
	reg_offset = (N & 0xFFFFFFFC);
	index = N & 0x3;
	address = 0xFFFED800 + reg_offset + index;
	/* Now that we know the register address and value, write to (only) the
	* appropriate byte */
	*(char *)address = (char)CPU_target;
}

/******************************************************************************
 * GCD_Avalon_ISR
 *
 * This code enables the gcd_done variable in the main program.
 *****************************************************************************/
void GCD_Avalon_ISR()
{
    volatile int tmp;
    gcd_done = 1;
    printf(" T!");
    tmp = *((volatile int*) 0xFF200010+3); // Clear interrupt
    return;
}

/******************************************************************************
 * HPS timer0 interrupt service routine
 *
 * This code increments the tick variable, and clears the interrupt
 *****************************************************************************/
void HPS_timer_ISR()
{
    volatile int * HPS_timer_ptr = (int *)HPS_TIMER0_BASE; // HPS timer address

    ++tick; // used by main program

    *(HPS_timer_ptr + 3); // Read timer end of interrupt register to
                          // clear the interrupt
    return;
}

/*****************************************************************************
 * Interval timer interrupt service routine
 *
 * Shifts a PATTERN being displayed on the LED lights. The shift direction
 * is determined by the external variable key_dir.
 *
******************************************************************************/
void interval_timer_ISR()
{
    volatile int * interval_timer_ptr = (int *)TIMER_BASE;
    volatile int * LED_ptr            = (int *)LED_BASE; // LED address

    *(interval_timer_ptr) = 0; // Clear the interrupt

    *(LED_ptr) = pattern; // Display pattern on LED

    /* rotate the pattern shown on the LED lights */
    if (key_dir == 0) // for 0 rotate left
        if (pattern & 0x80000000)
            pattern = (pattern << 1) | 1;
        else
            pattern = pattern << 1;
    else // rotate right
        if (pattern & 0x00000001)
        pattern = (pattern >> 1) | 0x80000000;
    else
        pattern = (pattern >> 1) & 0x7FFFFFFF;

    return;
}

/***************************************************************************************
 * Pushbutton - Interrupt Service Routine
 *
 * This routine toggles the key_dir variable from 0 <-> 1
****************************************************************************************/
void pushbutton_ISR(void)
{
    volatile int * KEY_ptr = (int *)KEY_BASE;
    int            press;

    press          = *(KEY_ptr + 3); // read the pushbutton interrupt register
    *(KEY_ptr + 3) = press;          // Clear the interrupt

    key_dir ^= 1; // Toggle key_dir value

    return;
}
