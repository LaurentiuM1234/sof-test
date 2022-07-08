#!/bin/bash -e
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2018 Intel Corporation. All rights reserved.

TOPDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

insert_module() {

    local MODULE="$1"; shift

    if modinfo "$MODULE" &> /dev/null ; then
        printf 'MODPROBE\t%s\t\t' "$MODULE"
        printf '%s ' "$@"
        printf '\n'
        # If sudo is slow, it's probably because the 'account' service
        # of the pam_unix.so module. Its version 1.5.1-7.fc34 tries to
        # close() all file descriptors from 65535 to 0.
        sudo modprobe "$MODULE" "$@"
    else
        printf 'SKIP    \t%s \t(not in tree)\n' "$MODULE"
    fi
}

remove_module() {

    local MODULE="$1"

    if grep -q "^${MODULE}[[:blank:]]" /proc/modules; then
        printf 'RMMOD\t%s\n' "$MODULE"
        sudo rmmod "$MODULE"
    else
        printf 'SKIP\t%s  \tnot loaded\n' "$MODULE"
    fi
}

exit_handler()
{
    local exit_status="$1"
    # Even without any active audio, pulseaudio can use modules
    # "non-deterministically". So even if we are successful this time,
    # warn about any running pulseaudio because it could make us fail
    # the next time.
    if pgrep -a pulseaudio; then
        systemctl_show_pulseaudio
    fi

    if test "$exit_status" -ne 0; then
        lsmod | grep -e sof -e snd -e sound -e drm
        # rmmod can fail silently, for instance when "Used by" is -1
        printf "%s FAILED\n" "$0"
    fi

    return "$exit_status"
}

# Always return 0 because if a lingering sof-logger is an error, it's
# not _our_ error.
kill_trace_users()
{
    local dma_trace=/sys/kernel/debug/sof/trace

    sudo fuser "$dma_trace" || return 0

    ( set -x
      sudo fuser --kill -TERM "$dma_trace" || true
      sudo fuser "$dma_trace" || return 0
      sleep 1
      sudo fuser --kill -KILL "$dma_trace" || true
    )
}
