# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "device",
    hdrs = ["device.h"],
)

cc_library(
    name = "fpga_nexysvideo",
    srcs = ["device_fpga_nexysvideo.c"],
    deps = [":device"],
)

cc_library(
    name = "fpga_cw310",
    srcs = ["device_fpga_cw310.c"],
    deps = [":device"],
)

cc_library(
    name = "sim_dv",
    srcs = ["device_sim_dv.c"],
    deps = [":device"],
)

cc_library(
    name = "sim_verilator",
    srcs = ["device_sim_verilator.c"],
    deps = [":device"],
)
