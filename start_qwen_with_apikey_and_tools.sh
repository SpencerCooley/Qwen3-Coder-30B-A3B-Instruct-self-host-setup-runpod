#!/bin/bash

set -e  # Exit on any error

# Kill any running Jupyter processes
echo "�~_~T� Killing Jupyter notebook processes..."
pkill -f jupyter || echo "No Jupyter processes found"
pkill -f notebook || echo "No notebook processes found"

# Set API key (change this to your desired key)
API_KEY="qwen-coder-api-key-12345"

# GPU Configuration
TENSOR_PARALLEL_SIZE=1  # Change to 1 for single GPU, 2 for dual A40 setup


if [ "$TENSOR_PARALLEL_SIZE" -eq 1 ]; then
    export CUDA_VISIBLE_DEVICES=0
else
    # Multi-GPU NCCL settings
    export NCCL_DEBUG=WARN
    export NCCL_SOCKET_IFNAME=^docker0,lo
    export NCCL_IB_DISABLE=1
    export NCCL_P2P_DISABLE=1
    export CUDA_VISIBLE_DEVICES=0,1
fi

echo "🚀 Starting Qwen3-Coder-30B-A3B-Instruct server with tool calling support..."

# Check if we're in the right directory
cd /workspace

# Set up paths
MODEL_DIR="/workspace/qwen3-coder-30b"
VLLM_PATH="/workspace/qwen-env/bin/vllm"

# Check if model exists
if [ ! -d "$MODEL_DIR" ]; then
    echo "❌ Model not found at $MODEL_DIR"
    echo "Available directories in /workspace:"
    ls -la /workspace/
    echo "Please run download_qwen_model.sh first!"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "qwen-env" ]; then
    echo "❌ Virtual environment not found! Please run setup_qwen_env.sh first."
    exit 1
fi

# Check if vLLM is installed
if [ ! -f "$VLLM_PATH" ]; then
    echo "❌ vLLM not found at $VLLM_PATH"
    echo "Checking what's in qwen-env/bin/:"
    ls -la /workspace/qwen-env/bin/ | grep -E "(vllm|python)"
    echo "Installing vLLM..."
    /workspace/qwen-env/bin/pip install vllm
fi

# Kill any existing vLLM processes
echo "🔪 Killing any existing vLLM processes..."
pkill -f "vllm" 2>/dev/null || echo "No existing vLLM processes found"

# Wait a moment for processes to clean up
sleep 2

echo "⚡ Starting vLLM server..."
echo "📍 Model: $MODEL_DIR"
echo "🌐 API: http://localhost:8888"
echo "🔑 API Key: $API_KEY"
echo "🛠️  Tool calling: Enabled"
echo ""
echo "Recommended settings:"
echo "  - temperature=0.7"
echo "  - top_p=0.8" 
echo "  - top_k=20"
echo "  - repetition_penalty=1.05"
echo "  - max_tokens=65536"
echo ""

# Start vLLM server with optimal settings for A100
echo "🚀 Executing vLLM command..."
echo "Command: $VLLM_PATH serve $MODEL_DIR --host 0.0.0.0 --port 8888 --api-key $API_KEY --enable-auto-tool-choice --tool-call-parser $MODEL_DIR/qwen3coder_tool_parser.py"
echo ""

$VLLM_PATH serve "$MODEL_DIR" \
    --host 0.0.0.0 \
    --port 8888 \
    --api-key "$API_KEY" \
    --served-model-name "Qwen3-Coder-30B-A3B-Instruct" \
    --max-model-len 141728 \
    --tensor-parallel-size $TENSOR_PARALLEL_SIZE \
    --gpu-memory-utilization 0.9 \
    --enable-auto-tool-choice \
    --tool-call-parser "qwen3_coder"
