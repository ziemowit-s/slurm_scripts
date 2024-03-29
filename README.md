# Slurm: Submission and Monitoring

## Introduction

This Bash script is designed to automate the submission and monitoring of batch jobs in a high-performance computing (HPC) environment. 
It's particularly tailored to run Jupyter notebooks with supercomputer [Athena](https://guide.plgrid.pl/resources/athena) in Academic Computer Centre Cyfronet AGH but can be adapted for other types of jobs.

## Features

- **Automated job submission** using `sbatch`.
- **Real-time monitoring** of the job's log file for initial output.
- **Interactive cancellation** with signal handling to cleanly cancel the job if the script is interrupted.
- **Automatic cleanup** by removing the log file after job completion or cancellation.

## Prerequisites

- Access to a computing cluster with `sbatch` command available.
- Permissions to submit and cancel jobs in the cluster.
- Change the Python source path in the `python-notebook.slurm` script suited to your location, which will load environment containing Jupyter
- Preferably provide Jupyter password to log in without the need of token
```bash
jupyter notebook password
```
- If you do want to use tokens instead look into the log file created for your job to see Jupyter's outputs containing the token
```bash
cat jupyter-log-JOB_ID.txt
```

## Usage

### Configuration
Before running the script, ensure `the python-notebook.slurm` file is configured with the desired SBATCH directives and job settings. By default it is set to 1 GPU (A100 for default Athena usage).
Time is parametrized with `run_jupyter.sh` script (see below).

### Check CUDA
You can check CUDA availability running:
```bash
sbatch check-cuda.slurm
```
It will check PyTorch (in your source Path in slurm file, so adjust if needed) and CUDA loaded as module and output log to `check-cuda-log.txt` file.
You need to manually remove the `check-cuda-log.txt` file. By default the script will run for 30 minuts, but if you want to kill it earlier just run:
```bash
scancel JOB_ID
```

### Running the Script

1. Make the script executable (if not already done):
```bash
chmod +x run_jupyter.sh
```

2. Run the script with 2 parameters: Jupyter starting directory at `/path/to/your/dir` and time of your script to run in format `days-hours:minutes:seconds` (e.g., `1-00:00:00` for one day) :
```bash
./run_jupyter.sh /path/to/your/dir 1-00:00:00
```


### Interruption Handling
To cancel the job and remove the log file, simply interrupt the script using Ctrl+C.
If the script detects an interruption, it will automatically execute scancel with the submitted job ID and remove the corresponding log file (after Ctrl+C wait till it ends).

### Output
The script will create a log file named `jupyter-log-<JOB_ID>.txt` capturing the output of the job. 
This file will be automatically displayed once it's available and deleted after the job completes or is canceled.
The content of the log file shows a SSH tunel command you should run on your local machine (especially check port because it might differ from the default Jupyter port), the ssh tunneling will looks like this:

```bash
ssh -o ServerAliveInterval=300 -N -L PORT:IP_ADDRESS:PORT USERNAME@athena.cyfronet.pl
```

after establising the tunel you will be able to access Jupyter from your local browser `localhost:PORT`. 
If you need the token, it will be displayed with all Jupyter run log, after sbatch submit the job.
