# Document Embedding Pipeline

Build a document embedding pipeline for semantic search and retrieval.

## Arguments

$ARGUMENTS - Source type: pdf, markdown, html, code, or a combination (e.g., "pdf and markdown")

## Instructions

1. **Detect the project's language and framework** by reading `package.json`, `pyproject.toml`, `go.mod`, or equivalent.

2. **Implement document loaders** based on `$ARGUMENTS`:
   - **PDF**: Use `pdf-parse` (Node) or `PyPDF2`/`pdfplumber` (Python). Extract text, preserve page numbers.
   - **Markdown**: Parse with `remark`/`unified` (Node) or `markdown-it` (Python). Preserve heading hierarchy.
   - **HTML**: Strip tags, extract main content using `cheerio` (Node) or `BeautifulSoup` (Python). Skip nav/footer/scripts.
   - **Code**: Parse by file type. Preserve function/class boundaries. Include file path as metadata.
   - Each loader returns: `{ content: string, metadata: { source, page?, heading?, fileType? } }`.

3. **Implement text splitter**:
   - Split by semantic boundaries first (paragraphs, sections, functions), then by token count.
   - Configure chunk size (default 512 tokens) and overlap (default 50 tokens).
   - Preserve metadata through splits (source file, page number, section heading).
   - Never split mid-sentence. Use sentence boundary detection.
   - Add chunk index to metadata for ordering.

4. **Set up embedding model**:
   - Support multiple providers: OpenAI `text-embedding-3-small`, Cohere `embed-english-v3.0`, or local models via `@xenova/transformers` / `sentence-transformers`.
   - Create an embedding interface so the provider can be swapped.
   - Normalize embeddings to unit vectors for cosine similarity.
   - Cache embeddings by content hash to avoid recomputing unchanged documents.

5. **Set up vector database storage**:
   - Support at least one of: Pinecone, Weaviate, Qdrant, ChromaDB, pgvector.
   - Create a vector store interface with: `upsert(id, vector, metadata)`, `search(query, topK, filter?)`, `delete(id)`.
   - Store metadata alongside vectors for filtering and display.
   - Use namespaces/collections to separate different document sets.

6. **Implement batch processing**:
   - Process documents in batches to respect API rate limits.
   - Add progress tracking (documents processed, chunks created, embeddings generated).
   - Implement retry logic for failed API calls with exponential backoff.
   - Support incremental updates: only re-embed changed documents (compare content hashes).

7. **Implement similarity search**:
   - Accept a query string, embed it, search the vector store.
   - Return top-K results with similarity scores and full metadata.
   - Support metadata filtering (by source, date, file type).
   - Implement hybrid search if the vector DB supports it (combine semantic + keyword).
   - Add a relevance threshold to filter low-quality matches.

8. **Create CLI / API interface**:
   - `ingest <path>` - Process and embed documents from a directory.
   - `search <query>` - Run similarity search and display results.
   - `status` - Show index stats (document count, last updated).
   - Support environment variable configuration for API keys and DB connection.

9. **Write tests**:
   - Test each document loader with sample files.
   - Test text splitter: correct chunk sizes, overlap, metadata preservation.
   - Test embedding + search round-trip with a small in-memory vector store.
   - Test incremental update: modify a document, re-ingest, verify only changed chunks update.
