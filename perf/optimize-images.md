# Image Optimizer

Optimize all images in the project for performance: format conversion, compression, responsive sizing, and lazy loading.

## Arguments

$ARGUMENTS - Optional scope: directory path, file pattern, or leave blank for full project scan

## Instructions

1. **Detect the project type** by reading `package.json`, `pyproject.toml`, or equivalent. Identify the framework (Next.js, React, Vue, static site, etc.).

2. **Scan for all images**:
   - Find all image files: `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`, `.webp`, `.avif`, `.ico`.
   - If `$ARGUMENTS` specifies a scope, limit the scan to that directory/pattern.
   - Record each image: path, format, file size, dimensions (if determinable from metadata).
   - Identify where each image is referenced in the codebase (HTML, CSS, JS/TS components).

3. **Convert to modern formats**:
   - **WebP**: Recommend converting all JPEG/PNG to WebP for broad browser support (95%+ coverage).
   - **AVIF**: Recommend AVIF for best compression where browser support is acceptable.
   - Use `<picture>` element with fallbacks: AVIF -> WebP -> original format.
   - For Next.js: verify `next/image` is used (automatic format negotiation).
   - For other frameworks: configure build-time conversion using `sharp`, `imagemin`, or equivalent.

4. **Resize oversized images**:
   - Identify images where the file dimensions are significantly larger than their display size.
   - Generate multiple sizes for responsive `srcset`: common breakpoints (320w, 640w, 768w, 1024w, 1280w, 1920w).
   - Set `sizes` attribute to match the actual layout behavior.
   - For hero/banner images: cap at 1920px width max.
   - For thumbnails: cap at 2x display size for retina.

5. **Compress images**:
   - Lossy compression for photographs (JPEG quality 80, WebP quality 80).
   - Lossless compression for screenshots, diagrams, icons.
   - SVG optimization: run through SVGO to remove metadata, simplify paths, minify.
   - Set up automated compression in the build pipeline.

6. **Implement lazy loading**:
   - Add `loading="lazy"` to all images below the fold.
   - Keep `loading="eager"` (or no attribute) for above-the-fold images (LCP candidates).
   - Add `decoding="async"` to non-critical images.
   - For Next.js: use `priority` prop on LCP image, `loading="lazy"` is default for others.

7. **Prevent CLS (Cumulative Layout Shift)**:
   - Ensure every `<img>` has explicit `width` and `height` attributes.
   - Use CSS `aspect-ratio` for responsive images.
   - For dynamically loaded images: use placeholder with matching dimensions.

8. **Implement LQIP (Low-Quality Image Placeholders)**:
   - Generate tiny blurred placeholders (10-20px wide, base64-encoded).
   - Show placeholder immediately, crossfade to full image on load.
   - For Next.js: use `placeholder="blur"` with `blurDataURL`.
   - For other frameworks: implement with CSS blur filter and JS load event.

9. **Generate optimization report**:
   - Table: image path, original size, optimized size, savings %, optimizations applied.
   - Total original size vs. optimized size.
   - Estimated page load improvement.
   - List of images that could not be optimized (already optimal, SVG animations, etc.).

10. **Implement the changes**: Apply all optimizations, update image references in the codebase, and verify the build succeeds.
