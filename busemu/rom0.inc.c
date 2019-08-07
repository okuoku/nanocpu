static char rom0_data[] = {
    /* 00 */ SWS,       /* Switch to scratch */
    /* 01 */ STA(SCR_ZERO), /* ACC = 0 on reset */
    /* 02 */ NOR(SCR_ZERO), /* ACC = allone */
    /* 03 */ STA(SCR_ALLONE),
    /* 04 */ ADD(SCR_ALLONE), /* ACC = ~1 */
    /* 05 */ STA(SCR_ONE),    /* Save ~1 to temp */
    /* 06 */ NOR(SCR_ONE),    /* ACC = 1 */
    /* 07 */ STA(SCR_ONE),    /* 1 */
    /* 08 */ ADD(SCR_ONE),
    /* 09 */ STA(SCR_TWO),    /* 2 */
    /* 10 */ ADD(SCR_ONE),
    /* 11 */ STA(SCR_THREE),  /* 3 */
    /* 12 */ ADD(SCR_ONE), 
    /* 13 */ STA(SCR_FOUR),   /* 4 */
    /* 14 */ SWD,       /* Switch to Data (= rom0) */
    /* 15 */ NOR(62),   /* Clear ACC */
    /* 16 */ ADD(63),   /* Load 128 */
    /* 17 */ SWS, 
    /* 18 */ STA(SCR_128), 
    /* 19 */ JCC(21), 
    /* 20 */ JCC(21), 
    /* 21 */ NOR(SCR_ALLONE), 
    /* 22 */ ADD(SCR_FOUR), /* 4: Debug adapter */
    /* 23 */ LDS, 
    /* 24 */ NOR(SCR_ALLONE), 
    /* 25 */ ADD(SCR_TWO),  /* DA0-2: Dump scratch RAM */
    /* 26 */ SWD, 
    /* 27 */ STA(0), 
    /* 28 */ SWS, 
    /* 29 */ NOR(SCR_ALLONE),
    /* 30 */ ADD(SCR_128), 
    /* 31 */ ADD(SCR_ONE),
    /* 32 */ LPS,           /* Switch to back 129 */
    /* 33 */ JCC(32), 
    /* 34 */ JCC(32), 
    /* 35 */ 0, 
    /* 36 */ 0, 
    /* 37 */ 0, 
    /* 38 */ 0, 
    /* 39 */ 0, 
    /* 40 */ 0, 
    /* 41 */ 0, 
    /* 42 */ 0, 
    /* 43 */ 0, 
    /* 44 */ 0, 
    /* 45 */ 0, 
    /* 46 */ 0, 
    /* 47 */ 0, 
    /* 48 */ 0, 
    /* 49 */ 0, 
    /* 50 */ 0, 
    /* 51 */ 0, 
    /* 52 */ 0, 
    /* 53 */ 0, 
    /* 54 */ 0, 
    /* 55 */ 0, 
    /* 56 */ 0, 
    /* 57 */ 0, 
    /* 58 */ 0, 
    /* 59 */ 0, 
    /* 60 */ 0, 
    /* 61 */ 0, 
    /* 62 */ 255,  /* ALLONE */
    /* 63 */ 128,  /* 128 */
};
