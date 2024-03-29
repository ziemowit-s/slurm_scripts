#!/bin/bash
#SBATCH --partition=plgrid-gpu-a100
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --time=00:30:00
#SBATCH --job-name=jupyter-notebook-tunnel
#SBATCH --output=install-unsloth-log.txt
#SBATCH --gres=gpu:1  # Adjust the number of GPUs requested based on your needs and limits
#SBATCH --account=plgneuroanatomistllm-gpu-a100  # Specify your account

export WORKING_DIR=$PLG_GROUPS_STORAGE/plggcompneuro

# Load necessary modules and activate your environment
module load CUDA/12.1.1
source $WORKING_DIR/nn39/bin/activate

export PIP_CACHE_DIR=$WORKING_DIR/.cache/pip
export TRANSFORMERS_CACHE=$WORKING_DIR/.cache/huggingface
export TORCH_CUDA_ARCH_LIST="8.0"

# Install wheel
pip install wheel

pip install "unsloth[cu121-ampere] @ git+https://github.com/unslothai/unsloth.git"
