#!/bin/bash
# Two-tier hardware: 4 GPUs/node NVLink scale-up + Slingshot scale-out.

set -e
REPO=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
TRACE="$REPO/llama3-torchtitan-nccl-4gpu-fsdp_2-tp_2-b_4-s_512"
OUTDIR="$REPO/simulation/examples/01_baseline_output"

GPUS_PER_NODE=4
INTRA_BW=300
INTRA_LAT=500
INTER_BW=25
INTER_LAT=5000

python "$REPO/simulation/pipeline.py" \
    --mode comm-only \
    --trace-dir "$TRACE" \
    --output-dir "$OUTDIR" \
    --gpus-per-node "$GPUS_PER_NODE" \
    --intra-topology FullyConnected \
    --intra-bandwidth "$INTRA_BW" \
    --intra-latency "$INTRA_LAT" \
    --topology Switch \
    --bandwidth "$INTER_BW" \
    --latency "$INTER_LAT" \
    --collective-algo ring \
    --compute-model gap

echo
echo "Outputs in: $OUTDIR"
