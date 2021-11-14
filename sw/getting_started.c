#include "address_map_arm.h"
#include <stdio.h>
#include <time.h>

#define USERINPUT 1
#define TIMERINIT 0xFFFFFFFF
#define TIMERCLOCKSPERSEC 200000000
#define TIMERSTART 0x0011
#define TIMERSTOP 0x0000

int euclids_sub(int a, int b);
int euclids_mod(int a, int b);
long long euclids_sub_64(long long a, long long b);
long long euclids_mod_64(long long a, long long b);
void report(long long gcd, clock_t total_time, unsigned int timer_total);

int main(void) {
    int a, b, gcd = 0;
    long long a_64, b_64, gcd_64 = 0;

    clock_t start_time, end_time, total_time = 0;
    unsigned int timer_start, timer_end, timer_total = 0;

    volatile int * MPcore_private_timer_ptr = (int *)MPCORE_PRIV_TIMER;
    *(MPcore_private_timer_ptr)   = 0x0;
    *(MPcore_private_timer_ptr+2) = 0x0000;

    while(1){
        // Got tired of inputting numbers, change #define at top
        if(USERINPUT) {
        printf("\nInput A: ");
        scanf(" %u",&a);
        printf("\nInput B: ");
        scanf(" %u",&b);
        }
        else {
            a = 2147483647;
            b = 524287;
        }
        printf("\nA: %u", a);
        printf("\nB: %u", b);



        printf("\n\n-------- GCD_SUB --------");
        // Test with clock() function
        start_time = clock();
        gcd = euclids_sub(a, b);
        end_time = clock();

        // Test using private arm timer
        *(MPcore_private_timer_ptr) = TIMERINIT; // Initialize timer
        *(MPcore_private_timer_ptr+2) = TIMERSTART; // Start timer
        timer_start = *(MPcore_private_timer_ptr+1); // Read current value
        gcd = euclids_sub(a, b);
        timer_end = *(MPcore_private_timer_ptr+1); // Read current value
        *(MPcore_private_timer_ptr+2) = TIMERSTOP; // Stop timer

        // Calculate
        total_time = end_time - start_time;
        timer_total = timer_start - timer_end;

        // Report
        report((long long)gcd, total_time, timer_total);



        printf("\n\n-------- GCD_MOD --------");
        // Test with clock() function
        start_time = clock();
        gcd = euclids_mod(a, b);
        end_time = clock();

        // Test using private arm timer
        *(MPcore_private_timer_ptr) = TIMERINIT; // Initialize timer
        *(MPcore_private_timer_ptr+2) = TIMERSTART; // Start timer
        timer_start = *(MPcore_private_timer_ptr+1); // Read current value
        gcd = euclids_mod(a, b);
        timer_end = *(MPcore_private_timer_ptr+1); // Read current value
        *(MPcore_private_timer_ptr+2) = TIMERSTOP; // Stop timer

        // Calculate
        total_time = end_time - start_time;
        timer_total = timer_start - timer_end;

        // Report
        report((long long)gcd, total_time, timer_total);


        // Got tired of inputting numbers, change #define at top
        if(USERINPUT) {
        printf("\nInput A: ");
        scanf(" %llu",&a_64);
        printf("\nInput B: ");
        scanf(" %llu",&b_64);
        }
        else {
            a_64 = 2305843009213693951;
            b_64 = 2147483647;
        }
        printf("\n\nA: %llu", a_64);
        printf("\nB: %llu", b_64);


        // TODO: Subtraction takes too long. Oh well.
        // printf("\n\n-------- GCD_SUB_64 --------");
        // // Test with clock() function
        // start_time = clock();
        // gcd_64 = euclids_sub_64(a_64, b_64);
        // end_time = clock();

        // // Test using private arm timer
        // *(MPcore_private_timer_ptr) = TIMERINIT; // Initialize timer
        // *(MPcore_private_timer_ptr+2) = TIMERSTART; // Start timer
        // timer_start = *(MPcore_private_timer_ptr+1); // Read current value
        // gcd_64 = euclids_sub_64(a_64, b_64);
        // timer_end = *(MPcore_private_timer_ptr+1); // Read current value
        // *(MPcore_private_timer_ptr+2) = TIMERSTOP; // Stop timer

        // // Calculate
        // total_time = end_time - start_time;
        // timer_total = timer_start - timer_end;

        // // Report
        // report(gcd_64, total_time, timer_total);



        printf("\n\n-------- GCD_MOD_64 --------");
        // Test with clock() function
        start_time = clock();
        gcd_64 = euclids_mod_64(a_64, b_64);
        end_time = clock();

        // Test using private arm timer
        *(MPcore_private_timer_ptr) = TIMERINIT; // Initialize timer
        *(MPcore_private_timer_ptr+2) = TIMERSTART; // Start timer
        timer_start = *(MPcore_private_timer_ptr+1); // Read current value
        gcd_64 = euclids_mod_64(a_64, b_64);
        timer_end = *(MPcore_private_timer_ptr+1); // Read current value
        *(MPcore_private_timer_ptr+2) = TIMERSTOP; // Stop timer

        // Calculate
        total_time = end_time - start_time;
        timer_total = timer_start - timer_end;

        // Report
        report(gcd_64, total_time, timer_total);

        char ch;
        printf("\n\nPress ENTER to continue.");
        scanf("%c",&ch);
    }

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

long long euclids_sub_64(long long a, long long b)
{
    if (a == b) {
        return a;}
    if (a > b) {
        return euclids_sub((a-b), b);}
    else {
        return euclids_sub(a, (b-a));}
}

int euclids_mod(int a, int b)
{
    int amb = a % b;
    if(amb == 0) {
        return b;}
    return euclids_mod(b, amb);
}

long long euclids_mod_64(long long a, long long b)
{
    int amb = a % b;
    if(amb == 0) {
        return b;}
    return euclids_mod(b, amb);
}

void report(long long gcd, clock_t total_time, unsigned int timer_total)
{
    printf("\nGCD : %lli", gcd);
    printf("\nClock Time: %E sec",     ((float)total_time)/CLOCKS_PER_SEC);
    printf("\nTimer Time: %E sec", ((float)timer_total)/TIMERCLOCKSPERSEC);
}

// Debug code
// printf( "\nstart_time: %i", (int)start_time);
// printf(   "\nend_time: %i",   (int)end_time);
// printf( "\ntotal_time: %i", (int)total_time);
// printf("\ntimer_start: %u",     timer_start);
// printf(  "\ntimer_end: %u",       timer_end);
// printf("\ntimer_total: %u",     timer_total);
