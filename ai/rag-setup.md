# RAG Pipeline Setup

Set up a complete Retrieval Augmented Generation (RAG) pipeline with document loading, chunking, embedding, vector storage, and retrieval.

## Arguments

$ARGUMENTS - `<doc-source>`: The document source — a local directory path, URL, or database connection string.

## Instructions

1. **Analyze the document source** provided in `$ARGUMENTS`:
   - If it is a directory: identify file types (PDF, Markdown, HTML, TXT, DOCX, code files).
   - If it is a URL: determine if it is a single page, sitemap, or API endpoint.
   - If it is a database: identify the table/collection and relevant text columns.

2. **Detect the project stack**:
   - Check `package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, or `Cargo.toml` to determine the language and framework.
   - Choose libraries accordingly (LangChain/LlamaIndex for Python, LangChain.js for Node.js).

3. **Set up document loading**:
   - Create a document loader module for the detected source type.
   - For directories: recursive file reader with type-specific parsers (pdf-parse, mammoth for DOCX, marked for Markdown).
   - For URLs: web scraper with rate limiting and robots.txt respect.
   - For databases: query-based loader with pagination.
   - Extract metadata (filename, source URL, page number, last modified date).

4. **Implement text chunking**:
   - Use recursive character text splitter as the default strategy.
   - Configure chunk size: start with 512 tokens for Q&A, 1024 for summarization.
   - Set chunk overlap: 10-20% of chunk size (e.g., 50-100 tokens for 512 chunk size).
   - Preserve document structure — do not split mid-sentence or mid-paragraph when possible.
   - Attach metadata to each chunk: source document, chunk index, section heading.
   - Create a configuration file so chunk size and overlap are tunable without code changes.

5. **Generate embeddings**:
   - Default to OpenAI `text-embedding-3-small` (cost-effective, good quality).
   - Provide alternative configurations for: Anthropic Voyage, Cohere embed-v3, local models (sentence-transformers).
   - Implement batch embedding with rate limiting and retry logic.
   - Cache embeddings to avoid re-computing on unchanged documents.
   - Store embedding model name alongside vectors for future migration.

6. **Set up vector storage**:
   - Detect if PostgreSQL is already in the project — if yes, use pgvector extension.
   - Otherwise, default to Chroma (local development) with Pinecone configuration for production.
   - Create the vector store schema/collection with:
     - Vector column/field with appropriate dimensions (1536 for OpenAI, adjust for others).
     - Metadata columns (source, chunk_index, created_at).
     - HNSW index for fast approximate nearest neighbor search.
   - Implement upsert logic for incremental updates (hash content to detect changes).

7. **Implement retrieval**:
   - Create a retrieval function that accepts a query string and returns top-k relevant chunks.
   - Default k=5, make configurable.
   - Implement similarity search using cosine similarity.
   - Add hybrid search combining semantic similarity with keyword matching (BM25):
     - Score = alpha * semantic_score + (1 - alpha) * keyword_score.
     - Default alpha = 0.7, make configurable.
   - Implement metadata filtering (filter by source, date range, document type).
   - Add Maximal Marginal Relevance (MMR) option to reduce redundancy in results.

8. **Build the RAG chain**:
   - Create a function that:
     1. Takes a user query.
     2. Retrieves relevant chunks via the retrieval function.
     3. Constructs a prompt with system instructions, retrieved context, and the user query.
     4. Sends to LLM (Claude or GPT) for response generation.
     5. Returns the response with source citations.
   - System prompt template should instruct the LLM to:
     - Only answer based on provided context.
     - Cite sources by document name and chunk.
     - Say "I don't have enough information" when context is insufficient.

9. **Add evaluation metrics**:
   - Implement retrieval evaluation:
     - Relevance scoring: are retrieved chunks relevant to the query?
     - Coverage: does the retrieved context contain the answer?
   - Implement response evaluation:
     - Faithfulness: does the response only use information from the context?
     - Answer relevance: does the response actually answer the question?
   - Create a simple eval script that runs test queries and logs metrics.

10. **Create configuration and documentation**:
    - Environment variables: API keys, database URLs, model names.
    - Configuration file with all tunable parameters (chunk size, overlap, k, alpha, model).
    - Add a seed/index script to process documents and populate the vector store.
    - Add a query script or API endpoint to test the pipeline end-to-end.

11. **Verify the implementation**:
    - Run the document loading and chunking on the provided source.
    - Verify embeddings are generated and stored correctly.
    - Test retrieval with a sample query.
    - Confirm the full RAG chain produces a cited response.
