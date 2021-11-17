#include "address_map_arm.h"
#include <stdio.h>
#include <time.h>

#define USERINPUT 1 // Whether to get user input or not
#define TIMERINIT 0xFFFFFFFF
#define TIMERCLOCKSPERSEC 200000000
#define TIMERSTART 0x0011
#define TIMERSTOP 0x0000

#define PRIV_TIMER_LOAD ((volatile int*) MPCORE_PRIV_TIMER+0)
#define PRIV_TIMER_COUNTER ((volatile int*) MPCORE_PRIV_TIMER+1)
#define PRIV_TIMER_CONTROL ((volatile int*) MPCORE_PRIV_TIMER+2)

#define AVALON_GCD_BASE 0xFF200010
#define AVALON_GCD_A ((volatile int*) AVALON_GCD_BASE+0)
#define AVALON_GCD_B ((volatile int*) AVALON_GCD_BASE+1)
#define AVALON_GCD_RESULT ((volatile int*) AVALON_GCD_BASE+2)
#define AVALON_GCD_STATUS ((volatile int*) AVALON_GCD_BASE+3)

int euclids_sub(int a, int b);
int avalon_sub(int a, int b);

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
    int i;
    unsigned int a, b = 0;
    volatile unsigned int gcd_sw, gcd_hw = 0;
    *PRIV_TIMER_LOAD    = 0x0;
    *PRIV_TIMER_CONTROL = 0x0000;

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
    while((*AVALON_GCD_STATUS & 0x1) == 0x0) {}
    return *AVALON_GCD_RESULT;
}
