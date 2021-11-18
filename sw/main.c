#include "address_map_arm.h"
#include <stdio.h>
#include <time.h>

#define USERINPUT         0          // Whether to get user input or not
#define TIMERINIT         0xFFFFFFFF // Timer Decrements (cannot be changed)
#define TIMERCLOCKSPERSEC 200000000  // ARM A9 MPCore Private Timer runs off 200 MHz
#define TIMERSTART        0x1        // Enable
#define TIMERSTOP         0x0        // Disable

#define PRIV_TIMER_LOAD ((volatile int*) MPCORE_PRIV_TIMER+0)
#define PRIV_TIMER_COUNTER ((volatile int*) MPCORE_PRIV_TIMER+1)
#define PRIV_TIMER_CONTROL ((volatile int*) MPCORE_PRIV_TIMER+2)

#define AVALON_GCD_BASE 0xFF200010
#define AVALON_GCD_A ((volatile int*) AVALON_GCD_BASE+0)
#define AVALON_GCD_B ((volatile int*) AVALON_GCD_BASE+1)
#define AVALON_GCD_RESULT ((volatile int*) AVALON_GCD_BASE+2)
#define AVALON_GCD_STATUS ((volatile int*) AVALON_GCD_BASE+3)

void set_A9_IRQ_stack(void);
void config_GIC(void);
void config_HPS_timer(void);
void config_HPS_GPIO1(void);
void config_interval_timer(void);
void config_KEYs(void);
void enable_A9_interrupts(void);
int euclids_sub(int a, int b);
int avalon_sub(int a, int b);

/* key_dir and pattern are written by interrupt service routines; we have to
 * declare these as volatile to avoid the compiler caching their values in
 * registers */
volatile int tick    = 0; // set to 1 every time the HPS timer expires
volatile int key_dir = 0;
volatile int pattern = 0x0F0F0F0F; // pattern for LED lights
volatile int gcd_done = 0;

#define VECLENGTH 5 // Length of test vector array
unsigned int a_vec [VECLENGTH] = {
		91,
		1,
		1000000,
		2,
		2147483647
};
unsigned int b_vec [VECLENGTH] = {
		21,
		1,
		1,
		1023,
		524287
};

int main(void) {
    volatile int * HPS_GPIO1_ptr = (int *)HPS_GPIO1_BASE; // GPIO1 base address
    volatile int   HPS_timer_LEDG = 0x01000000; // value to turn on the HPS green light LEDG
    int i;
    unsigned int a, b = 0;
    volatile unsigned int gcd_sw, gcd_hw = 0;
    *PRIV_TIMER_LOAD    = 0x0;
    *PRIV_TIMER_CONTROL = 0x0000;


    set_A9_IRQ_stack();      // initialize the stack pointer for IRQ mode
    config_GIC();            // configure the general interrupt controller
    config_HPS_timer();      // configure the HPS timer
    config_HPS_GPIO1();      // configure the HPS GPIO1 interface
    config_interval_timer(); // configure Altera interval timer to generate
                             // interrupts
    config_KEYs();           // configure pushbutton KEYs to generate interrupts

    enable_A9_interrupts(); // enable interrupts

    for(i = 0; i < VECLENGTH; i++) {
        unsigned int sw_timer_start, sw_timer_end, sw_timer_total = 0;
        unsigned int hw_timer_start, hw_timer_end, hw_timer_total = 0;

        // Got tired of inputting numbers, change #define at top
        if(USERINPUT && (i == 0)) {
        printf("\nInput A: ");
        scanf(" %u",&a);
        printf("\nInput B: ");
        scanf(" %u",&b);
        }
        else {
            a = a_vec[i];
            b = b_vec[i];
        }
        printf("\nA: %u", a);
        printf("\nB: %u", b);

        // Software GCD
        *PRIV_TIMER_LOAD = TIMERINIT;         // Initialize timer
        *PRIV_TIMER_CONTROL = TIMERSTART;     // Start timer
        sw_timer_start = *PRIV_TIMER_COUNTER; // Read current value
        gcd_sw = euclids_sub(a, b);           // Calculate GCD
        sw_timer_end = *PRIV_TIMER_COUNTER;   // Read current value
        *PRIV_TIMER_CONTROL = TIMERSTOP;      // Stop timer

        // Hardware GCD
        *PRIV_TIMER_LOAD = TIMERINIT;         // Initialize timer
        *PRIV_TIMER_CONTROL = TIMERSTART;     // Start timer
        hw_timer_start = *PRIV_TIMER_COUNTER; // Read current value
        gcd_hw = avalon_sub(a, b);            // Calculate GCD
        hw_timer_end = *PRIV_TIMER_COUNTER;   // Read current value
        *PRIV_TIMER_CONTROL = TIMERSTOP;      // Stop timer

        sw_timer_total = sw_timer_start - sw_timer_end;
        hw_timer_total = hw_timer_start - hw_timer_end;

        printf("\nGCD_SW: %x", gcd_sw);
        printf("\nGCD_HW: %x", gcd_hw);
        printf("\nSW Cycles: %u SW Time: %E sec", sw_timer_total, ((float)sw_timer_total)/TIMERCLOCKSPERSEC);
        printf("\nHW Cycles: %u HW Time: %E sec", hw_timer_total, ((float)hw_timer_total)/TIMERCLOCKSPERSEC);
        printf("\nSpeedup: %f", ( (float)sw_timer_total/TIMERCLOCKSPERSEC ) / ( (float)hw_timer_total/TIMERCLOCKSPERSEC ) );

        printf("\n");
    }

    printf("\nFin.");
    return 0;
}

