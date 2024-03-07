#!/bin/bash


export ROOT=$PWD/inference
export SD_FOLDER=$PWD/inference/text_to_image
export LOADGEN_FOLDER=$PWD/inference/loadgen
export MODEL_PATH=$PWD/inference/text_to_image/model/

cd $SD_FOLDER

cp $ROOT/data/text_to_image-mlperf.conf $SD_FOLDER/mlperf.conf

pip install -r requirements.txt
pip install pandas

cd $LOADGEN_FOLDER
CFLAGS="-std=c++14" python setup.py install


mkdir -p model

cd $MODEL_PATH

sudo -v ; curl https://rclone.org/install.sh | sudo bash

rclone config create mlc-inference s3 provider=Cloudflare \\
	access_key_id=f65ba5eef400db161ea49967de89f47b \\
	secret_access_key=fbea333914c292b854f14d3fe232bad6c5407bf0ab1bebf78833c2b359bdfd2b \\
	endpoint=https://c2686074cb2caf5cbaf6d134bdba8b47.r2.cloudflarestorage.com

rclone copy mlc-inference:mlcommons-inference-wg-public/stable_diffusion_fp32 ./stable_diffusion_fp32 -P

cd $SD_FOLDER/tools

./download-coco-2014.sh -n 20 -m 50

cd $SD_FOLDER

python3 main.py --dataset "coco-1024" --dataset-path coco2014 --profile stable-diffusion-xl-pytorch --model-path model/ --dtype fp32 --device cpu --time 1 --scenario Offline --thread 10
