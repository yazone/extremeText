#!/usr/bin/env bash

DATASET_NAME="WikipediaLarge-500K"
FILES_PREFIX="WikipediaLarge-500K"
PARAMS="-lr 0.5 -epoch 30 -arity 2 -dim 500 -l2 0.001 -wordsWeights -treeType kmeans"

bash run_xml.sh $DATASET_NAME $FILES_PREFIX "$PARAMS"