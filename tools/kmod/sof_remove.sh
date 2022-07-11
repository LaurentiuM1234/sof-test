#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2018 Intel Corporation. All rights reserved.

source lib.sh

setup()
{
    trap 'exit_handler $?' EXIT

    # Breaks systemctl --user and "double sudo" is not great
    test "$(id -u)" -ne 0 ||
        >&2 printf '\nWARNING: running as root is not supported\n\n'

    # Make sure sudo works first, not after dozens of SKIP
    sudo true

    # For some reason (bug?) using /sys/kernel/debug/sof/trace hangs rmmod
    # Playing audio is not an issue, for instance speaker-test -s 1 -l 0 is
    # interrupted when unloading the drivers
    kill_trace_users
}

main()
{
    # set platform variable which will be used to identify the appropriate
    # module removal script
    local platform="$1"

    # do setup before calling the removal script
    setup

    # remove platform-specific modules
    "$TOPDIR"/tools/kmod/sof_remove_"$platform".sh || return $?
}

main "$@"
