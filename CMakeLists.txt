cmake_minimum_required(VERSION 3.0)
project(nanocpu NONE)

set(WITH_GHDL c:/prog/ghdl/0.36-mingw64-llvm/bin/ghdl)

set(srcs_base # ordered
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
    )

set(srcs_gen)

set(srcs_tests
    tests/test_chip.vhd
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

ghdl_analyze_all(
    ${srcs_base}
    ${srcs_tests})


