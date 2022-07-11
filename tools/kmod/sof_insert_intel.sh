#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2018 Intel Corporation. All rights reserved.

source lib.sh

# Modules parameters can be passed here as a quick and purely local
# hack.  Be conscious of unexpected interactions with "official"
# parameters located in /etc/modprobe.d/*.conf
#
# This is not required unless you want to change the default flags.
# For the list of flags search:   git -C linux grep SOF_DBG_
# Warning: the DMA trace can be forced ON in Kconfig and
# the SOF_DBG_ENABLE_TRACE bit ignored here.
# insert_module snd_sof sof_debug=1


# Insert codec drivers first, they are required to register ASoC components
insert_module snd_soc_da7213
insert_module snd_soc_da7219
insert_module snd_soc_pcm512x_i2c
insert_module snd_soc_wm8804_i2c

insert_module snd_soc_rt274
insert_module snd_soc_rt286
insert_module snd_soc_rt298

insert_module snd_soc_rt700
insert_module snd_soc_rt711
insert_module snd_soc_rt1308
insert_module snd_soc_rt1308_sdw
insert_module snd_soc_rt715
insert_module snd_soc_rt711_sdca
insert_module snd_soc_rt1316_sdw
insert_module snd_soc_rt715_sdca
insert_module snd_soc_sdw_mockup

insert_module snd_soc_rt1011
insert_module snd_soc_rt5640
insert_module snd_soc_rt5645
insert_module snd_soc_rt5651
insert_module snd_soc_rt5660
insert_module snd_soc_rt5670
insert_module snd_soc_rt5677
insert_module snd_soc_rt5677_spi
insert_module snd_soc_rt5682_i2c
insert_module snd_soc_rt5682_sdw

insert_module snd_soc_max98090
insert_module snd_soc_ts3a227e
insert_module snd_soc_max98357a
insert_module snd_soc_max98373_sdw
insert_module snd_soc_max98373_i2c
insert_module snd_soc_max98390

insert_module snd_soc_es8316
insert_module snd_soc_es8326

# insert top-level ACPI/PCI SOF drivers. They will register SOF components and
# load machine drivers as needed. Do not insert any other sort of audio module,
# code dependencies will be used to load the relevant modules.
insert_module snd_sof_acpi

insert_module snd_sof_acpi_intel_byt
insert_module snd_sof_acpi_intel_bdw

# Module parameters can be passed here as a quick and purely local hack.
# Be conscious of unexpected interactions with "official" parameters
# located in /etc/modprobe.d/*.conf
insert_module snd_sof_pci # ipc_type=1 # sof_pci_debug=1 ...

insert_module snd_sof_pci_intel_tng
insert_module snd_sof_pci_intel_skl
insert_module snd_sof_pci_intel_apl
insert_module snd_sof_pci_intel_cnl
insert_module snd_sof_pci_intel_icl
insert_module snd_sof_pci_intel_tgl
insert_module snd_sof_pci_intel_mtl

# USB
insert_module snd_usb_audio
