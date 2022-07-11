#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2018 Intel Corporation. All rights reserved.

source lib.sh

setup()
{
    # Make sure sudo works first, not after dozens of SKIP
    sudo true
}

main()
{
    # set platform variable which will be used to identify the appropriate
    # module insertion script
    local platform="$1"

    # do setup before calling the insertion script
    setup

    # insert platform-specific modules
    "$TOPDIR"/tools/kmod/sof_insert_"$platform".sh || return $?
}

main "$@"
