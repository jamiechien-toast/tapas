#!/bin/bash


TOOL_VERSION="1.0.1"
KEYWORD=("ILITEK Driver probe failed" "i2c_geni a94000.i2c: GSI QC err")
CURR=`pwd`

echo "==============================="
if [ $# -gt 0 ]; then
    if [ $(adb devices | grep $1 | wc -l) -gt 0 ]; then
        echo "Target device $1 connected"
        TARGET="-s $1"
        test -d $CURR/$1 || mkdir -p $CURR/$1
    else
        echo "[ERROR] Target device $1 not connected!!!"
        exit
    fi
fi
adb $TARGET wait-for-device
echo "==============================="
cd $CURR/$d
run=0
error_cnt=0
while [ $error_cnt -eq 0 ]; do
    echo "RUN-$run"
    adb $TARGET reboot
    adb $TARGET wait-for-device
    sleep 3
    adb $TARGET bugreport
    LAST_BUGREP=`ls -A1 . | grep bugreport | sort -r | head -1`
    unzip -oq $LAST_BUGREP "${LAST_BUGREP%.*}.txt"
    for (( k=0; k<${#KEYWORD[@]}; k++ )); do
        echo "    grep keyword-$k"
        error_cnt=`grep "${KEYWORD[$k]}" "${LAST_BUGREP%.*}.txt" | wc -l`
        if [ $error_cnt -gt 0 ]; then
            echo "Got you evil one! (${KEYWORD[$k]})"
            echo "Rename evil bugreport..."
            mv $LAST_BUGREP I_FOUND_THE_EVIL.zip
            exit
        fi
    done
    run=$(($run+1))
    if [ $(($run%100)) -eq 0 ]; then
        rm bugreport-*.zip
        rm bugreport-*.txt
    fi
    sleep 10
done
cd $CURR

