#!/bin/bash

set -e

##
## Case Name: check-keyword-detection
## Preconditions:
##    N/A
## Description:
##    trigger the wov by playing a special sine wav(997 Hz sine wav) which generate by wav tool
##    and then use wavtool to do the analysis
## Case step:
##    1. use wavtool to generate the test wav file.
##    2. play the sine wav on USB sound card
##    3. run kwd and waitting to be triggered.
##    3. after the test, use wavetool to analyze the recorded wav.
## Expect result:
##    no errors and the captured data should match with the orignal one
##

libdir=$(dirname "${BASH_SOURCE[0]}")
# shellcheck source=case-lib/lib.sh
source "$libdir"/../case-lib/lib.sh

OPT_NAME['t']='tplg'              OPT_DESC['t']='tplg file, default value is env TPLG: $''TPLG'
OPT_HAS_ARG['t']=1                  OPT_VAL['t']="$TPLG"

OPT_NAME['s']='sof-logger'        OPT_DESC['s']="Open sof-logger trace the data will store at $LOG_ROOT"
OPT_HAS_ARG['s']=0                  OPT_VAL['s']=1

OPT_NAME['p']='preamble-time'     OPT_DESC['p']='key phrase preamble length'
OPT_HAS_ARG['p']=1                  OPT_VAL['p']=2100

OPT_NAME['s']='history-depth'     OPT_DESC['s']='draining size'
OPT_HAS_ARG['s']=1                  OPT_VAL['s']=2100

OPT_NAME['b']='buffer'            OPT_DESC['b']='buffer size'
OPT_HAS_ARG['b']=1                  OPT_VAL['b']=67200

OPT_NAME['l']='loop'              OPT_DESC['l']='loop count'
OPT_HAS_ARG['l']=1                  OPT_VAL['l']=1

OPT_NAME['d']='duration'          OPT_DESC['d']='interrupt kwd pipeline in # seconds'
OPT_HAS_ARG['d']=1                  OPT_VAL['d']=10

func_opt_parse_option "$@"
setup_kernel_check_point

tplg=${OPT_VAL['t']}
loop_cnt=${OPT_VAL['l']}
buffer_size=${OPT_VAL['b']}
history_depth=${OPT_VAL['s']}
preamble_time=${OPT_VAL['p']}
duration=${OPT_VAL['d']}

logger_disabled || func_lib_start_log_collect

func_pipeline_export "$tplg" "kpbm:any"

if test "$PIPELINE_COUNT" != "1"; then
    die "detected $PIPELINE_COUNT wov pipeline(s) from topology, but 1 is needed"
fi

# parser the parameters of the wov pipeline
channel=$(func_pipeline_parse_value 0 ch_max)
rate=$(func_pipeline_parse_value 0 rate)
dev=$(func_pipeline_parse_value 0 dev)
fmts=$(func_pipeline_parse_value 0 fmts)

test_dir="/tmp"
def_blob="$test_dir"/detertor_default_config.blob

# get wov kcontrol ID
wov_kctl_id=$(amixer -c "$SOFCARD" controls |grep "Detector" |awk -F= '{print $2}' |cut -d"," -f1)

# get wov PGA volume kcontrol name
wov_kctl_pga=$(amixer -c "$SOFCARD" controls |grep "KWD Capture Volume" |awk -F= '{print $4}')

# adjust wov PGA volume
amixer -c "$SOFCARD" cset name="$wov_kctl_pga" 40

# store the default config blob
_store_default_wov_config_bolb()
{
    if [ ! -f "$def_blob" ]; then
        sof-ctl -Dhw:"$SOFCARD" -n "$wov_kctl_id" -r -o "$def_blob"
        dlogi "default blob:"
        cat "$def_blob"
    fi
}

# get default preamble time and history depth
_get_default_pt_hd()
{
    def_pt=$(awk -F "," '{print $4}' < "$def_blob")
    def_hd=$(awk -F "," '{print $7}' < "$def_blob")
}
# restore the default config blob
_restore_default_wov_config_bolb()
{
    if [ -f "$def_blob" ]; then
        sof-ctl -Dhw:"$SOFCARD" -n "$wov_kctl_id" -r -s "$def_blob"
    fi
}

# update the blob
_update_blob(){
    new_blob=$test_dir"/new_blob"
    [ $preamble_time -ge $history_depth ] || {
        die "Warning: invalid arguments, preamble_time must be greater than or equal to history_depth"
    }
    awk -F, -v OFS=, '{if ( $4 == '"$def_pt"' && $7 == '"$def_hd"' ) $4='"$preamble_time"'; $7='"$history_depth"'}1' \
        "$def_blob" > "$new_blob"
    dlogi "kwd config blob is updated to:"
    cat "$new_blob"
    dlogi "write back the new kwd config blob"
    sof-ctl -Dhw:"$SOFCARD" -n "$wov_kctl_id" -r -s "$new_blob" >> /dev/null || die "Failed to write back the new kwd config bolb"
}

for i in $(seq 1 "$loop_cnt")
do
    for fmt in $fmts
    do
        if [ "$fmt" == "S24_LE" ]; then
            dlogi "S24_LE is not supported, skip to test this format"
            continue
        fi
        test_file="$test_dir"/wov_"${fmt%_*}"_test.wav
        recorded_file="$test_dir"/wov_"${fmt%_*}"_record.wav
        _store_default_wov_config_bolb || die "Failed to dump KWD config blob "
        _get_default_pt_hd || die "Failed to get the default preamble_time and history_depth"
        _update_blob || die "Failed to update the KWD config blob"
        # generate the wav files for test
        wavetool.py -g wov -A 0.25 1. -D 4. 6. -B "${fmt%_*}" -o "$test_file"

        # play the testing wav first
        dlogc "aplay -Dplughw:1,0 $test_file"
        aplay -Dplughw:1,0 "$test_file" & aplayPID=$!
        dlogi "Testing: iteration $i with $fmt format"

        # run keyword detection
        dlogc "arecord -D$dev -M -N -r $rate -c $channel -f $fmt --buffer-size=$buffer_size -d $duration $recorded_file"
        arecord -D"$dev" -M -N -r "$rate" -c "$channel" -f "$fmt" --buffer-size="$buffer_size" -d "$duration" "$recorded_file" -vvv

        # analyze the recorded wav file
        wavetool.py -a "wov" -R "$recorded_file" || {
            # upload the failed wav file
            find /tmp -maxdepth 1 -type f -name "wov_*_record.wav" -size +0 -exec cp {} "$LOG_ROOT/" \;
            exit 1
        }

        timeout 5 tail --pid=$aplayPID -f /dev/null || die "Failed to stop playback"
        _restore_default_wov_config_bolb || die "Failed to restore kwd config blob"
    done
done

sof-kernel-log-check.sh "$KERNEL_CHECKPOINT"
