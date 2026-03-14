# AI Chatbot Builder

Build a full-featured AI chatbot with streaming responses, conversation history, tool calling, and a frontend chat UI.

## Arguments

$ARGUMENTS - `<provider>`: The AI provider to use — `anthropic` or `openai`.

## Instructions

1. **Detect the project stack**:
   - Check `package.json`, `requirements.txt`, `pyproject.toml`, or framework config files.
   - Determine if this is a Next.js, Express, FastAPI, Django, or other project.
   - Choose the appropriate SDK: `@anthropic-ai/sdk` or `openai` for Node.js, `anthropic` or `openai` for Python.

2. **Install dependencies**:
   - For Anthropic: install the Anthropic SDK for the detected language.
   - For OpenAI: install the OpenAI SDK for the detected language.
   - Install any additional dependencies for streaming (e.g., `eventsource-parser` for SSE parsing on the client).

3. **Create the chat API endpoint**:
   - Create a POST endpoint at `/api/chat` that accepts:
     - `messages`: array of `{ role, content }` objects.
     - `system`: optional system prompt override.
     - `model`: optional model override (default: `claude-sonnet-4-20250514` for Anthropic, `gpt-4o` for OpenAI).
     - `stream`: boolean, default true.
   - Implement streaming response using Server-Sent Events (SSE):
     - Set headers: `Content-Type: text/event-stream`, `Cache-Control: no-cache`, `Connection: keep-alive`.
     - Stream each text delta as an SSE event: `data: {"content": "..."}\n\n`.
     - Send a final `data: [DONE]\n\n` event.
   - Implement non-streaming fallback that returns the full response as JSON.
   - Add request validation: check that messages array is not empty, roles are valid.

4. **Set up system prompt configuration**:
   - Create a system prompt configuration file or constant.
   - Include a default system prompt with clear instructions for the chatbot's behavior.
   - Support dynamic system prompt loading (from database, file, or environment variable).
   - Allow per-conversation system prompt overrides via the API.

5. **Implement conversation history management**:
   - Create a conversation store (in-memory for development, with interface for database persistence).
   - Each conversation has: `id`, `title`, `messages[]`, `createdAt`, `updatedAt`, `metadata`.
   - Implement context window management:
     - Track token count of the conversation (use tiktoken for OpenAI, estimate for Anthropic).
     - When approaching the context limit, implement a sliding window: keep the system prompt and the most recent N messages.
     - Optionally summarize older messages before dropping them.
   - API endpoints: create conversation, list conversations, get conversation, delete conversation.

6. **Set up tool/function calling**:
   - Create a tool registry with a clean interface for defining tools:
     - Tool name, description, input schema (JSON Schema).
     - Handler function that executes the tool and returns a result.
   - Include example tools: web search, calculator, current date/time.
   - Implement the tool execution loop:
     - If the model returns a tool_use (Anthropic) or function_call (OpenAI), execute the tool.
     - Send the tool result back to the model.
     - Continue until the model produces a text response (set max iterations to 10).
   - Handle tool errors gracefully — send error messages back to the model rather than crashing.

7. **Add rate limiting**:
   - Implement per-user rate limiting (by IP or API key).
   - Default limits: 20 requests per minute, 100 requests per hour.
   - Return 429 status with `Retry-After` header when rate limit is exceeded.
   - Use a sliding window algorithm for smooth rate limiting.

8. **Implement cost tracking**:
   - Track token usage per request: input tokens, output tokens.
   - Calculate cost based on the model's pricing (store pricing as configuration).
   - Log per-request cost and maintain running totals per user/conversation.
   - Add a `/api/usage` endpoint to retrieve usage statistics.
   - Set optional spending limits with alerts.

9. **Add error handling and retry logic**:
   - Handle API errors: rate limits (429), server errors (500), timeout, network failures.
   - Implement exponential backoff retry: 3 attempts, starting at 1 second, with jitter.
   - Return user-friendly error messages — never expose raw API errors to the client.
   - Log detailed error context server-side for debugging.

10. **Build the frontend chat component**:
    - Create a chat UI component with:
      - Message list with role-based styling (user messages right-aligned, assistant left-aligned).
      - Message bubbles with proper spacing and visual hierarchy.
      - Markdown rendering in assistant messages (support code blocks, lists, links, bold/italic).
      - Code block syntax highlighting with a copy button.
      - Input area: multi-line text input with send button, submit on Enter (Shift+Enter for newline).
      - Loading indicator: typing dots or skeleton animation while waiting for response.
      - Streaming display: render text as it arrives, character by character.
      - Auto-scroll to bottom on new messages, with scroll-to-bottom button when scrolled up.
      - Conversation sidebar: list of past conversations with titles, click to load.
    - Responsive design: works on mobile and desktop.
    - Keyboard shortcuts: Ctrl+N for new conversation, Escape to clear input.

11. **Wire frontend to backend**:
    - Create an API client module that handles:
      - SSE streaming with `fetch` and `ReadableStream` (or `EventSource`).
      - Parsing streamed chunks and updating the UI incrementally.
      - Abort controller to cancel in-flight requests (stop generating button).
      - Error handling and display in the chat UI.
    - Manage client-side state: current conversation, message list, loading state, error state.

12. **Add environment configuration**:
    - Required environment variables: API key for the chosen provider.
    - Optional: model name, max tokens, temperature, system prompt.
    - Create a `.env.example` file with all variables documented.
    - Validate that required environment variables are present at startup.

13. **Verify the implementation**:
    - Start the development server.
    - Test sending a message and receiving a streamed response.
    - Test conversation persistence (refresh page, conversation should reload).
    - Test error handling (invalid API key, network failure).
    - Test rate limiting triggers correctly.
