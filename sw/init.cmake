# Tentative init routine
set(init_slice2
    # ACC = 2 (My Slice number)
    LDS # 00
    SWD # 01
    NOR xAllOne # 03
    # ACC = 0
    SWS # 04
    STA zZero # 05
    NOR zZero # 06
    # ACC = AllOne
    STA zAllOne # 07
    ADD zAllOne # 08
    # ACC = 254
    STA zOne # 09
    NOR zOne # 0a
    # ACC = 1
    STA zOne # 0b
    ADD zOne # 0c
    # ACC = 2
    STA zTwo # 0d
    ADD zOne # 0e
    # ACC = 3
    STA zThree # 0f
    ADD zOne # 10
    # ACC = 4
    STA zFour # 11
    ADD zFour # 12
    # ACC = 8
    STA z8 # 13
    ADD z8 # 14
    # ACC = 16
    STA z16 # 15
    ADD z16 # 16
    # ACC = 32
    STA z32 # 17
    ADD z32 # 18
    # ACC = 64
    STA z64 # 19
    ADD z64 # 1a
    # ACC = 128
    STA z128 # 1b
    NOR zAllOne # 1c
    # ACC = 0

    # Disable SPI
    ADD z128
    LDS # Select rgn2
    NOR zAllOne
    SWD
    STA 1
    SWS

    # Map DA to rgn2
    ADD z128
    ADD z64
    LDS # Select rgn3
    NOR zAllOne
    ADD z128
    SWD
    STA 1 # Configure rgn2
    SWS

    # Success
    NOR zAllOne
    ADD z128 # 1f 0x80 = 2:xxx Debug Adapter
    LDS # 20
    SWD # 21
    STA 3 # 22 2:003 Success
    SWS
xTerm:
    JCC xTerm # 23
    JCC xTerm # 24
xAllOne:
    _IMM 255
xEnd_slice2:
)
