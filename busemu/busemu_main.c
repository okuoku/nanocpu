#include <stdio.h>

#define OP_NOR 0
#define OP_ADD 1
#define OP_STA 2
#define OP_JCC 3

#define OP(x,y) (x<<6|y)
#define OP0(x,y) (x<<6|y)

#define SWD (OP0(OP_JCC,64-4)) /* SWitch to Data space */
#define SWS (OP0(OP_JCC,64-3)) /* SWitch to Scratch space */
#define LDS (OP0(OP_JCC,64-2)) /* Load Data Segment */
#define LPS (OP0(OP_JCC,64-1)) /* Load Program Segment */

#define NOR(x) OP(OP_NOR,x)
#define ADD(x) OP(OP_ADD,x)
#define STA(x) OP(OP_STA,x)
#define JCC(x) OP(OP_JCC,x)

#define BIT_RESET(x) (x?0:1<<8)
#define BIT_ERR(x) (x?1<<9:0)

#define ATTR_UNINIT 0
#define ATTR_ROM 1
#define ATTR_RAM 2

static int cycles = 0;
static int initialized = 0;

#define ROMRAMSIZE (1<<14)
static unsigned char romram[ROMRAMSIZE];
static unsigned char romram_attr[ROMRAMSIZE];

#include "scrdefs.h"
#include "rom0.inc.c"

typedef int (*bushandler_t)(int addr, int datain, int we);

static bushandler_t bushandlers[256];

static int /* -1 for err */
handler_romram(int addr, int datain, int we){
    const int do_write = we ? 0 : 1;
    int r;
    if(do_write){
        if(romram_attr[addr] == ATTR_ROM){
            printf("ROMRAM: Write cycle for ROM region!(0x%x)\n", addr);
            return -1;
        }
        printf("ROMRAM: Write %x <= %x\n", addr, datain);
        romram[addr] = datain;
        romram_attr[addr] = ATTR_RAM;
        return 0;
    }else{
        if(romram_attr[addr] == ATTR_UNINIT){
            printf("ROMRAM: Undefined value!(0x%x)\n", addr);
            r = 0xcc;
        }else{
            r = romram[addr];
        }
        printf("ROMRAM: Read %x => %x\n", addr, r);
        return r;
    }
}

static int /* -1 for err */
handler_da(int addr, int datain, int we){
    const int segaddr = addr & 63;
    if(segaddr){
        printf("DA: Unknown segaddr(%d)!\n", segaddr);
        return -1;
    }
    if(we){
        printf("DA: Read from DA!(0x%x)\n", addr);
        return -1;
    }
    switch(datain){
        case 0: /* Halt */
            printf("DA: Halt.\n");
            return -1;
        case 2: /* Dump Scratch RAM */
            printf("DA: Dump scratch.\n");
            break;
        default:
            printf("DA: Unknown DA command!(0x%x)\n", datain);
            return -1;
    }
    return 0;
}

static void
fillrom(int segment, const char* data){
    int i;
    for(i=0;i!=64;i++){
        romram[segment*64+i] = data[i];
        romram_attr[segment*64+i] = ATTR_ROM;
    }
}

static void
load_roms(void){
    int i;
    for(i=0;i!=256;i++){
        bushandlers[i] = handler_romram;
    }

    /* Install debug adapter */
    bushandlers[4] = handler_da;

    /* Init ram */
    for(i=0;i!=ROMRAMSIZE;i++){
        romram[i] = 0xcc;
        romram_attr[i] = ATTR_UNINIT;
    }

    /* Rom0 */
    fillrom(0, rom0_data);
}

int
busemu_cycle(int addr, int datain, int oe, int we){
    /* NB: nRESET and nWE are active-low */
    int do_reset;
    int do_err;
    int do_write;
    int dataout;
    int seg;
    int r;

    do_reset = 0;
    do_err = 0;
    dataout = 0;
    if(we){
        do_write = 0;
    }else{
        do_write = 1;
    }
    if(initialized == 0){
        printf("Reset: Load ROM.\n");
        load_roms();
        initialized++;
    }

    printf("Cycle: %x %x %x\n", addr, datain, we);
    seg = addr >> 6;
    if(seg < 0 || seg > 255){
        printf("Cycle: SEG overflow. (0x%x, read-zero)\n",addr);
        dataout = 0;
    }else{
        r = bushandlers[seg](addr,datain,we);
        if(r < 0 || r > 255){
            printf("Cycle: Bus error(%d)\n", r);
            do_err = 1;
        }else{
            do_err = 0;
            dataout = r;
        }
    }

    cycles ++;
    if(cycles == 100){
        printf("Cycle: Timeout.\n");
        do_err = 1;
    }
    return BIT_RESET(do_reset)|BIT_ERR(do_err)|dataout;
}
