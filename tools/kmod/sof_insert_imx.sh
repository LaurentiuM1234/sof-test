#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2018 Intel Corporation. All rights reserved.
# Copyright 2022 NXP.

source lib.sh

# Insert codec drivers
insert_module snd_soc_wm8960

# Insert core driver
insert_module snd_sof

# Insert OF driver
insert_module snd_sof_of

# Insert helper drivers
insert_module imx_common
insert_module snd_sof_xtensa_dsp

# Insert i.MX specific drivers
insert_module snd_sof_imx8
insert_module snd_sof_imx8m
