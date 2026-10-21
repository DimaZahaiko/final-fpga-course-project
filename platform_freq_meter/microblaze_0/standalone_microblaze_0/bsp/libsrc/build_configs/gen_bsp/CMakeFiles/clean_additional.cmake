# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "")
  file(REMOVE_RECURSE
  "D:\\FPGA_homeworks_12plus\\the_last_homework\\platform_freq_meter\\microblaze_0\\standalone_microblaze_0\\bsp\\include\\sleep.h"
  "D:\\FPGA_homeworks_12plus\\the_last_homework\\platform_freq_meter\\microblaze_0\\standalone_microblaze_0\\bsp\\include\\xiltimer.h"
  "D:\\FPGA_homeworks_12plus\\the_last_homework\\platform_freq_meter\\microblaze_0\\standalone_microblaze_0\\bsp\\include\\xtimer_config.h"
  "D:\\FPGA_homeworks_12plus\\the_last_homework\\platform_freq_meter\\microblaze_0\\standalone_microblaze_0\\bsp\\lib\\libxiltimer.a"
  )
endif()
