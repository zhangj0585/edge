#!/bin/bash
##
# @file This file is part of EDGE.
#
# @author Alexander Breuer (anbreuer AT ucsd.edu)
#
# @section LICENSE
# Copyright (c) 2017, Regents of the University of California
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# @section DESCRIPTION
# Calls TF-MISFIT_GOF_CRITERIA to produce goodness-of-fit criteria.
##
# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-r RECEIVER1 -s RECEIVER2 -x EXTQ1 -y EXTQ2 -c EXTC1 -d EXTC2 -n EXTS1 -m EXTS2 -o OUTDIR]
Calls TF-MISFIT_GOF_CRITERIA to produce goodness-of-fit criteria.
     -h This help message.
     -r RECEIVER1 first seismogram.
     -s RECEIVER2 second seismogram, used as reference solution.
     -x EXTQ1 component to extract from first receiver (optional).
     -y EXTQ2 component to extract from second receiver (optional).
     -c EXTC1 fused simulation to extract from first receiver (optional).
     -d EXTC2 fused simulation to extract from second receiver (optional).
     -n EXTS1 sampling of first receiver (optional).
     -m EXTS2 sampling of second receiver (optional).
     -o OUTDIR output directory.
EOF
}

#
# parse command line arguments
#
OPTIND=1
while getopts "hr:s:x:y:c:d:n:m:o:" opt; do
  case "$opt" in
    h)
       show_help
       exit 0
       ;;
    r)
       RECEIVER1=$OPTARG
       ;;
    s)
       RECEIVER2=$OPTARG
       ;;
    x)
       EXTQ1=$OPTARG
       ;;
    y)
       EXTQ2=$OPTARG
       ;;
    c)
       EXTC1=$OPTARG
       ;;
    d)
       EXTC2=$OPTARG
       ;;
    n)
       EXTS1=$OPTARG
       ;;
    m)
       EXTS2=$OPTARG
       ;;
    o)
       OUT_DIR=$OPTARG
       ;;
    '?')
       show_help >&2
       exit 1
       ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

if [[ $OPTIND != 7 ]] && [[ $OPTIND != 13 ]] && [[ $OPTIND != 19 ]]
then
  show_help >&2
  exit 1
fi

# print info on the run
echo "$(date) running tf_misfit_gof, stay tuned.."
echo "$(date) arguments:"
echo "$(date)   receiver 1: ${RECEIVER1}"
echo "$(date)   receiver 2 (used as reference): ${RECEIVER2}"

# save current dir
CUR_DIR=$(pwd)

# create output directory
TMP_DIR=$(mktemp -d)

# extract components if required
if [[ $EXTQ1 != '' ]]
then
  EXT_DIR=$(mktemp -d)

  # extract
  cp $RECEIVER1 $EXT_DIR
  cd $EXT_DIR
  recvs_csv_to_plain.r . $EXTS1 1

  # move extracted receiver
  mv *_Q${EXTQ1}_C${EXTC1}.dat ${TMP_DIR}/S1.dat

  # remove extraction dir
  rm -r $EXT_DIR

  # remove header
  sed -i -e "1d" ${TMP_DIR}/S1.dat

  cd $CUR_DIR
else
  # copy receivers as to temp dir
  cp $RECEIVER1 $TMP_DIR/S1.dat
fi

if [[ $EXTQ2 != '' ]]
then
  EXT_DIR=$(mktemp -d)

  # extract
  cp $RECEIVER2 $EXT_DIR
  cd $EXT_DIR
  recvs_csv_to_plain.r . $EXTS2 1

  # move extracted receiver
  mv *_Q${EXTQ2}_C${EXTC2}.dat ${TMP_DIR}/S2.dat

  # remove extraction dir
  rm -r $EXT_DIR

  # remove header
  sed -i -e "1d" ${TMP_DIR}/S2.dat

  cd $CUR_DIR
else
  # copy receivers as to temp dir
  cp $RECEIVER2 $TMP_DIR/S2.dat
fi

# move to temp dir
cd $TMP_DIR

# create config for TF_MISFIT_GOF
# TODO: Fix to dynamic number of samples, time step and frequency range.
echo "&INPUT MT=250, DT=0.02, FMIN=0.13, FMAX=5.0, S1_NAME='S1.dat', S2_NAME='S2.dat', NC = 1,
       IS_S2_REFERENCE = T, LOCAL_NORM = F/
     "> HF_TF-MISFIT_GOF

# call TF_MISFIT_GOF
tf_misfits_gof

# move back to current dir
cd $CUR_DIR

# create output directoru
mkdir -p $OUT_DIR

# store the results
mv $TMP_DIR/* $OUT_DIR

# remove temp dir
rmdir $TMP_DIR

echo "$(date) tf_misfit_gof got the job done"