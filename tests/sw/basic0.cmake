set(basic0_globals
    _DEF zZero 0
    _DEF zOne 1
    _DEF zTwo 2
    _DEF zThree 3
    _DEF zFour 4
    _DEF z64 5
    _DEF z32 6
    _DEF z16 7
    _DEF z8 8
    _DEF zAllOne 9
    _DEF z128 10
    )

set(basic0_slice0 # 3:000 = Slice 0xc0
    SWS # 00
    # ACC = 0 (Reset)
    STA zZero # 01
    NOR zZero  # 02
    # ACC = AllOne
    STA zAllOne # 03
    ADD zAllOne # 04
    # ACC = 254
    STA zOne # 05
    NOR zOne # 06
    # ACC = 1
    STA zOne # 07
    ADD zOne # 08
    # ACC = 2
    STA zTwo # 09
    ADD zOne # 0a
    # ACC = 3
    STA zThree # 0b
    ADD zOne # 0c
    # ACC = 4
    STA zFour # 0d
    ADD zFour # 0e
    # ACC = 8
    STA z8 # 0f

    ADD z8 # 10
    # ACC = 16
    STA z16 # 11
    ADD z16 # 12
    # ACC = 32
    STA z32 # 13
    ADD z32 # 14
    # ACC = 64
    STA z64 # 15
    ADD z64 # 16
    # ACC = 128
    STA z128 # 17
    NOR zAllOne # 18
    # ACC = 0
    ADD z128 # 19
    ADD z64 # 1a
    ADD zOne # 1b
    # ACC = c1, Jump to next slice
    LPS # 1c
Fail00:
    JCC Fail00 # 1d
    JCC Fail00 # 1e
    ___ # 1f
    )

set(basic0_slice1 # 3:040 (c1)
    # Test absolute jump
    JCC Success00 # 00
    JCC Success00 # 01
Fail00:
    JCC Fail00 # 02
    JCC Fail00 # 03
Success00:
    # Test conditional jump
    NOR zAllOne # 04
    ADD z128 # 05
    ADD z128 # 06
Fail01:
    JCC Fail01 # 07
    JCC Success01 # 08
Fail02:
    JCC Fail02 # 09
Fail03:
    JCC Fail03 # 0a
Success01:
    NOR zAllOne
    ADD z128 # 2:xxx Debug Adapter
    LDS
    SWD
    STA 3 # 2:003 Success
    SWS

    JCC Fail04
    JCC Fail04
    # Go to Slice c2
    NOR zAllOne
    ADD z128
    ADD z64
    ADD zTwo
    LPS

Fail04:
    JCC Fail04
    JCC Fail04
    )
