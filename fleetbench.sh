#!bin/bash

sudo apt install apt-transport-https curl gnupg clang -y
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg
sudo mv bazel-archive-keyring.gpg /usr/share/keyrings
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list

sudo apt update && sudo apt install -y bazel
sudo apt update && sudo apt -y full-upgrade
sudo apt install -y bazel-7.0.2

#COMPILE AND RUN
GLIBC_TUNABLES=glibc.pthread.rseq=0 bazel build --config=clang --config=opt fleetbench/tcmalloc:empirical_driver

bazel-bin/fleetbench/tcmalloc/empirical_driver  --benchmark_min_time=120s --benchmark_filter="BM_Tcmalloc_9/min_warmup_time:0.500/real_time/threads:8"
