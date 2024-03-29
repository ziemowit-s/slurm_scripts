import torch

# Check PyTorch version
print(f"PyTorch Version: {torch.__version__}")

# Check CUDA availability
cuda_available = torch.cuda.is_available()
print(f"CUDA Available: {cuda_available}")

if cuda_available:
    # Check CUDA version
    print(f"CUDA Version: {torch.version.cuda}")
    
    # Check the number of GPUs available
    num_gpus = torch.cuda.device_count()
    print(f"Number of GPUs Available: {num_gpus}")
    
    # Print information about each available GPU
    for i in range(num_gpus):
        print(f"GPU {i}: Name = {torch.cuda.get_device_name(i)}, Capability = {torch.cuda.get_device_capability(i)}")
else:
    print("No GPU available.")

# Create a tensor and move it to GPU
tensor = torch.tensor([1, 2, 3]).cuda()

print("CUDA tensor device:")
# Print tensor device, should output something like: cuda:0 indicating GPU usage
print(tensor.device)

