#!/bin/bash

set -e  # Exit on any error

echo "📥 Downloading Qwen3-Coder-30B-A3B-Instruct model..."

# Check if we're in the right directory
cd /workspace

# Set up paths
MODEL_NAME="Qwen/Qwen3-Coder-30B-A3B-Instruct"
MODEL_DIR="qwen3-coder-30b"
HF_CLI="/workspace/qwen-env/bin/huggingface-cli"

# Check if virtual environment exists
if [ ! -d "qwen-env" ]; then
    echo "❌ Virtual environment not found! Please run setup_qwen_env.sh first."
    exit 1
fi

# Check available disk space
echo "💾 Checking available disk space..."
AVAILABLE_SPACE=$(df /workspace | tail -1 | awk '{print $4}')
REQUIRED_SPACE=70000000  # ~70GB in KB
if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    echo "❌ Insufficient disk space!"
    echo "Available: $(($AVAILABLE_SPACE / 1024 / 1024))GB"
    echo "Required: ~70GB"
    echo "Please free up space and try again."
    exit 1
fi

echo "✅ Sufficient disk space available: $(($AVAILABLE_SPACE / 1024 / 1024))GB"

# Remove existing model directory if it exists
if [ -d "$MODEL_DIR" ]; then
    echo "🗑️  Removing existing model directory..."
    rm -rf "$MODEL_DIR"
fi

# Check if huggingface-cli is available
if [ ! -f "$HF_CLI" ]; then
    echo "❌ huggingface-cli not found! Installing..."
    /workspace/qwen-env/bin/pip install huggingface-hub
fi

# Show model info before download
echo ""
echo "📋 Model Information:"
echo "Model: $MODEL_NAME"
echo "Download size: ~65.1 GB"
echo "Destination: /workspace/$MODEL_DIR"
echo ""

# Confirm download
echo -n "⚠️  This will download ~65GB. Continue? (y/N): "
read REPLY
if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
    echo "❌ Download cancelled."
    exit 1
fi

# Start download with progress
echo "🚀 Starting download..."
echo "⏱️  This will take 10-30 minutes depending on your connection..."
echo ""

# Download the model
$HF_CLI download "$MODEL_NAME" --local-dir "/workspace/$MODEL_DIR" --resume-download

# Verify download
if [ -d "/workspace/$MODEL_DIR" ] && [ -f "/workspace/$MODEL_DIR/config.json" ]; then
    echo ""
    echo "✅ Download completed successfully!"
    echo "📁 Model location: /workspace/$MODEL_DIR"
    echo "📊 Model size: $(du -sh /workspace/$MODEL_DIR | cut -f1)"
    echo ""
    echo "🎯 Ready to run inference!"
    echo "Next steps:"
    echo "  1. Activate environment: source qwen-env/bin/activate"
    echo "  2. Run inference with vLLM or transformers"
else
    echo "❌ Download failed or incomplete!"
    echo "Please check your internet connection and try again."
    exit 1
fi
