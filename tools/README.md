# Metric Tools

`tools/` contains the metric implementations used by CCL-Bench. A metric consumes a trace directory and returns a scalar value that can be displayed in the website table.

## Running A Metric

From the repository root:

```bash
python tools/main.py --trace /path/to/trace_dir --metric avg_step_time
```

The trace directory should contain the workload card and any profiler artifacts needed by the selected metric, such as Kineto JSON, XLA trace JSON, Nsight Systems SQLite exports, or benchmark latency JSON files.

## Metric Interface

Each metric lives in its own subdirectory and exposes a callable function used by `tools/main.py`, usually:

```python
def metric_cal(trace_dir: str) -> float:
    ...
```

Metric implementations should:

- validate that the trace directory contains the artifacts they need;
- return `None` when a metric is not applicable to a trace;
- avoid modifying trace artifacts;
- document which profiler format they expect;
- keep units explicit in the README or code comments.

If a metric should appear on the website, add it to `website/benchmark_config.json` and regenerate `website/benchmark_data.json` plus `website/data.js`.

## Available Metrics

All metrics registered in `tools/main.py`, grouped by category. Metric names with group suffixes are kept as-is to avoid breaking existing website configuration and prior benchmark rows.

### Step / Timing

| Metric | Meaning |
| --- | --- |
| `avg_step_time` | Average per-step or per-engine-iteration wall time from trace annotations. |
| `wall_time_s` | Total wall time in seconds (group-21 trace JSON). |
| `total_compute_time_s` | Total compute time in seconds (group-21 trace JSON). |
| `total_trace_time` | Total span of the trace from first to last event. |
| `total_kernel_time` | Sum of all kernel durations in the trace. |
| `break_down_steps` | Per-phase step breakdown returning multiple values. |

### Inference Latency

| Metric | Meaning |
| --- | --- |
| `ttft` | Time to first token from benchmark latency JSON. |
| `tpot` | Time per output token from benchmark latency JSON. |
| `ttft_group_6` | Time to first token (group-6 Nsight Systems implementation). |
| `tpot_group_6` | Time per output token (group-6 Nsight Systems implementation). |

### Utilization / Efficiency

| Metric | Meaning |
| --- | --- |
| `mfu` | Model FLOP utilization from workload-card metadata and measured time. |
| `mean_sm_coverage` | Average streaming-multiprocessor coverage from GPU kernel trace data. |
| `aggregate_gpu_utilization` | Aggregate GPU utilization across all observed kernels. |
| `compute_utilization_proxy` | Ratio of active compute time to wall time (group-21). |
| `gpu_step_score` | Composite GPU step efficiency score. |
| `dominant_kernel_concentration` | Fraction of kernel time spent in the single most dominant kernel. |
| `moe_fraction` | Fraction of kernel time attributed to MoE-related kernels. |
| `memory_bound_fraction` | Fraction of kernel time that is memory-bound. |
| `kernel_compute_time_group_6` | Total compute kernel time from Nsight Systems data (group-6). |

### Communication

| Metric | Meaning |
| --- | --- |
| `communication_fraction` | Fraction of traced time in communication kernels or events. |
| `communication_ratio` | Alternative communication time ratio. |
| `communication_overlap_ratio` | Fraction of communication time that overlaps with compute. |
| `compute_comm_overlap` | Estimated overlap between compute and communication intervals. |
| `total_communication_time` | Total traced communication time (Nsight Systems). |
| `total_comm_time_s` | Total communication time in seconds (group-21 trace JSON). |
| `avg_comm_kernel_time_s` | Average communication kernel duration in seconds (group-21). |
| `allreduce_comm_time_s` | Total AllReduce communication time in seconds (group-21). |
| `num_comm_kernels` | Count of communication kernels observed in the trace (group-21). |
| `coll_call_num` | Number of collective communication calls. |
| `communication_overhead` | Communication overhead fraction (group-1). |
| `comm_kernel_breakdown_tpu` | Per-collective breakdown of communication kernel time (TPU, group-4). |
| `straggler` | Straggler delay scalar (returns delay only). |
| `straggler_metrics` | Straggler delay and slowdown printed together (legacy). |
| `load_imbalance_ratio` | Load imbalance ratio across ranks. |
| `traffic_window` | Windowed traffic analysis for communication bursts (group-1). |

