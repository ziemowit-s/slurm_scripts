#!/bin/bash
#SBATCH --partition=plgrid-gpu-a100
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --time=2-00:00:00
#SBATCH --job-name=jupyter-notebook-tunnel
#SBATCH --output=jupyter-log-%J.txt
#SBATCH --gres=gpu:1  # Adjust the number of GPUs requested based on your needs and limits
#SBATCH --account=plgneuroanatomistllm-gpu-a100  # Specify your account

cd $PLG_GROUPS_STORAGE/plggcompneuro

# Set the working directory
export WORKING_DIR=$(pwd)
export HOME=$WORKING_DIR
export PATH=$PATH:$HOME:$HOME/.local/bin
export PIP_CACHE_DIR=$HOME/.cache/pip
export JUPYTER_INIT_PATH=$WORKING_DIR
export TOKENIZERS_PARALLELISM=false


# Load necessary modules
module load GCC/12.3.0
module load CUDA/12.1.1
module load Python/3.11.3
module load Python-bundle-PyPI/2023.06
module load IPython/8.14.0

# Define the directory name
DIR="nngcc"
source $DIR/bin/activate

## get tunneling info
XDG_RUNTIME_DIR=""
ipnport=$(shuf -i8000-9999 -n1)
ipnip=$(hostname -i)
user=$USER

## print tunneling instructions to jupyter-log-{jobid}.txt
echo -e "
    Copy/Paste this in your local terminal to ssh tunnel with remote
    -----------------------------------------------------------------
    ssh -o ServerAliveInterval=300 -N -L $ipnport:$ipnip:$ipnport ${user}@athena.cyfronet.pl
    -----------------------------------------------------------------

    Then open a browser on your local machine to the following address
    ------------------------------------------------------------------
    localhost:$ipnport  (prefix w/ https:// if using password)
    ------------------------------------------------------------------
    "

# Print the current working directory
echo "Starting Jupyter Notebook in directory:"
pwd

## start an ipcluster instance and launch jupyter server
jupyter-notebook --no-browser --port=$ipnport --ip=$ipnip

