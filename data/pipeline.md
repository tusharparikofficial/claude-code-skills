# Data Processing Pipeline

Build a data processing pipeline with extraction, transformation, validation, and loading.

## Arguments

$ARGUMENTS - Description of the pipeline (e.g., "ingest CSV sales data, normalize, validate, load to Postgres")

## Instructions

1. **Detect the project's language and framework** by reading `package.json`, `pyproject.toml`, `go.mod`, or equivalent.

2. **Design the pipeline stages** based on `$ARGUMENTS`:
   - **Source connectors**: Identify data sources (files, APIs, databases, message queues). Create a connector interface with `connect()`, `read()`, `close()` methods.
   - **Extraction**: Read raw data from each source. Handle pagination for APIs, streaming for large files, cursor-based reads for databases.
   - **Transformation**: Map, filter, aggregate, join, reshape. Each transform is a pure function: input data in, transformed data out, no side effects.
   - **Validation**: Schema validation (required fields, types, ranges). Business rule validation (cross-field checks, referential integrity). Collect validation errors without stopping the pipeline.
   - **Loading**: Write to destination (database, file, API, data warehouse). Support upsert, append, and replace modes.

3. **Implement the pipeline orchestrator**:
   - Chain stages: Source -> Extract -> Transform -> Validate -> Load.
   - Support backpressure: if the loader is slow, pause extraction.
   - Process in batches (configurable batch size, default 1000 records).
   - Track progress: records processed, records failed, current stage, elapsed time.

4. **Add error handling**:
   - Dead letter queue: failed records go to a separate store with error details for manual review.
   - Retry logic: transient errors (network, rate limit) retry with exponential backoff.
   - Circuit breaker: if error rate exceeds threshold (e.g., 10%), pause pipeline and alert.
   - Each stage catches its own errors and reports them without crashing the pipeline.

5. **Add scheduling** (optional based on project needs):
   - Cron-based scheduling using node-cron, APScheduler, or system cron.
   - Support manual trigger via CLI or API endpoint.
   - Idempotent runs: re-running the same time window produces the same result.
   - Watermark tracking: remember the last successfully processed timestamp/ID.

6. **Add observability**:
   - Structured logging at each stage: records in, records out, records failed, duration.
   - Metrics: throughput (records/sec), error rate, stage latency.
   - Health check endpoint showing pipeline status and last run summary.

7. **Write tests**:
   - Unit test each transform function with sample data.
   - Unit test validation rules with valid and invalid records.
   - Integration test the full pipeline with a small dataset and test database.
   - Test error handling: simulate source failure, validation failure, loader failure.

8. **Create a CLI interface**:
   - `run` - Execute the pipeline.
   - `run --dry-run` - Execute extraction and transformation but skip loading.
   - `status` - Show last run status and metrics.
   - `retry-failed` - Reprocess records from the dead letter queue.
