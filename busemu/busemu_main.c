#include <stdio.h>

#define RESET(x) (x?0:1<<8)
#define ERR(x) (x?1<<9:0)

static int initialized = 0;

int
busemu_cycle(int addr, int datain, int we){
    /* NB: nRESET and nWE are active-low */
    int do_reset;
    int do_err;
    int do_write;
    int dataout;
    if(we){
        do_write = 0;
    }else{
        do_write = 1;
    }
    if(initialized<4){
        printf("Reset: %x %x %x\n", addr, datain, we);
        do_reset = 1;
        initialized++;
    }else{
        printf("Cycle: %x %x %x\n", addr, datain, we);
        do_reset = 0;
    }
    dataout = 0;
    do_err = 0;
    return RESET(do_reset)|ERR(do_err)|dataout;
}
