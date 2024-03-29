#!/bin/bash
#SBATCH --partition=plgrid-gpu-a100
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --time=00:30:00
#SBATCH --job-name=jupyter-notebook-tunnel
#SBATCH --output=check-cuda-log.txt
#SBATCH --gres=gpu:1  # Adjust the number of GPUs requested based on your needs and limits
#SBATCH --account=plgneuroanatomistllm-gpu-a100  # Specify your account

# Module for A100 CUDA 
module load CUDA/12.1.1

source $PLG_GROUPS_STORAGE/plggcompneuro/nn39/bin/activate
python $PLG_GROUPS_STORAGE/plggcompneuro/slurm_scripts/check_cuda.py
