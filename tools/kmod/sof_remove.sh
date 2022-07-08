#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2018 Intel Corporation. All rights reserved.

source "$TOPDIR"/tools/kmod/lib.sh

trap 'exit_handler $?' EXIT

# Breaks systemctl --user and "double sudo" is not great
test "$(id -u)" -ne 0 ||
    >&2 printf '\nWARNING: running as root is not supported\n\n'

# Make sure sudo works first, not after dozens of SKIP
sudo true

# For some reason (bug?) using /sys/kernel/debug/sof/trace hangs rmmod
# Playing audio is not an issue, for instance speaker-test -s 1 -l 0 is
# interrupted when unloading the drivers.
kill_trace_users

# SOF CI has a dependency on usb audio
remove_module snd_usb_audio

#-------------------------------------------
# Top level devices
# ACPI is after PCI due to TNG dependencies
#-------------------------------------------
remove_module snd_hda_intel
remove_module snd_sof_pci_intel_tng
remove_module snd_sof_pci_intel_skl
remove_module snd_sof_pci_intel_apl
remove_module snd_sof_pci_intel_cnl
remove_module snd_sof_pci_intel_icl
remove_module snd_sof_pci_intel_tgl
remove_module snd_sof_pci_intel_mtl
remove_module snd_sof_acpi_intel_byt
remove_module snd_sof_acpi_intel_bdw

#--------------------------------------------------
# With older kernels this is in use by snd_sof_pci,
# see https://github.com/thesofproject/linux/pull/2683
#--------------------------------------------------
remove_module snd_sof_intel_hda_common || true

#-------------------------------------------
# Helpers
#-------------------------------------------
remove_module snd_sof_acpi
remove_module snd_sof_pci
remove_module snd_sof_intel_atom

#-------------------------------------------
# legacy drivers (not used but loaded)
#-------------------------------------------
remove_module snd_soc_catpt
remove_module snd_intel_sst_acpi
remove_module snd_intel_sst_core
remove_module snd_soc_sst_atom_hifi2_platform
remove_module snd_soc_skl

#------------------------------------------------------
# obsolete platform drivers - kept to avoid breaking CI
#------------------------------------------------------
remove_module snd_sof_intel_byt
remove_module snd_sof_intel_bdw

#-------------------------------------------
# platform drivers
#-------------------------------------------
remove_module snd_sof_intel_hda_common
remove_module snd_sof_intel_hda
remove_module snd_sof_intel_ipc
remove_module snd_sof_xtensa_dsp
remove_module snd_soc_acpi_intel_match

#-------------------------------------------
# Machine drivers
#-------------------------------------------
remove_module snd_soc_sof_rt5682
remove_module snd_soc_sof_da7219_max98373
remove_module snd_soc_sst_bdw_rt5677_mach
remove_module snd_soc_sst_broadwell
remove_module snd_soc_sst_bxt_da7219_max98357a
remove_module snd_soc_sst_sof_pcm512x
remove_module snd_soc_sst_bxt_rt298
remove_module snd_soc_sst_sof_wm8804
remove_module snd_soc_sst_byt_cht_da7213
remove_module snd_soc_sst_byt_cht_es8316
remove_module snd_soc_sst_bytcr_rt5640
remove_module snd_soc_sst_bytcr_rt5651
remove_module snd_soc_sst_cht_bsw_max98090_ti
remove_module snd_soc_sst_cht_bsw_nau8824
remove_module snd_soc_sst_cht_bsw_rt5645
remove_module snd_soc_sst_cht_bsw_rt5672
remove_module snd_soc_sst_glk_rt5682_max98357a
remove_module snd_soc_cml_rt1011_rt5682
remove_module snd_soc_skl_hda_dsp
remove_module snd_soc_sdw_rt700
remove_module snd_soc_sdw_rt711_rt1308_rt715
remove_module snd_soc_sof_sdw
remove_module snd_soc_sof_es8336
remove_module snd_soc_ehl_rt5660
remove_module snd_soc_intel_hda_dsp_common
remove_module snd_soc_intel_sof_maxim_common
remove_module snd_soc_intel_sof_realtek_common

#-------------------------------------------
# SOF client drivers
#-------------------------------------------
remove_module snd_sof_probes
remove_module snd_sof_ipc_test
remove_module snd_sof_ipc_flood_test
remove_module snd_sof_ipc_msg_injector
remove_module snd_sof_dma_trace

# snd_sof_nocodec dependencies re-ordered
# in https://github.com/thesofproject/linux/pull/2800
# TODO: remove || true and the duplicate below
# when we stop testing old branches.
remove_module snd_sof_nocodec || true

remove_module snd_sof
remove_module snd_sof_nocodec
remove_module snd_sof_utils

#-------------------------------------------
# Codec drivers
#-------------------------------------------
remove_module snd_soc_da7213
remove_module snd_soc_da7219
remove_module snd_soc_pcm512x_i2c
remove_module snd_soc_pcm512x

remove_module snd_soc_rt274
remove_module snd_soc_rt286
remove_module snd_soc_rt298
remove_module snd_soc_rt700
remove_module snd_soc_rt711
remove_module snd_soc_rt1308
remove_module snd_soc_rt1308_sdw
remove_module snd_soc_rt715
remove_module snd_soc_rt711_sdca
remove_module snd_soc_rt1316_sdw
remove_module snd_soc_rt715_sdca
remove_module snd_soc_sdw_mockup
remove_module snd_soc_rt1011
remove_module snd_soc_rt5640
remove_module snd_soc_rt5645
remove_module snd_soc_rt5651
remove_module snd_soc_rt5660
remove_module snd_soc_rt5670
remove_module snd_soc_rt5677
remove_module snd_soc_rt5677_spi
remove_module snd_soc_rt5682_sdw
remove_module snd_soc_rt5682_i2c
remove_module snd_soc_rt5682
remove_module snd_soc_rt5682s
remove_module snd_soc_rl6231
remove_module snd_soc_rl6347a

remove_module snd_soc_wm8804_i2c
remove_module snd_soc_wm8804

remove_module snd_soc_es8316
remove_module snd_soc_es8326

remove_module snd_soc_max98090
remove_module snd_soc_ts3a227e
remove_module snd_soc_max98357a
remove_module snd_soc_max98373_sdw
remove_module snd_soc_max98373_i2c
remove_module snd_soc_max98373
remove_module snd_soc_max98390

remove_module snd_soc_hdac_hda
remove_module snd_soc_hdac_hdmi
remove_module snd_hda_codec_hdmi
remove_module snd_soc_dmic

remove_module snd_hda_codec_realtek
remove_module snd_hda_codec_generic

#-------------------------------------------
# Remaining core SOF parts
#-------------------------------------------
remove_module snd_soc_acpi
remove_module snd_hda_ext_core

remove_module snd_intel_dspcfg

remove_module soundwire_intel_init
remove_module soundwire_intel
remove_module soundwire_cadence
remove_module soundwire_generic_allocation
remove_module regmap_sdw
remove_module regmap_sdw_mbq
remove_module soundwire_bus
remove_module snd_intel_sdw_acpi

remove_module snd_soc_core
remove_module snd_hda_codec
remove_module snd_hda_core
remove_module snd_hwdep
remove_module snd_compress
remove_module snd_pcm_dmaengine
remove_module snd_pcm

