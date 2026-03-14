# YouTube Video Info

Get detailed metadata for a specific YouTube video using yt-dlp.

## Arguments

$ARGUMENTS - A YouTube video URL or video ID (required)

## Instructions

Run the `clnote` CLI tool to get video metadata:

```bash
clnote --json info "<url_or_id>"
```

If `clnote` is not found, fall back to yt-dlp directly:

```bash
yt-dlp --dump-json --skip-download "<url_or_id>" 2>/dev/null
```

## Output Format

Present the metadata as a detailed card:
- **Title**
- **Channel** (with channel ID)
- **Views** (human-readable)
- **Likes**
- **Duration**
- **Upload Date**
- **URL**
- **Thumbnail URL**
- **Description** (first 300 characters, with "..." if truncated)
- **Tags** (comma-separated, if available)

If the video is not found or unavailable, say so clearly with the error reason.
