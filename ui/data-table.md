# Build Advanced Data Table

Generate a feature-rich data table with sorting, filtering, pagination, selection, and export capabilities.

## Arguments

$ARGUMENTS - `<data-source>` the data source description (API endpoint, database table, or data shape/type)

## Instructions

1. Analyze the data source:
   - If an API endpoint is given, examine the response shape (or infer from the endpoint name)
   - If a database table or model is given, read the schema to determine columns
   - If a data shape/type is described, use it directly
   - Determine column names, data types, and which columns should be sortable/filterable

2. Detect the project's framework and choose the table implementation:
   - React: Use TanStack Table (`@tanstack/react-table`) if already installed, otherwise install it
   - Vue: Use TanStack Table for Vue or build custom with composables
   - If no framework is detected or the project prefers vanilla, build a custom implementation
   - Check for existing UI library (shadcn/ui, Radix, Headless UI, Vuetify) and use compatible components

3. Create the data table with these features:

### Column Definitions
   - Define columns with: accessor key, header label, data type, width (min/max/default)
   - Mark columns as sortable, filterable, or hideable
   - Support custom cell renderers for:
     - Dates (formatted display)
     - Numbers (formatted with locale)
     - Booleans (icon or badge)
     - Status values (colored badges)
     - Actions column (edit, delete, view buttons)
     - Links (clickable with proper href)

### Sorting
   - Click column header to sort (asc -> desc -> none)
   - Visual indicator for sort direction (arrow icon in header)
   - Multi-column sort support (hold Shift + click)
   - Server-side sorting: send sort parameters to API (`?sort=name&order=asc`)
   - Default sort configuration

### Filtering
   - Global search input that searches across all text columns
   - Per-column filters:
     - Text columns: text input with contains/starts-with/equals
     - Numeric columns: range input (min/max)
     - Date columns: date range picker
     - Enum/status columns: multi-select dropdown
     - Boolean columns: checkbox or toggle
   - Debounced filter input (300ms) to avoid excessive API calls
   - Server-side filtering: send filter parameters to API
   - Clear all filters button
   - Active filter count indicator

### Pagination (Server-Side)
   - Page size selector (10, 25, 50, 100 rows per page)
   - Page navigation: first, previous, page numbers, next, last
   - Show "Showing X-Y of Z results" text
   - Send pagination parameters to API (`?page=1&limit=25`)
   - Handle total count from API response
   - Preserve page when filters change (reset to page 1)
   - URL query parameter sync (page, sort, filters reflected in URL)

### Column Resize
   - Drag column border to resize
   - Double-click column border to auto-fit content width
   - Minimum column width constraint
   - Persist column widths to localStorage
   - Reset column widths option

### Row Selection
   - Checkbox column for row selection
   - Select all checkbox in header (selects current page or all pages with confirmation)
   - Shift+click for range selection
   - Selected row count indicator
   - Selected rows accessible via callback/state
   - Visual highlight on selected rows

### Bulk Actions
   - Action bar appears when rows are selected
   - Configurable bulk actions (delete, export, status change, etc.)
   - Confirmation dialog for destructive actions
   - Show progress for bulk operations
   - Clear selection after bulk action completes

### Export to CSV
   - Export button in table toolbar
   - Options: export current page, export all (filtered) results, export selected rows
   - Generate CSV with proper escaping (commas in values, quotes, newlines)
   - Use column headers as CSV headers
   - Trigger browser download with generated filename including date
   - Handle large datasets (stream or paginate through all results)

### Search
   - Global search bar above the table
   - Debounced input (300ms)
   - Highlight matching text in cells (optional)
   - Clear search button
   - Search across specified columns only

### Responsive Design (Card View on Mobile)
   - Desktop (>1024px): Standard table layout
   - Tablet (768-1024px): Horizontally scrollable table with shadow indicators
   - Mobile (<768px): Card view where each row becomes a card:
     - Key fields shown as card title/subtitle
     - Remaining fields as label-value pairs
     - Actions as buttons at card bottom
     - Selection checkbox in card corner
   - Toggle between table and card view (user preference)

4. Create supporting components:

### Table Toolbar
   - Search input
   - Filter toggles
   - Column visibility toggle (dropdown to show/hide columns)
   - Export button
   - Bulk action bar (when rows selected)
   - Results count

### Empty State
   - No data: friendly message with illustration placeholder
   - No results (filters active): "No results match your filters" with clear filters button
   - Error state: error message with retry button

### Loading State
   - Skeleton rows while data is loading
   - Loading indicator for sort/filter/page changes
   - Disable interactions while loading

5. Create the data fetching layer:
   - Custom hook/composable for table data fetching
   - Accepts: API endpoint, default sort, default page size
   - Manages: loading state, error state, data, total count
   - Sends: pagination, sort, filter, search parameters
   - Supports: refetch, invalidation
   - Debounces filter/search requests

6. Create TypeScript types:
   - Column definition type
   - Sort state type
   - Filter state type
   - Pagination state type
   - Table data response type (data array + total count + metadata)
   - Row data type (from data source)

7. Add accessibility:
   - Proper `<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>` semantics
   - `aria-sort` on sortable column headers
   - `aria-selected` on selected rows
   - Keyboard navigation: Arrow keys to move between cells, Enter to activate
   - Screen reader announcements for sort changes, page changes, selection changes
   - `role="status"` for results count and loading state

8. Print a summary of created files, features implemented, and usage instructions including how to customize columns and connect to the API.
