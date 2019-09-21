# TENTATIVE: For simulation

cmake_minimum_required(VERSION 3.0)
project(nanocpu NONE)

set(WITH_XILINX f:/xilinx)
set(WITH_GHDL c:/prog/ghdl/0.36-mingw64-llvm/bin/ghdl)
set(WITH_GHDLDIR c:/prog/ghdl/0.36-mingw64-llvm)

set(XILINX_SIMPRIMS ${WITH_XILINX}/14.7/ISE_DS/ISE/vhdl/src/simprims)

include(../cmake/nanoasm.cmake)
include(../sw/globals.cmake)
include(../sw/spiloader.cmake)
include(../sw/init.cmake)

asm_pass1(globals scratch_globals)

# Bootloader / Firmware
asm_pass1(spiloader_slice0 spiloader_slice0)
asm_pass1(spiloader_slice1 spiloader_slice1)
asm_pass1(init_slice2 init_slice2)
asm_pass2(obj_loader_slice0 spiloader_slice0 spiloader_slice0)
asm_pass2(obj_loader_slice1 spiloader_slice1 spiloader_slice1)
asm_pass2(obj_loader_slice2 init_slice2 init_slice2)

function(genrom id)
    set(vars ${ARGN})
    set(cur 0)
    set(len)
    set(acc)
    foreach(v ${vars})
        foreach(b ${${v}})
            set(rom_${cur} ${b})
            math(EXPR cur "${cur}+1")
        endforeach()
    endforeach()
    set(len ${cur})
    set(cur 0)
    while(NOT cur EQUAL ${len})
        to_binary(data ${rom_${cur}})
        to_binary12(addr ${cur})
        set(acc "${acc}\n                when \"${addr}\" => data <= \"${data}\";")
        math(EXPR cur "${cur}+1")
    endwhile()
    set(ROMCONTENTS "${acc}")
    set(ROMIDENT ${id})
    configure_file(../mem_rom4k.vhd.in 
        ${CMAKE_CURRENT_LIST_DIR}/../gen/mem_rom4k_${id}.vhd @ONLY
        NEWLINE_STYLE LF)
endfunction()

function(genspirom id)
    set(ROMIDENT ${id})
    configure_file(../spi_rom4k.vhd.in
        ${CMAKE_CURRENT_LIST_DIR}/../gen/spi_rom4k_${id}.vhd @ONLY)
endfunction()

genrom(spiloader obj_loader_slice0 obj_loader_slice1 obj_loader_slice2)
genspirom(spiloader)


set(srcs
    gen/mem_rom4k_spiloader.vhd

    mem_ram8k.vhd
    test_aram.vhd
    spi_sr.vhd
    spi_dsr.vhd
    test_spi_ctr.vhd
    ioc_mbc.vhd
    ioc_boot.vhd
    ioc_spi.vhd
    nanocpu.vhd
    glue_async.vhd
    chip_single.vhd
    chip_asram.vhd
    test_da.vhd

    gen/spi_rom4k_spiloader.vhd
    #gen/top_timesim.vhd
    boards/cr2starter/glue.vhd

    tests/async_boot.vhd
    )

function(ghdl_analyze_all)
    set(ghdl ${WITH_GHDL})
    set(CMDS)
    set(srcs_fullpath)
    set(srcs ${ARGN})

    foreach(f ${srcs})
        set(pth ${CMAKE_CURRENT_SOURCE_DIR}/../${f})
        list(APPEND srcs_fullpath ${pth})
    endforeach()

    set(last_depend)
    foreach(f ${srcs})
        set(pth ${CMAKE_CURRENT_SOURCE_DIR}/../${f})
        string(REPLACE "/" "X" f_tgt ${f})
        add_custom_target(ghdl_analyze_${f_tgt} 
            COMMAND ${ghdl} -a 
            -P${WITH_GHDLDIR}/lib/ghdl/vendors/xilinx-ise
            ${pth}
            DEPENDS ${srcs_fullpath} ${last_depend}
            COMMENT "Analyze [${f}] with GHDL..."
            )
        set(last_depend ghdl_analyze_${f_tgt})
    endforeach()

    add_custom_target(ghdl_analyze_all ALL
        DEPENDS ${last_depend})
endfunction()

function(add_ghdl_run id)
    set(ghdl ${WITH_GHDL})
    add_custom_target(run-${id}
        COMMAND ${ghdl} -e ghdl_${id}
        COMMAND ${ghdl} -r -v ghdl_${id}
        --stop-time=2000us
        --fst=fst.out
        DEPENDS ghdl_analyze_all)
endfunction()

function(add_ghdl_run0 id)
    set(ghdl ${WITH_GHDL})
    add_custom_target(run-${id}
        COMMAND ${ghdl} -e -Wno-binding 
        -P${WITH_GHDLDIR}/lib/ghdl/vendors/xilinx-ise
        ${id}
        COMMAND ${ghdl} -r -v ${id}
        --stop-time=20000us
        #--stop-time=1800000ns
        --fst=fst.out
        DEPENDS ghdl_analyze_all)
endfunction()

ghdl_analyze_all(${srcs})

add_ghdl_run0(async_boot) # Takes a bit longer