int euclids_sub(int a, int b)
{
    if (a == b) {
        return a;}
    if (a > b) {
        return euclids_sub((a-b), b);}
    else {
        return euclids_sub(a, (b-a));}
}

int avalon_sub(int a, int b)
{
    *AVALON_GCD_A = a;
    *AVALON_GCD_B = b;
    while(!gcd_done) {}
    gcd_done = 0;
    return *AVALON_GCD_RESULT;
}

/* setup HPS timer */
void config_HPS_timer()
{
    volatile int * HPS_timer_ptr = (int *)HPS_TIMER0_BASE; // timer base address

    *(HPS_timer_ptr + 0x2) = 0; // write to control register to stop timer
    /* set the timer period */
    int counter      = 100000000; // period = 1/(100 MHz) x (100 x 10^6) = 1 sec
    *(HPS_timer_ptr) = counter;   // write to timer load register

    /* write to control register to start timer, with interrupts */
    *(HPS_timer_ptr + 2) = 0b011; // int mask = 0, mode = 1, enable = 1
}

/* setup HPS GPIO1. The GPIO1 port has one green light (LEDG) and one pushbutton
 * KEY connected for the DE1-SoC Computer. The KEY is connected to GPIO1[25],
 * and is not used here. The green LED is connected to GPIO1[24]. */
void config_HPS_GPIO1()
{
    volatile int * HPS_GPIO1_ptr = (int *)HPS_GPIO1_BASE; // GPIO1 base address

    *(HPS_GPIO1_ptr + 0x1) =
        0x01000000; // write to the data direction register to set
                    // bit 24 (LEDG) to be an output
    // Other possible actions include setting up GPIO1 to use the KEY, including
    // setting the debounce option and causing the KEY to generate an interrupt.
    // We do not use the KEY in this example.
}

/* setup the interval timer interrupts in the FPGA */
void config_interval_timer()
{
    volatile int * interval_timer_ptr =
        (int *)TIMER_BASE; // interal timer base address

    /* set the interval timer period for scrolling the HEX displays */
    int counter                 = 5000000; // 1/(100 MHz) x 5x10^6 = 50 msec
    *(interval_timer_ptr + 0x2) = (counter & 0xFFFF);
    *(interval_timer_ptr + 0x3) = (counter >> 16) & 0xFFFF;

    /* start interval timer, enable its interrupts */
    *(interval_timer_ptr + 1) = 0x7; // STOP = 0, START = 1, CONT = 1, ITO = 1
}

/* setup the KEY interrupts in the FPGA */
void config_KEYs()
{
    volatile int * KEY_ptr = (int *)KEY_BASE; // pushbutton KEY address

    *(KEY_ptr + 2) = 0x3; // enable interrupts for KEY[1]
}
