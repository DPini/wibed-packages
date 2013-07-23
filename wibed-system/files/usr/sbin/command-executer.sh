#!/bin/bash

RESULTS_DIR="/var/wibed/results"

COMMANDS_PIPE="/var/wibed/pipes/commands"

trap "rm -f $COMMANDS_PIPE" EXIT

# Start command executer
if [[ ! -p $COMMANDS_PIPE ]]; then
    mkdir -p "$(dirname $COMMANDS_PIPE)"
    mkfifo $COMMANDS_PIPE
fi

if [[ ! -e $RESULTS_DIR ]]; then
    mkdir $RESULTS_DIR
fi

#while read commandId commandStr
while true
do
    if read commandId commandStr < $COMMANDS_PIPE; then
        if [[ -z $commandId || -z $commandStr ]] ; then
            continue
        fi

        echo "Command ID: $commandId"
        echo "Command Str: $commandStr"

        # Exit signal
        if [ $commandId -lt 0 ] ; then
            echo "Found exit signal"
            break
        fi

        commandDir="$RESULTS_DIR/$commandId"

        if [[ ! -d $commandDir ]] ; then
            mkdir "$commandDir"
        fi

        stdoutFile="$commandDir/stdout"
        stderrFile="$commandDir/stderr"
        exitCodeFile="$commandDir/exitCode"

        { eval $commandStr ; } 1>$stdoutFile 2>$stderrFile

        exitCode=$?
        echo $exitCode > $exitCodeFile
    fi
#done < $COMMANDS_PIPE
done

echo "Command executer exiting"
