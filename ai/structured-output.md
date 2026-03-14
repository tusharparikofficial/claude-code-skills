# Structured LLM Output

Generate structured, type-safe output from LLM calls with validation and retry logic.

## Arguments

$ARGUMENTS - Description of the schema or data structure to extract (e.g., "product review with sentiment, rating, pros, cons")

## Instructions

1. **Detect the project's language and framework** by reading `package.json`, `pyproject.toml`, `go.mod`, or equivalent.

2. **Define the output schema** based on `$ARGUMENTS`:
   - **TypeScript/JavaScript**: Create a Zod schema with `.describe()` annotations on each field. Export the schema and inferred type (`z.infer<typeof Schema>`).
   - **Python**: Create a Pydantic `BaseModel` with `Field(description=...)` on each field. Add `model_config` with `json_schema_extra` examples.
   - Include all relevant field types: strings, numbers, booleans, enums, arrays, nested objects.
   - Add validation constraints: min/max length, regex patterns, numeric ranges, array bounds.

3. **Implement the structured output call**:
   - Use the LLM provider's JSON mode or structured output feature:
     - **OpenAI**: `response_format: { type: "json_schema", json_schema: { ... } }`
     - **Anthropic**: Use tool_use with the schema as the tool's input_schema, or parse JSON from the response.
     - **Vercel AI SDK**: `generateObject()` with the Zod schema.
   - Pass the schema definition in the system prompt or as a response format parameter.
   - Include 1-2 few-shot examples in the prompt showing the expected JSON structure.

4. **Add validation and retry logic**:
   - Parse the LLM response and validate against the schema.
   - On validation failure:
     - Extract the validation error messages.
     - Retry the LLM call with the original prompt plus the validation errors appended (max 3 retries).
     - Use exponential backoff between retries.
   - On repeated failure, return a typed error result (not an exception).

5. **Create a reusable wrapper function**:
   - Accept any schema, prompt, and optional config (maxRetries, model, temperature).
   - Return a discriminated union / result type (success with data, or failure with error details).
   - Log each attempt: prompt tokens, completion tokens, validation outcome.

6. **Add type-safe response handling**:
   - Export TypeScript types / Python type hints inferred from the schema.
   - Provide helper functions for common post-processing: normalization, enum mapping, default filling.
   - Ensure the caller gets full IDE autocomplete on the returned object.

7. **Write tests**:
   - Unit test the schema validation with valid and invalid inputs.
   - Unit test the retry logic with mocked LLM responses (first call returns malformed JSON, second succeeds).
   - Test edge cases: empty strings, null fields, extra fields, deeply nested objects.

8. **Provide usage examples** in a comment block at the top of the main file showing how to call the function and handle the result.
