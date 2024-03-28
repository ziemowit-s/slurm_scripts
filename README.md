# Slurm Job Submission and Monitoring Script

## Introduction

This Bash script is designed to automate the submission and monitoring of batch jobs in a high-performance computing (HPC) environment. 
It's particularly tailored to run Jupyter notebooks but can be adapted for other types of jobs.

## Features

- **Automated job submission** using `sbatch`.
- **Real-time monitoring** of the job's log file for initial output.
- **Interactive cancellation** with signal handling to cleanly cancel the job if the script is interrupted.
- **Automatic cleanup** by removing the log file after job completion or cancellation.

## Prerequisites

- Access to a computing cluster with `sbatch` command available.
- Permissions to submit and cancel jobs in the cluster.

## Usage

### Configuration
Before running the script, ensure `the python-notebook.slurm` file is configured with the desired SBATCH directives and job settings.

### Running the Script

1. Make the script executable (if not already done):
```bash
chmod +x submit_and_monitor.sh

2. Run the script by simply executing it from the command line:
```bash
./submit_and_monitor.sh
```

### Interruption Handling
To cancel the job and remove the log file, simply interrupt the script using Ctrl+C.
If the script detects an interruption, it will automatically execute scancel with the submitted job ID and remove the corresponding log file (after Ctrl+C wait till it ends).

### Output
The script will create a log file named `jupyter-log-<JOB_ID>.txt` capturing the output of the job. 
This file will be automatically displayed once it's available and deleted after the job completes or is canceled.
