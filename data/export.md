# Data Export System

Build a data export system supporting multiple formats with streaming for large datasets.

## Arguments

$ARGUMENTS - Export format: csv, excel, pdf, json, or a combination (e.g., "csv and excel")

## Instructions

1. **Detect the project's language and framework** by reading `package.json`, `pyproject.toml`, `go.mod`, or equivalent.

2. **Create the export interface**:
   - Define an `ExportOptions` type: `{ format, columns?, filters?, sort?, filename?, maxRows? }`.
   - Define an `ExportResult` type: `{ filePath, fileSize, rowCount, duration }`.
   - Create an `Exporter` interface with `export(data, options) -> ExportResult`.

3. **Implement format-specific exporters** based on `$ARGUMENTS`:
   - **CSV**: Use streaming writes (`csv-stringify` for Node, `csv` module for Python). Handle special characters, escaping, BOM for Excel compatibility.
   - **Excel**: Use `exceljs` (Node) or `openpyxl` (Python). Support multiple sheets, column formatting, auto-width, header styling, frozen panes.
   - **PDF**: Use `pdfkit` or `puppeteer` (Node), `reportlab` or `weasyprint` (Python). Table layout, pagination, headers/footers, page numbers.
   - **JSON**: Stream JSON arrays for large datasets. Support JSON Lines (JSONL) format for line-by-line processing. Pretty-print option.

4. **Add streaming for large datasets**:
   - Never load the entire dataset into memory. Use cursor-based or offset pagination from the data source.
   - Stream rows through a transform pipeline: query -> format -> write to file.
   - Set a configurable memory limit. If a single export would exceed it, enforce chunking.
   - Show progress: rows exported / total rows, estimated time remaining.

5. **Add column selection and filtering**:
   - Accept a list of column names to include (default: all columns).
   - Support column renaming in the export (display names different from field names).
   - Apply filters before export (date range, status, category, etc.).
   - Apply sorting before export.

6. **Add progress tracking**:
   - For synchronous exports: return progress percentage via callback or event emitter.
   - For async exports: create a job record with status (queued, processing, complete, failed) and progress percentage.
   - Support polling or WebSocket for real-time progress updates.

7. **Generate download links**:
   - Store exported files in a temporary directory or object storage (S3, GCS).
   - Generate a signed/expiring download URL (default 1 hour TTL).
   - Return the URL to the client immediately after export completes.

8. **Add cleanup**:
   - Automatically delete exported files after TTL expires.
   - Run cleanup on a schedule (cron job or startup check).
   - Track disk usage and alert if temp directory exceeds threshold.

9. **Write tests**:
   - Test each format exporter with small sample data, verify output is valid.
   - Test column selection: only selected columns appear in output.
   - Test filtering: only matching rows appear in output.
   - Test streaming: export a dataset larger than memory limit, verify output completeness.
   - Test cleanup: verify files are deleted after TTL.
