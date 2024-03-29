#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <path-to-jupyter-starting-dir> <job-duration>"
  exit 1
fi

# The path to the Jupyter starting directory from the first script argument
starting_dir=$1

# The job duration in the format 'days-hours:minutes:seconds' from the second script argument
job_duration=$2

# Function to cancel the job and remove the log file
cancel_job() {
  echo "Cancelling job $job_id"
  scancel $job_id
  if [ -f "$log_file_name" ]; then
    echo "Removing log file $log_file_name"
    rm -f $log_file_name
  fi
}

# Submit the batch job, passing the starting directory and job duration as variables
output=$(sbatch --export=ALL,JUPYTER_INIT_PATH="$starting_dir" --time="$job_duration" python-notebook.slurm)

# Extract the job ID from the output
job_id=$(echo $output | grep -oP '\d+')

echo "Submitted batch job with ID: $job_id"

# Construct the log file name using the job ID
log_file_name="jupyter-log-$job_id.txt"

# Set up trap to call cancel_job when the script is interrupted
trap cancel_job INT TERM

echo "Waiting for log file to be created..."

# Wait indefinitely for the log file to be created, checking periodically
while [ ! -f "$log_file_name" ]; do
  sleep 10  # Wait for 10 seconds before checking again
done

echo "Log file ($log_file_name) was created."
echo "Contents of the log file:"
cat $log_file_name
echo "---------------------------------"

# After the log file is found, monitor the job status
echo "Monitoring the job status. Press Ctrl+C to cancel the job and exit."
while squeue | grep -q $job_id; do
  sleep 10
done

echo "Job $job_id has completed or was cancelled."

# Optionally, you can also remove the log file here if you want to clean up
if [ -f "$log_file_name" ]; then
  echo "Removing log file $log_file_name"
  rm -f $log_file_name
fi
