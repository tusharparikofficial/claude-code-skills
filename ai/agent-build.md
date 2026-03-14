# AI Agent Builder

Build an AI agent with tool use, planning, memory, and human-in-the-loop checkpoints.

## Arguments

$ARGUMENTS - Description of the agent's purpose (e.g., "research agent that searches the web and summarizes findings")

## Instructions

1. **Detect the project's language and framework** by reading `package.json`, `pyproject.toml`, `go.mod`, or equivalent.

2. **Define the agent's capabilities** based on `$ARGUMENTS`:
   - List the tools the agent needs (web search, file read, API calls, database queries, code execution, etc.).
   - Define the agent's system prompt with role, constraints, and output format.
   - Identify which actions require human approval.

3. **Implement the agent loop**:
   - Create the core loop: receive input -> think/plan -> select tool -> execute tool -> observe result -> repeat or respond.
   - Set a maximum iteration limit (default 10) to prevent runaway loops.
   - Implement a `shouldStop` check after each iteration: task complete, error threshold, or iteration limit.
   - Support both streaming and non-streaming execution modes.

4. **Define tools**:
   - Create a `Tool` interface/type with: `name`, `description`, `parameters` (JSON Schema or Zod/Pydantic), `execute` function.
   - Implement each tool as a separate module/file.
   - Add input validation on every tool call before execution.
   - Add timeout and error handling per tool.
   - Return structured results from each tool (not raw strings).

5. **Add memory and context management**:
   - **Short-term**: Conversation history with sliding window or token-count truncation.
   - **Long-term** (optional): Vector store for past interactions, summaries of completed tasks.
   - Implement context compression: summarize older messages when context grows large.
   - Track token usage to stay within model limits.

6. **Add planning prompts**:
   - Before tool execution, have the agent output a plan (chain-of-thought).
   - After tool results, have the agent reflect on whether the result advances the goal.
   - Support plan revision when new information changes the approach.

7. **Implement human checkpoints**:
   - Mark specific tool calls or actions as requiring human approval.
   - Pause execution and present the proposed action to the user.
   - Accept approve/reject/modify responses.
   - Log all checkpoint decisions for audit.

8. **Add observability**:
   - Log every step: thought, tool selected, tool input, tool output, tokens used.
   - Track total cost across all LLM calls in the agent run.
   - Emit events/callbacks for UI integration (step started, step completed, waiting for approval).

9. **Error handling**:
   - Catch tool execution errors and feed them back to the agent for self-correction.
   - Implement retry logic with backoff for transient failures.
   - Graceful degradation: if a tool fails repeatedly, inform the agent to try an alternative approach.

10. **Write tests**:
    - Test the agent loop with mocked tools (tool returns predefined results).
    - Test iteration limit enforcement.
    - Test human checkpoint pause/resume.
    - Test error recovery (tool throws, agent retries).