### Bandwidth

| Metric | Meaning |
| --- | --- |
| `average_memory_bandwidth` | Average explicit memory transfer bandwidth (bytes and duration from trace). |
| `memory_transfer_overhead` | Fraction of time spent in explicit memory transfers. |
| `avg_comm_bandwidth_GBps` | Average communication bandwidth in GB/s (group-21). |
| `bandwidth_utilization_allgather_group_6` | Estimated AllGather bandwidth utilization (group-6). |
| `bandwidth_utilization_allreduce_group_6` | Estimated AllReduce bandwidth utilization (group-6). |
| `bandwidth_utilization_alltoall_group_6` | Estimated AllToAll bandwidth utilization (group-6). |
| `bandwidth_utilization_reducescatter_group_6` | Estimated ReduceScatter bandwidth utilization (group-6). |
| `bandwidth_utilization_peertopeer_group_6` | Estimated point-to-point bandwidth utilization (group-6). |
| `bandwidth_utilization` | Bandwidth utilization (group-1). |
| `scale_up_bw_utility` | Scale-up bandwidth utility metric. |
| `estimated_bandwidth` | Estimated bandwidth from TPU collective timing (group-4). |

### Collective Data Volume

| Metric | Meaning |
| --- | --- |
| `collective_vol_allreduce_gb` | Total AllReduce data volume in GB. |
| `collective_vol_allgather_gb` | Total AllGather data volume in GB. |
| `collective_vol_reducescatter_gb` | Total ReduceScatter data volume in GB. |
| `collective_vol_alltoall_gb` | Total AllToAll data volume in GB. |
| `collective_vol_total_gb` | Total collective communication data volume in GB. |

### Hockney Model

| Metric | Meaning |
| --- | --- |
| `hockney_alpha_s` | Hockney latency term (alpha) in seconds (group-21). |
| `hockney_beta_s_per_byte` | Hockney inverse-bandwidth term (beta) in seconds per byte (group-21). |
| `hockney_inverse_beta_Bps` | Hockney effective bandwidth (1/beta) in bytes per second (group-21). |

### FLOPs / Throughput

| Metric | Meaning |
| --- | --- |
| `achieved_flops_from_trace_json` | Achieved FLOPs derived from trace annotations (group-21). |
| `total_model_flops_from_args` | Total model FLOPs estimated from workload arguments (group-21). |
| `throughput` | Training throughput (tokens/s or samples/s, group-21). Accepts `--model_params`. |
| `throughput_group_6` | Throughput metric (group-6 implementation). |
| `estimated_throughput_tokens_per_s` | Estimated throughput in tokens per second (group-21). |
| `flops_per_token_used` | Effective FLOPs consumed per output token (group-21). |
| `estimated_total_tokens` | Estimated total tokens processed in the trace (group-21). |

### Dashboard Metrics

The current public dashboard is driven by the metrics configured in `website/benchmark_config.json`. Not every metric above appears on the public leaderboard — only those listed in that config file are rendered in the website table.

## Trace Compatibility

Not every metric applies to every trace:

- Kineto or XLA JSON traces are typically used for step-time style metrics.
- Nsight Systems SQLite exports are used for GPU kernel and communication breakdowns.
- vLLM or SGLang benchmark JSON files may provide request-level latency fields.
- Workload cards provide model architecture, phase, parallelism, and hardware metadata.

Metric tools should fail clearly when an expected artifact is missing and should return `None` for intentionally unsupported trace types.

## Adding A Metric

1. Create `tools/<metric_name>/`.
2. Implement the metric function and any small helper functions.
3. Add a short README or module docstring describing required trace artifacts and units.
4. Register the metric in `tools/main.py`.
5. Add a small fixture or documented manual check when possible.
6. Add the metric to `website/benchmark_config.json` only if it should be shown on the public leaderboard.

Keep raw traces and generated profiler dumps out of git unless they are tiny fixtures created specifically for testing.
