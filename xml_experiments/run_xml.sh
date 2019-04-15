#!/usr/bin/env bash

DATASET_NAME=$1
FILES_PREFIX=$2
PARAMS=$3
QUANTIZE_PARAMS=$4

THREADS=11

mkdir -p models

SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" )
BIN=${SCRIPT_DIR}/../extremetext

if [ ! -e datasets4fastText ]; then
    git clone https://github.com/mwydmuch/datasets4fastText.git
    cd datasets4fastText
    git checkout with_features_values
    cd ..
fi

if [ ! -e $FILES_PREFIX ]; then
    bash datasets4fastText/xml_repo/get_${DATASET_NAME}.sh
fi

if [ ! -e ${BIN} ]; then
    cd ${SCRIPT_DIR}/..
    make -j
    cd -
fi

TRAIN=${FILES_PREFIX}/${FILES_PREFIX}_train
TEST=${FILES_PREFIX}/${FILES_PREFIX}_test

if [ ! -e $TRAIN ]; then
    TRAIN=${FILES_PREFIX}/${FILES_PREFIX}_train0
    TEST=${FILES_PREFIX}/${FILES_PREFIX}_test0
fi

# Model training
mkdir -p models
MODEL="models/${FILES_PREFIX}_$(echo $PARAMS | tr ' /' '__')"

if [ ! -e ${MODEL}.bin ]; then
    time $BIN supervised -input $TRAIN -output $MODEL $PARAMS -thread $THREADS
fi

# Test model
time $BIN test ${MODEL}.bin ${TEST} 1 0.7 $THREADS
#time $BIN test ${MODEL}.bin ${TEST} 3 0 $THREADS
#time $BIN test ${MODEL}.bin ${TEST} 5 0 $THREADS

#time $BIN test ${MODEL}.bin ${TEST} 1 0 1
#time $BIN test ${MODEL}.bin ${TEST} 3 0 1
#time $BIN test ${MODEL}.bin ${TEST} 5 0 1

echo "Model: ${MODEL}.bin"
echo "Model size: $(ls -lh ${MODEL}.bin | grep -E '[0-9\.,]+[BMG]' -o)"

# Model quantization
#if [ ! -e ${MODEL}.ftz ]; then
#    time $BIN quantize -output $MODEL -input $TRAIN -thread $THREADS $QUANTIZE_PARAMS
#fi

#time $BIN test ${MODEL}.ftz ${TEST} 1
#time $BIN test ${MODEL}.ftz ${TEST} 3
#time $BIN test ${MODEL}.ftz ${TEST} 5

#echo "Quantized model: ${MODEL}.ftz"
#echo "Quantized model size: $(ls -lh ${MODEL}.ftz | grep -E '[0-9\.,]+[BMG]' -o)"

# Get probabilities for labels in the file
#time $BIN get-prob ${MODEL}.bin ${TEST} ${MODEL}_test.prob ${THREADS}

# Predict labels
#time $BIN predict ${MODEL}.bin ${TEST} 5 0 ${MODEL}_test.pred 1 > ${MODEL}_test.pred

# Predict labels and get probabilities for labels in the file
#time $BIN predict-prob ${MODEL}.bin ${TEST} 5 0 ${MODEL}_test.pred-prob ${THREADS}