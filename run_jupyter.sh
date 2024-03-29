#!/bin/bash

# Check if a path argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path-to-jupyter-init_path>"
  exit 1
fi

# The path to the Jupyter init directory from the script argument
starting_dir=$1

# Initialize the number of attempts to wait for the log file to be created
max_attempts=50

# Function to cancel the job and remove the log file
cancel_job() {
  echo "Cancelling job $job_id"
  scancel $job_id
  if [ -f "$log_file_name" ]; then
    echo "Removing log file $log_file_name"
    rm -f $log_file_name
  fi
}

# Submit the batch job and capture the output, passing the starting directory as a variable
output=$(sbatch --export=ALL,JUPYTER_INIT_PATH="$starting_dir" python-notebook.slurm)

# Extract the job ID from the output
job_id=$(echo $output | grep -oP '\d+')

echo "Submitted batch job with ID: $job_id"

# Construct the log file name using the job ID
log_file_name="jupyter-log-$job_id.txt"

# Set up trap to call cancel_job when the script is interrupted
trap cancel_job INT TERM

attempt=0

# Wait for the log file to be created, checking periodically
while [ ! -f "$log_file_name" ] && [ $attempt -lt $max_attempts ]; do
  echo "Waiting for log file to be created... (Attempt: $((attempt+1))/$max_attempts)"
  sleep 10  # Wait for 10 seconds before checking again
  ((attempt++))
done

# Check if the log file was created within the given number of attempts
if [ ! -f "$log_file_name" ]; then
  echo "Error: Log file ($log_file_name) was not created after $max_attempts attempts."
  exit 1
else
  echo "Log file ($log_file_name) was created."
  echo "Contents of the log file:"
  cat $log_file_name
  echo "---------------------------------"
fi

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
