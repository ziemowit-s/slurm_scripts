#!/bin/bash

# Submit the batch job and capture the output
output=$(sbatch python-notebook.slurm)

# Extract the job ID from the output
job_id=$(echo $output | grep -oP '\d+')

echo "Submitted batch job with ID: $job_id"

# Construct the log file name using the job ID
log_file_name="jupyter-log-$job_id.txt"

# Flag to keep track of script running status
keep_running=true

# Function to cancel the job and remove the log file, then exit script
cancel_job() {
  echo "Cancelling job $job_id"
  scancel $job_id
  if [ -f "$log_file_name" ]; then
    echo "Removing log file $log_file_name"
    rm -f $log_file_name
  fi
  keep_running=false
  exit  # Exit the script immediately
}

# Set up trap to call cancel_job when the script is interrupted
trap cancel_job INT TERM

echo "Waiting for log file to be created..."

# Wait for the log file to be created, checking periodically
while $keep_running; do
  if [ -f "$log_file_name" ]; then
    echo "Log file ($log_file_name) was created."
    echo "Contents of the log file:"
    cat $log_file_name
    echo "---------------------------------"
    break  # Log file found, break out of the loop
  else
    sleep 10  # Wait for 10 seconds before checking again
  fi
done

# Exit the script if cancel_job was called before the log file was created
if [ "$keep_running" = false ]; then
  exit
fi

# After the log file is found, monitor the job status
echo "Monitoring the job status. Press Ctrl+C to cancel the job and exit."
while $keep_running && squeue | grep -q $job_id; do
  sleep 10
done

echo "Job $job_id has completed or was cancelled."

# Optionally, you can also remove the log file here if you want to clean up
if [ -f "$log_file_name" ]; then
  echo "Removing log file $log_file_name"
  rm -f $log_file_name
fi
