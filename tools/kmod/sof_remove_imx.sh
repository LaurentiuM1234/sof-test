#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2018 Intel Corporation. All rights reserved.
# Copyright 2022 NXP

source lib.sh

# i.MX specific drivers
remove_module snd_sof_imx8
remove_module snd_sof_imx8m


# i.MX helper drivers
remove_module imx_common
remove_module snd_sof_xtensa_dsp

# OF driver
remove_module snd_sof_of

# Core driver
remove_module snd_sof

# Codecs
remove_module snd_soc_wm8960
