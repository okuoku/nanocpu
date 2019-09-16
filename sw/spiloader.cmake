set(spiloader_slice0
    SWS # 00
    NOR sAllOne # 01
    ADD sBootFlag # 02
    ADD sAllOne # 03
    JCC xNext # 04

    # Switch to ram on first boot
    NOR sAllOne # 05
    STA sBootFlag # 06
    LPS # 07

    # Process a byte
xNext:
    NOR sAllOne # 08
    ADD sCmdOff # 09
    ADD sAllOne # 0a
    JCC xFirstCommand # 0b
xSendSpi:
    # SPI Read
    NOR sAllOne # 0c
    ADD s128 # 0d 128 = Rgn02 = SPI register
    LDS # 0e
    NOR sAllOne # 0f
    ADD sSendBuf # 10
    SWD #11 
    STA 0 # 12 SPI Write
    SWS # 13
xWaitLoop:
    NOR sAllOne # 14
    ADD sActivityMask # 15
    SWD # 16
    NOR 1 # 17 SPI Status Register
    SWS # 18
    ADD sAllOne # 19
    JCC xWaitLoop # 1a

    # Read Done
    NOR sAllOne # 1b
    ADD sCmdOff # 1c
    NOR sZero # 1d
    ADD sFour # 1e
    ADD sOne # 1f
    ADD sAllOne # 20
    JCC xCopyByte # 21
    
    # Next Byte
    NOR sAllOne # 22
    ADD sCmdOff # 23
    ADD sOne # 24
    STA sCmdOff # 25 CmdOff++
    ADD s64 # 26 # Make ADD [sCmdOff + xCmd0]
    ADD xCmd0 # 27
    STA xFetchBuf # 28
xFirstCommand:
    NOR sAllOne # 29
xFetchBuf:
    ADD xCmd0 # 2a
    STA sSendBuf # 2b
    JCC xSendSpi # 2c
xCopyByte:
    NOR sAllOne # 2d
    ADD sOne # 2e
    LPS # 2f


sSendBuf:
    _IMM 0 # 30
xCmd0:
    _IMM 3 # 31 # Read
xCmd1:
    _IMM 128 # 32 # Offs0
xCmd2:
    _IMM 0 # 33 # Offs1
xCmd3:
    _IMM 0 # 34 # Offs2

sActivityMask: # 254 to Mask activity
    _IMM 254 # 35
sCmdOff:
    _IMM 0 # 36
sCurrentSlice:
    _IMM 3 # 37
sByteOff:
    _IMM 0 # 38
sSliceEnd:
    _IMM 0 # 39
sBootFlag:
sZero:
    _IMM 144 # 3a # To indicate boot
s128:
    _IMM 128 # 3b
s64:
    _IMM 64 # 3c
sFour:
    _IMM 4 # 3d
sOne:
    _IMM 1 # 3e
sAllOne:
    _IMM 255 # 3f
    )

set(spiloader_slice1
    _DEF sSendBuf 48
    _DEF sCurrentSlice 55
    _DEF sByteOff 56
    _DEF sSliceEnd 57
    _DEF sZero 58
    _DEF s128 59
    _DEF s64 60
    _DEF sFour 61
    _DEF sOne 62
    _DEF sAllOne 63

    NOR sAllOne # 00
    ADD s128 # 01
    LDS # 02
    NOR sAllOne # 03
    SWD # 04
    ADD 0 # 05
    SWS # 06
    STA sSendBuf # 07

    # Copy a byte
    NOR sAllOne # 08
    ADD sCurrentSlice # 09
    LDS # 0a Select Current slice

    NOR sAllOne # 0b
    ADD sSendBuf # 0c
    SWD # 0d

xCopyByte:
    STA 0 # 0e
    SWS # 0f

    # Select my slice
    NOR sAllOne # 10
    ADD sOne # 11
    LDS # 12 Select my page

    # ByteOff++
    NOR sAllOne # 13
    ADD sByteOff # 14
    ADD sOne # 15
    STA sByteOff # 16
    # ByteOff == 64?
    NOR sZero # 17
    ADD s64 # 18
    ADD sOne # 19
    ADD sAllOne # 1a
    JCC xNextSlice # 1b

    # Update CopyByte
    NOR sAllOne # 1c
    ADD sByteOff # 1d 
    ADD s128 # 1e Make STA [sByteOff]
    SWD # 1f

    STA xCopyByte # 20
    SWS # 21
    # Jump back to slice0
    NOR sAllOne # 22
    LPS # 23

xNextSlice:
    NOR sAllOne # 24
    STA sByteOff # 25
    ADD s128 # 26
    SWD # 27
    STA xCopyByte # 28
    SWS # 29
    NOR sAllOne # 2a
    ADD sCurrentSlice # 2b
    ADD sOne # 2c
    STA sCurrentSlice # 2d
    NOR sZero # 2e
    ADD sSliceEnd # 2f
    ADD sOne # 30
    ADD sAllOne # 31
    JCC xFinish # 32
    NOR sAllOne # 33
    LPS # 34

xFinish:
    # Jump to slice 2 
    NOR sAllOne # 35
    ADD sOne # 36
    ADD sOne # 37
    LPS # 38
    ___ # 39
    ___ # 3a
    ___ # 3b
    ___ # 3c
    ___ # 3d
    ___ # 3e
    ___ # 3f
    )
