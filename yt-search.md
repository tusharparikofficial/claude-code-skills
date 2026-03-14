# YouTube Video Search

Search YouTube for videos and return metadata using yt-dlp.

## Arguments

$ARGUMENTS - The search query (required). Optionally prefix with a number and a colon to set max results, e.g. "10:python tutorials"

## Instructions

Parse the arguments:
- If the input matches the pattern `<number>:<query>`, use `<number>` as the max results and `<query>` as the search term.
- Otherwise, default to 5 results and use the full input as the query.

Run the `clnote` CLI tool to search YouTube:

```bash
clnote --json search -n <max_results> "<query>"
```

If `clnote` is not found, fall back to using yt-dlp directly:

```bash
yt-dlp --dump-json --flat-playlist "ytsearch<max_results>:<query>" 2>/dev/null
```

## Output Format

Present results as a clean numbered list with:
- Title (bold)
- Channel name
- View count (human-readable: K, M)
- Duration
- Upload date
- URL

If `--json` was used, also show the raw JSON.

If the search returns no results, say so clearly.
If there's an error, show the error message and suggest the user check their query or network connection.
