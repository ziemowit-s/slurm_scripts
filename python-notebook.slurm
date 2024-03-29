#!/bin/bash
#SBATCH --partition=plgrid-gpu-a100
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --time=1-00:00:00
#SBATCH --job-name=jupyter-notebook-tunnel
#SBATCH --output=jupyter-log-%J.txt
#SBATCH --gres=gpu:1  # Adjust the number of GPUs requested based on your needs and limits
#SBATCH --account=plgneuroanatomistllm-gpu-a100  # Specify your account

source $PLG_GROUPS_STORAGE/plggcompneuro/nn39/bin/activate

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

##module load jupyterlab/3.1.6-gcccore-11.2.0 scipy-bundle/2021.10-intel-2021b

# Change to the JUPYTER_INIT_PATH if specified, otherwise default to the home directory
if [ -n "$JUPYTER_INIT_PATH" ]; then
    cd "$JUPYTER_INIT_PATH"
else
    cd $HOME
fi

## start an ipcluster instance and launch jupyter server
jupyter-notebook --no-browser --port=$ipnport --ip=$ipnip
