#!/bin/bash

echo "🔍 Debug script - checking everything step by step..."

echo "📁 Current directory:"
pwd

echo "📁 Contents of /workspace:"
ls -la /workspace/

echo "🐍 Virtual environment check:"
if [ -d "qwen-env" ]; then
    echo "✅ qwen-env exists"
    echo "Contents of qwen-env/bin:"
    ls -la qwen-env/bin/ | head -10
else
    echo "❌ qwen-env not found"
fi

echo "📦 Model directory check:"
if [ -d "qwen3-coder-30b" ]; then
    echo "✅ Model directory exists"
    echo "Model directory size:"
    du -sh qwen3-coder-30b/
    echo "Model files:"
    ls -la qwen3-coder-30b/ | head -5
else
    echo "❌ Model directory not found"
fi

echo "🔧 vLLM check:"
if [ -f "/workspace/qwen-env/bin/vllm" ]; then
    echo "✅ vLLM executable found"
    /workspace/qwen-env/bin/vllm --version
else
    echo "❌ vLLM executable not found"
    echo "Checking for python vllm module:"
    /workspace/qwen-env/bin/python -c "import vllm; print('vLLM version:', vllm.__version__)" 2>/dev/null || echo "vLLM module not found"
fi

echo "🔍 Python packages installed:"
/workspace/qwen-env/bin/pip list | grep -E "(vllm|torch|transformers)"

echo "💾 GPU check:"
nvidia-smi || echo "nvidia-smi not available"

echo "🔍 Process check:"
ps aux | grep vllm || echo "No vLLM processes running"
