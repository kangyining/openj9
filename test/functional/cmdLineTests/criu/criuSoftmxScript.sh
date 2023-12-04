#!/bin/sh

#
# Copyright IBM Corp. and others 2022
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which accompanies this
# distribution and is available at https://www.eclipse.org/legal/epl-2.0/
# or the Apache License, Version 2.0 which accompanies this distribution and
# is available at https://www.apache.org/licenses/LICENSE-2.0.
#
# This Source Code may also be made available under the following
# Secondary Licenses when the conditions for such availability set
# forth in the Eclipse Public License, v. 2.0 are satisfied: GNU
# General Public License, version 2 with the GNU Classpath
# Exception [1] and GNU General Public License, version 2 with the
# OpenJDK Assembly Exception [2].
#
# [1] https://www.gnu.org/software/classpath/license.html
# [2] https://openjdk.org/legal/assembly-exception.html
#
# SPDX-License-Identifier: EPL-2.0 OR Apache-2.0 OR GPL-2.0-only WITH Classpath-exception-2.0 OR GPL-2.0-only WITH OpenJDK-assembly-exception-1.0
#

echo "start running script";
# the expected arguments are:
# $1 is the TEST_ROOT
# $2 is the JAVA_COMMAND
# $3 is the JVM_OPTIONS
# $4 is the MAINCLASS
# $5 is the APP ARGS
# $6 is the NUM_CHECKPOINT
# $7 is the KEEP_CHECKPOINT
# $8 is the KEEP_TEST_OUTPUT
# $9 is the dynamicHeapAdjustmentForRestore
# $10 is the Xmx
# $11 is the MaxRAMPercentage
# $12 is the Xms
# $13 is the Xsoftmx
echo "export GLIBC_TUNABLES=glibc.cpu.hwcaps=-XSAVEC,-XSAVE,-AVX2,-ERMS,-AVX,-AVX_Fast_Unaligned_Load";
export GLIBC_TUNABLES=glibc.pthread.rseq=0:glibc.cpu.hwcaps=-XSAVEC,-XSAVE,-AVX2,-ERMS,-AVX,-AVX_Fast_Unaligned_Load
echo "export LD_BIND_NOT=on";
export LD_BIND_NOT=on

MEMORY=$(grep MemTotal /proc/meminfo | awk '{print $2}')
echo $MEMORY
XDynamicHeapAdjustment=""
if [ "$9" == true ]; then
    XDynamicHeapAdjustment="-XX:+dynamicHeapAdjustmentForRestore"
fi

Xmx=""
if [ "${10}" == true ]; then
    Xmx="-Xmx$((MEMORY/2))k"
fi

MaxRAMPercentage=""
if [ "${11}" == true ]; then
    MaxRAMPercentage="-XX:MaxRAMPercentage=50"
fi

Xms=""
if [ "${12}" == true ]; then
    Xms="-Xms$((MEMORY/8))k"
fi

Xsoftmx=""
if [ "${13}" == true ]; then
    Xsoftmx="-Xsoftmx$((MEMORY/8))k"
fi
echo $Xmx
echo $MaxRAMPercentage
echo $Xms
echo $Xsoftmx
echo "HERE"
echo "$2 -XX:+EnableCRIUSupport -verbose:gc $XDynamicHeapAdjustment $Xmx $MaxRAMPercentage $Xms $Xsoftmx $3 -cp "$1/criu.jar" $4 $5 $6 >testOutput 2>&1;"
$2 -XX:+EnableCRIUSupport -verbose:gc $XDynamicHeapAdjustment $Xmx $MaxRAMPercentage $Xms $Xsoftmx $3 -cp "$1/criu.jar" $4 $5 $6 >testOutput 2>&1;
cat testOutput criuOutput;
echo "finish"

if [ "$7" != true ]; then
    NUM_CHECKPOINT=$6
    for ((i=0; i<$NUM_CHECKPOINT; i++)); do
        sleep 2;
        criu restore -D ./cpData --shell-job >criuOutput 2>&1;
    done
fi


if  [ "$7" != true ]; then
    if [ "$8" != true ]; then
        rm -rf testOutput criuOutput
        echo "Removed test output files"
    fi
fi
echo "finished script";
