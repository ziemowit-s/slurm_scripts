#!/bin/bash
#SBATCH --partition=plgrid-gpu-a100
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --job-name=jupyter-notebook-tunnel
#SBATCH --output=jupyter-log-%J.txt
#SBATCH --gres=gpu:1  # Adjust the number of GPUs requested based on your needs and limits
#SBATCH --account=plgneuroanatomistllm-gpu-a100  # Specify your account

# Load the CUDA/11.7.0 module, recommended for A100 GPU
module load CUDA/12.1.1
##module load PyTorch/1.12.1-CUDA-11.3.1

# Define working directory
export WORKING_DIR=$PLG_GROUPS_STORAGE/plggcompneuro

# Set Hugging Face Transformers cache directory
export HF_HOME=$WORKING_DIR/.cache/huggingface

# Set pip cache directory
export PIP_CACHE_DIR=$WORKING_DIR/.cache/pip

# Use WORKING_DIR for other necessary operations, e.g., setting the initial path for the Jupyter Notebook
export JUPYTER_INIT_PATH=$WORKING_DIR

source $WORKING_DIR/nn39/bin/activate

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

# Change to the JUPYTER_INIT_PATH if specified, otherwise default to the home directory
if [ -n "$JUPYTER_INIT_PATH" ]; then
    cd "$JUPYTER_INIT_PATH"
else
    cd $HOME
fi

# Print the current working directory
echo "Starting Jupyter Notebook in directory:"
pwd

# check CUDA if available
python $PLG_GROUPS_STORAGE/plggcompneuro/slurm_scripts/check_cuda.py

## start an ipcluster instance and launch jupyter server
jupyter-notebook --no-browser --port=$ipnport --ip=$ipnip
