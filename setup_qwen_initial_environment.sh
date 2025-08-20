#!/bin/bash

set -e  # Exit on any error

echo "🚀 Setting up Qwen3-Coder environment in /workspace..."

# Kill any running Jupyter processes
echo "🔪 Killing Jupyter notebook processes..."
pkill -f jupyter || echo "No Jupyter processes found"
pkill -f notebook || echo "No notebook processes found"

# Navigate to workspace
cd /workspace

# Remove existing environment if it exists
if [ -d "qwen-env" ]; then
    echo "🗑️  Removing existing qwen-env..."
    rm -rf qwen-env
fi

# Create new virtual environment
echo "🐍 Creating Python virtual environment..."
python3 -m venv qwen-env

# Use the virtual environment's python and pip directly
echo "⚡ Using virtual environment..."
PYTHON_PATH="/workspace/qwen-env/bin/python"
PIP_PATH="/workspace/qwen-env/bin/pip"

# Upgrade pip
echo "📦 Upgrading pip..."
$PIP_PATH install --upgrade pip

# Install PyTorch with CUDA support
echo "🔥 Installing PyTorch with CUDA 12.1..."
$PIP_PATH install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install core ML packages
echo "🤗 Installing Transformers and Hugging Face packages..."
$PIP_PATH install transformers accelerate huggingface-hub datasets

# Install vLLM for high-performance inference
echo "⚡ Installing vLLM..."
$PIP_PATH install vllm

# Install additional useful packages
echo "📊 Installing additional packages..."
$PIP_PATH install numpy scipy matplotlib seaborn jupyter ipykernel

# Install flash attention (optional but recommended)
echo "⚡ Installing Flash Attention (this may take a while)..."
$PIP_PATH install flash-attn --no-build-isolation || echo "⚠️  Flash Attention installation failed (optional)"

# Show environment info
echo ""
echo "✅ Environment setup complete!"
echo "📍 Location: /workspace"
echo "🐍 Python: $PYTHON_PATH"
echo "📦 Pip: $($PIP_PATH --version)"
echo ""
echo "To activate the environment in future sessions:"
echo "  cd /workspace && source qwen-env/bin/activate"
echo ""
echo "Ready to download Qwen3-Coder-30B-A3B-Instruct!"
