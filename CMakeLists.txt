cmake_minimum_required(VERSION 3.0)
project(nanocpu NONE)

set(WITH_GHDL c:/prog/ghdl/0.36-mingw64-llvm/bin/ghdl)

include(./cmake/nanoasm.cmake)
include(./sw/globals.cmake)
include(./sw/spiloader.cmake)
include(./tests/sw/basic0.cmake)

asm_pass1(globals scratch_globals)

# Bootloader / Firmware
asm_pass1(spiloader_slice0 spiloader_slice0)
asm_pass1(spiloader_slice1 spiloader_slice1)
asm_pass2(obj_loader_slice0 spiloader_slice0 spiloader_slice0)
asm_pass2(obj_loader_slice1 spiloader_slice1 spiloader_slice1)

# Tests
asm_pass1(basic0_slice0 basic0_slice0)
asm_pass1(basic0_slice1 basic0_slice1)

asm_pass2(out_basic0_slice0 basic0_slice0 basic0_slice0)
asm_pass2(out_basic0_slice1 basic0_slice1 basic0_slice1)

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
    configure_file(mem_rom4k.vhd.in 
        ${CMAKE_CURRENT_LIST_DIR}/gen/mem_rom4k_${id}.vhd @ONLY
        NEWLINE_STYLE LF)
endfunction()

function(gentest_plain id)
    set(ROMIDENT ${id})
    configure_file(test_chip_plain.vhd.in
        ${CMAKE_CURRENT_LIST_DIR}/gen/test_chip_plain_${id}.vhd @ONLY)
endfunction()

genrom(basic0 out_basic0_slice0 out_basic0_slice1)
gentest_plain(basic0)

set(srcs_gen_roms
    gen/mem_rom4k_basic0.vhd)
set(srcs_gen_tests
    gen/test_chip_plain_basic0.vhd)

set(srcs_base # ordered
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
    )

set(srcs_tests
    tests/ghdl_basic0.vhd
    )

function(ghdl_analyze_all)
    set(ghdl ${WITH_GHDL})
    set(CMDS)
    set(srcs_fullpath)
    set(srcs ${ARGN})

    foreach(f ${srcs})
        set(pth ${CMAKE_CURRENT_SOURCE_DIR}/${f})
        list(APPEND srcs_fullpath ${pth})
    endforeach()

    set(last_depend)
    foreach(f ${srcs})
        set(pth ${CMAKE_CURRENT_SOURCE_DIR}/${f})
        string(REPLACE "/" "X" f_tgt ${f})
        add_custom_target(ghdl_analyze_${f_tgt} 
            COMMAND ${ghdl} -a ${pth}
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
        --stop-time=20000ns
        --fst=fst.out
        DEPENDS ghdl_analyze_all)
endfunction()

ghdl_analyze_all(
    ${srcs_gen_roms}
    ${srcs_base}
    ${srcs_gen_tests}
    ${srcs_tests})

add_ghdl_run(basic0)

