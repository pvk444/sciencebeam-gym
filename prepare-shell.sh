#!/bin/bash

# Use this file by running:
# source prepare-shell.sh [--cloud]

SUB_PROJECT_NAME="sciencebeam"
MODEL_NAME="pix2pix"
VERSION_NAME=v5
TRAINING_SUFFIX=-default
TRAINING_ARGS=""
PROJECT=$(gcloud config list project --format "value(core.project)")
LOCAL_PATH_ROOT="./.models"
BUCKET="gs://${PROJECT}-ml"
TEMP_BUCKET=
COLOR_MAP_FILENAME="color_map.conf"
XML_MAPPING_FILENAME="annot-xml-full.conf"
USE_SEPARATE_CHANNELS=true
DATASET_SUFFIX=
BATCH_SIZE=10
EVAL_SET_SIZE=10
QUALITATIVE_FOLDER_NAME=
QUALITATIVE_SET_SIZE=10
RANDOM_SEED=42
BASE_LOSS=L1
CHANNEL_NAMES=
TRAIN_FILE_LIMIT=
EVAL_FILE_LIMIT=
PAGE_RANGE=
MIN_ANNOTATION_PERCENTAGE=0
QUALITATIVE_PAGE_RANGE=1
QUALITATIVE_FILE_LIMIT=10
QUALITATIVE_PREPROC_PATH=
NUM_WORKERS=1
CLASS_WEIGHTS_FILENAME=
MAX_TRAIN_STEPS=1000
JOB_ID=
USE_CLOUD=false

extra_args=()
for arg in "$@"; do
case $arg in
  --cloud) USE_CLOUD=true ;;
  *) extra_args+=($arg) ;;
esac; done
set -- $extra_args
echo "USE_CLOUD: $USE_CLOUD"
echo "ARGS: $@"

CONFIG_FILE='.config'
POST_CONFIG_FILE=
if [ -f "$CONFIG_FILE" ]; then
  source "${CONFIG_FILE}"
fi

DATASET_TRAINING_SUFFIX=${DATASET_SUFFIX}${TRAINING_SUFFIX}

# generate job id and save it
# TODO this should be done on-demand
DEFAULT_JOB_ID="${MODEL_NAME}${DATASET_TRAINING_SUFFIX}_$(date +%Y%m%d_%H%M%S)"
DEFAULT_JOB_ID="${DEFAULT_JOB_ID//-/_}"

if [ -z "$JOB_ID" ]; then
  JOB_ID="${DEFAULT_JOB_ID}"
fi

if [ -z "$TEMP_BUCKET" ]; then
  TEMP_BUCKET="${BUCKET}"
fi

# cloud paths
GCS_SUB_PROJECT_PATH="${BUCKET}/${SUB_PROJECT_NAME}"
GCS_PATH="${GCS_SUB_PROJECT_PATH}/${MODEL_NAME}/${VERSION_NAME}"
GCS_DATA_PATH="${GCS_PATH}/data${DATASET_SUFFIX}"
GCS_CONFIG_PATH="${GCS_PATH}/config"
GCS_PREPROC_PATH="${GCS_PATH}${DATASET_SUFFIX}/preproc"
GCS_TRAIN_MODEL_PATH="${GCS_PATH}${DATASET_TRAINING_SUFFIX}/training"
GCS_MODEL_EXPORT_PATH="${GCS_PATH}${DATASET_TRAINING_SUFFIX}/export"

# local paths
LOCAL_MODEL_PATH="${LOCAL_PATH_ROOT}/${MODEL_NAME}/${VERSION_NAME}"
LOCAL_DATA_PATH="${LOCAL_MODEL_PATH}/data${DATASET_SUFFIX}"
LOCAL_CONFIG_PATH="."
LOCAL_PREPROC_PATH="${LOCAL_MODEL_PATH}${DATASET_SUFFIX}/preproc"
LOCAL_TRAIN_MODEL_PATH="${LOCAL_MODEL_PATH}${DATASET_TRAINING_SUFFIX}/training"
LOCAL_MODEL_EXPORT_PATH="${LOCAL_MODEL_PATH}${DATASET_TRAINING_SUFFIX}/export"

if [ $USE_CLOUD == true ]; then
  DATA_PATH="${GCS_DATA_PATH}"
  CONFIG_PATH="${GCS_CONFIG_PATH}"
  PREPROC_PATH="${GCS_PREPROC_PATH}"
  TRAIN_MODEL_PATH="${GCS_TRAIN_MODEL_PATH}"
  MODEL_EXPORT_PATH="${GCS_MODEL_EXPORT_PATH}"
else
  DATA_PATH="${LOCAL_DATA_PATH}"
  CONFIG_PATH="${LOCAL_CONFIG_PATH}"
  PREPROC_PATH="${LOCAL_PREPROC_PATH}"
  TRAIN_MODEL_PATH="${LOCAL_TRAIN_MODEL_PATH}"
  MODEL_EXPORT_PATH="${LOCAL_MODEL_EXPORT_PATH}"
fi

TRAIN_PREPROC_PATH=${PREPROC_PATH}/train
EVAL_PREPROC_PATH=${PREPROC_PATH}/validation
TEST_PREPROC_PATH=${PREPROC_PATH}/test
FILE_LIST_PATH=$DATA_SOURCE_PATH

if [ ! -z "$QUALITATIVE_FOLDER_NAME" ]; then
  QUALITATIVE_PREPROC_PATH=${PREPROC_PATH}/$QUALITATIVE_FOLDER_NAME
fi

if [ ! -z "$CLASS_WEIGHTS_FILENAME" ]; then
  CLASS_WEIGHTS_URL="${TRAIN_PREPROC_PATH}/${CLASS_WEIGHTS_FILENAME}"
fi

if [ ! -z "$POST_CONFIG_FILE" ]; then
  source "${POST_CONFIG_FILE}"
fi
