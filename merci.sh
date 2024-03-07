#!/bin/bash

export HOME="/mnt/sda4/run/"

#mem_sizes=( 1.25 1.5 2.0 9.0 )
mem_sizes=( 1.5)
thread=10

top_dir=result
merci_dir=$top_dir/merci

mkdir -p $top_dir
mkdir -p $merci_dir

apt install g++-9

mkdir -p data/1_raw_data/amazon

cd data/1_raw_data/amazon

wget https://datarepo.eng.ucsd.edu/mcauley_group/data/amazon_v2/categoryFiles/Office_Products.json.gz
wget https://datarepo.eng.ucsd.edu/mcauley_group/data/amazon_v2/metaFiles2/meta_Office_Products.json.gz


#PREPROCESSING
cd ../../1_preprocess/scripts/
python3 amazon_parse_divide_filter.py Office_Products

#PARTITIONING
cd ../../2_partition/scripts/
./run_patoh.sh amazon_Office_Products 2748

#CLUSTERING
cd ../../3_clustering/
mkdir -p bin
make
./bin/clustering -d amazon_Office_Products -p 2748

#PERFORMANCE EVALUATION
cd ../4_performance_evaluation/
mkdir -p bin
make all
for mem in ${mem_sizes[@]}; do
	sync && echo 1 > /proc/sys/vm/drop_caches
	./bin/eval_merci -d amazon_Office_Products -p 2748 --memory_ratio ${mem} -c ${thread} -r 5 > ../${merci_dir}/amazon_${mem}X
