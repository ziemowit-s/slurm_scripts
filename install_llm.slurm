#!/bin/bash
#SBATCH --partition=plgrid-gpu-a100
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --time=03:00:00
#SBATCH --job-name=jupyter-notebook-tunnel
#SBATCH --output=install-llm-log.txt
#SBATCH --gres=gpu:1  # Adjust the number of GPUs requested based on your needs and limits
#SBATCH --account=plgneuroanatomistllm-gpu-a100  # Specify your account

cd $PLG_GROUPS_STORAGE/plggcompneuro

# Set the working directory
export WORKING_DIR=$(pwd)
export HOME=$WORKING_DIR
export PATH=$PATH:$HOME:$HOME/.local/bin
export PIP_CACHE_DIR=$HOME/.cache/pip

# Load necessary modules
module load GCC/12.3.0
module load CUDA/12.1.1
module load Python/3.11.3
module load Python-bundle-PyPI/2023.06
module load IPython/8.14.0

# Define the directory name
DIR="nngcc"

# Check if the directory exists
if [ -d "$DIR" ]; then
    # The directory exists, so remove it
    echo "Removing directory: $DIR"
    rm -r "$DIR"
else
    # The directory does not exist
    echo "Directory $DIR does not exist. create one and restart"
fi

# Create and activate the Python virtual environment
python3 -m venv $DIR
source $DIR/bin/activate

cd llm

pip install wheel
pip install -r requirements.txt
pip install ipywidgets

pip install "unsloth[cu121-ampere] @ git+https://github.com/unslothai/unsloth.git"
