#!/bin/bash

# Use this file by running:
# source prepare-shell.sh [--cloud]

export SUB_PROJECT_NAME="sciencebeam"
export MODEL_NAME="pix2pix"
export VERSION_NAME=v5
export TRAINING_SUFFIX=-default
export TRAINING_ARGS=""
export PROJECT=$(gcloud config list project --format "value(core.project)")
export LOCAL_PATH_ROOT="./.models"
export BUCKET="gs://${PROJECT}-ml"
export COLOR_MAP_FILENAME="color_map.conf"
export USE_SEPARATE_CHANNELS=true
export DATASET_SUFFIX=
export BATCH_SIZE=10
export EVAL_SET_SIZE=10
export QUALITATIVE_FOLDER_NAME=
export QUALITATIVE_SET_SIZE=10
export RANDOM_SEED=42
export BASE_LOSS=L1
CHANNEL_NAMES=
TRAIN_FILE_LIMIT=
EVAL_FILE_LIMIT=
PAGE_RANGE=
MIN_ANNOTATION_PERCENTAGE=0
QUALITATIVE_PAGE_RANGE=1
QUALITATIVE_FILE_LIMIT=10
QUALITATIVE_PREPROC_PATH=

export USE_CLOUD=false

if [ "$1" == "--cloud" ]; then
  export USE_CLOUD=true
fi

export CONFIG_FILE='.config'
POST_CONFIG_FILE=
if [ -f "$CONFIG_FILE" ]; then
  source "${CONFIG_FILE}"
fi

if [ ! -z "$DATASET_SUFFIX" ]; then
  TRAINING_SUFFIX=$DATASET_SUFFIX
fi

# generate job id and save it
# TODO this should be done on-demand
export DEFAULT_JOB_ID="${SUB_PROJECT_NAME}_${USER}_${MODEL_NAME}_$(date +%Y%m%d_%H%M%S)"

export JOB_ID_FILE='.job-id'
if [ -f "$JOB_ID_FILE" ]; then
  export JOB_ID=`cat "${JOB_ID_FILE}"`
else
  export JOB_ID="${DEFAULT_JOB_ID}"
  echo -n "$JOB_ID" > "${JOB_ID_FILE}"
fi

# cloud paths
export GCS_SUB_PROJECT_PATH="${BUCKET}/${SUB_PROJECT_NAME}"
export GCS_PATH="${GCS_SUB_PROJECT_PATH}/${MODEL_NAME}/${VERSION_NAME}"
export GCS_DATA_PATH="${GCS_PATH}/data${DATASET_SUFFIX}"
export GCS_CONFIG_PATH="${GCS_PATH}/config"
export GCS_PREPROC_PATH="${GCS_PATH}/preproc${DATASET_SUFFIX}"
export GCS_TRAIN_MODEL_PATH="${GCS_PATH}${TRAINING_SUFFIX}/training"

# local paths
export LOCAL_MODEL_PATH="${LOCAL_PATH_ROOT}/${MODEL_NAME}/${VERSION_NAME}"
export LOCAL_DATA_PATH="${LOCAL_MODEL_PATH}/data${DATASET_SUFFIX}"
export LOCAL_CONFIG_PATH="."
export LOCAL_PREPROC_PATH="${LOCAL_MODEL_PATH}/preproc${DATASET_SUFFIX}"
export LOCAL_TRAIN_MODEL_PATH="${LOCAL_MODEL_PATH}${TRAINING_SUFFIX}/training"

echo "USE_CLOUD: $USE_CLOUD"

if [ $USE_CLOUD == true ]; then
  export DATA_PATH="${GCS_DATA_PATH}"
  export CONFIG_PATH="${GCS_CONFIG_PATH}"
  export PREPROC_PATH="${GCS_PREPROC_PATH}"
  export TRAIN_MODEL_PATH="${GCS_TRAIN_MODEL_PATH}"
else
  export DATA_PATH="${LOCAL_DATA_PATH}"
  export CONFIG_PATH="${LOCAL_CONFIG_PATH}"
  export PREPROC_PATH="${LOCAL_PREPROC_PATH}"
  export TRAIN_MODEL_PATH="${LOCAL_TRAIN_MODEL_PATH}"
fi

TRAIN_PREPROC_PATH=${PREPROC_PATH}/train
EVAL_PREPROC_PATH=${PREPROC_PATH}/validation
TEST_PREPROC_PATH=${PREPROC_PATH}/test
FILE_LIST_PATH=$DATA_SOURCE_PATH

if [ ! -z "$QUALITATIVE_FOLDER_NAME" ]; then
  QUALITATIVE_PREPROC_PATH=${PREPROC_PATH}/$QUALITATIVE_FOLDER_NAME
fi

if [ ! -z "$POST_CONFIG_FILE" ]; then
  source "${POST_CONFIG_FILE}"
fi
