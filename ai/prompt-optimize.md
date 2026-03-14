# Prompt Optimizer

Analyze and optimize LLM prompts for clarity, effectiveness, and reliability.

## Arguments

$ARGUMENTS - The prompt text to optimize, or a file path containing the prompt

## Instructions

1. **Load the prompt**:
   - If `$ARGUMENTS` is a file path, read the file contents.
   - If `$ARGUMENTS` is inline text, use it directly.
   - Identify the prompt's purpose: classification, extraction, generation, reasoning, or multi-step.

2. **Analyze the current prompt** for weaknesses:
   - **Clarity**: Are instructions ambiguous? Are there conflicting directives?
   - **Specificity**: Does it tell the model exactly what format/structure to output?
   - **Examples**: Are there few-shot examples? Are they representative and diverse?
   - **Edge cases**: Does the prompt handle unusual inputs gracefully?
   - **Grounding**: Does it minimize hallucination risk with explicit constraints?
   - **Token efficiency**: Is the prompt unnecessarily verbose?
   - Rate each dimension 1-5 and explain the rating.

3. **Apply optimization techniques**:
   - **Chain-of-thought**: Add "Think step by step" or structured reasoning sections where the task requires logic.
   - **Few-shot examples**: Add 2-3 diverse examples covering normal cases, edge cases, and expected refusals.
   - **Structured output**: Add explicit output format specification (JSON schema, markdown template, or labeled sections).
   - **Role assignment**: Add a clear system prompt role if missing ("You are a...").
   - **Constraint specification**: Add explicit constraints for length, tone, format, and what NOT to do.
   - **Input/output delimiters**: Use clear delimiters (XML tags, triple backticks) to separate instructions from input.

4. **Generate the optimized prompt**:
   - Write the improved version with all optimizations applied.
   - Add inline comments explaining each change and why it improves the prompt.
   - Preserve the original intent exactly -- do not change what the prompt asks for.

5. **Create evaluation test cases**:
   - Generate 5-10 test inputs that cover:
     - Happy path (2-3 typical inputs).
     - Edge cases (empty input, very long input, ambiguous input).
     - Adversarial cases (prompt injection attempts, off-topic requests).
     - Boundary conditions (minimum/maximum expected values).
   - For each test input, write the expected output or expected behavior.
   - Format as a structured test suite that can be run programmatically.

6. **Create a comparison report**:
   - Show the original prompt and optimized prompt side by side.
   - List each change made and the reasoning.
   - Estimate the expected improvement in reliability and output quality.
   - Note any tradeoffs (e.g., longer prompt = higher cost but better results).

7. **Output the optimized prompt** to a file alongside the test cases. Use the same directory as the original prompt file, or the project root if the prompt was inline.
