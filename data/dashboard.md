# Analytics Dashboard

Build an analytics dashboard with data fetching, metrics, charts, and filtering.

## Arguments

$ARGUMENTS - Data source type: postgres, api, csv, or a specific description (e.g., "postgres sales database")

## Instructions

1. **Detect the project's language and framework** by reading `package.json`, `pyproject.toml`, `go.mod`, or equivalent.

2. **Set up data fetching** based on `$ARGUMENTS`:
   - **Postgres**: Create a data access layer with parameterized queries. Use connection pooling. Support date range filters in queries.
   - **API**: Create an API client with retry logic, rate limiting, and response caching. Handle pagination.
   - **CSV**: Create a file parser with streaming for large files. Support column type inference.
   - All sources return a normalized format: `{ data: Record[], metadata: { total, lastUpdated } }`.

3. **Define metrics and KPIs**:
   - Analyze the data structure and suggest relevant metrics (totals, averages, growth rates, distributions).
   - Create metric calculation functions: each takes raw data and returns `{ value, label, change?, trend? }`.
   - Support time-series aggregation: daily, weekly, monthly rollups.
   - Add comparison periods: current vs. previous period, year-over-year.

4. **Build chart components**:
   - Use **Recharts** (React) or **Chart.js** (vanilla/any framework).
   - Create reusable chart components: LineChart, BarChart, PieChart, AreaChart.
   - Each chart accepts: `data`, `xKey`, `yKey`, `title`, `color`.
   - Add responsive sizing and loading states.
   - Include tooltips with formatted values.

5. **Build the dashboard layout**:
   - Top row: KPI cards showing key metrics with trend indicators.
   - Middle: Primary chart (time series) with date range selector.
   - Bottom: Secondary charts (distributions, comparisons) in a grid.
   - Responsive: stack vertically on mobile, grid on desktop.

6. **Add date range filtering**:
   - Preset ranges: Today, Last 7 days, Last 30 days, This month, This quarter, This year, Custom.
   - Custom date picker with start/end date inputs.
   - Apply filter to all data queries and re-render all charts.
   - Persist selected range in URL query params or local storage.

7. **Add CSV export**:
   - Export button on each chart and a global "Export All" button.
   - Generate CSV with headers matching the displayed data.
   - For large datasets, stream the CSV generation.
   - Include the current filter settings in the filename.

8. **Add real-time refresh** (optional):
   - Auto-refresh toggle with configurable interval (30s, 1m, 5m).
   - Show last-updated timestamp.
   - Animate data transitions on refresh.
   - Pause auto-refresh when tab is inactive.

9. **Write tests**:
   - Test metric calculation functions with known data.
   - Test date filtering logic.
   - Test CSV export output format.
   - Test chart components render without errors (smoke tests).
