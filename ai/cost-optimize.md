# AI API Cost Optimizer

Analyze and optimize AI/LLM API costs across the codebase.

## Arguments

$ARGUMENTS - Optional scope or focus area (e.g., "chatbot module", "all endpoints", or leave blank for full scan)

## Instructions

1. **Scan the codebase** for all LLM API calls:
   - Search for imports/usage of: `openai`, `anthropic`, `@anthropic-ai/sdk`, `cohere`, `@google/generative-ai`, Vercel AI SDK, LangChain, LlamaIndex.
   - Identify every call site: model used, prompt structure, token counts, frequency.
   - Map the call graph: which features trigger which LLM calls, and how often.

2. **Analyze current costs**:
   - For each call site, estimate tokens per request (system prompt + user input + output).
   - Multiply by estimated request volume (from logs, rate limits, or reasonable assumptions).
   - Calculate monthly cost per call site using current model pricing.
   - Identify the top 5 most expensive call sites.

3. **Suggest semantic caching**:
   - Identify calls with repetitive or similar inputs (FAQ responses, boilerplate generation, classification).
   - Recommend caching strategy: exact match (hash-based) or semantic similarity (embedding + threshold).
   - Provide implementation: cache layer with TTL, cache key generation, hit/miss logging.
   - Estimate cache hit rate and cost savings.

4. **Suggest prompt compression**:
   - Find prompts with redundant instructions, overly verbose examples, or repeated context.
   - Recommend: shorter system prompts, compressed few-shot examples, dynamic context injection (only include relevant context).
   - Estimate token reduction per call.

5. **Suggest model routing**:
   - Identify calls where a cheaper/smaller model would suffice (simple classification, formatting, extraction).
   - Recommend a routing strategy: use fast/cheap model by default, escalate to powerful model on low-confidence results.
   - Provide a router implementation with configurable thresholds.
   - Map each call site to recommended model tier.

6. **Suggest batch processing**:
   - Identify calls that could be batched (multiple items processed individually that could be combined).
   - Recommend batch API usage where available (OpenAI Batch API, Anthropic message batches).
   - Estimate latency vs. cost tradeoff.

7. **Suggest streaming optimizations**:
   - Identify calls that stream but discard partial results (streaming to a variable, not to UI).
   - Recommend non-streaming for background processing (lower cost on some providers).
   - Identify calls that should stream but do not (user-facing responses with high latency).

8. **Generate cost optimization report**:
   - Table: call site, current model, current est. monthly cost, recommended change, projected monthly cost, savings %.
   - Total current estimated monthly cost vs. projected cost after all optimizations.
   - Priority-ordered action items (highest savings first).
   - Implementation effort estimate for each optimization (low/medium/high).

9. **Implement the highest-impact optimization** (the one with the best savings-to-effort ratio):
   - Write the code changes.
   - Add cost tracking middleware/wrapper that logs model, tokens, and cost per request.
   - Add a cost dashboard endpoint or log aggregation query.
