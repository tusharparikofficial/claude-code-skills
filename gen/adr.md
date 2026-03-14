# Create Architecture Decision Record

Create an Architecture Decision Record (ADR) documenting a significant architectural decision.

## Arguments

$ARGUMENTS - Required: the title of the architectural decision (e.g., "Use PostgreSQL for primary database", "Adopt microservices architecture", "Switch from REST to GraphQL").

## Instructions

1. **Parse the decision title** from `$ARGUMENTS`. If the title is unclear or missing, ask the user for clarification.

2. **Determine the next ADR number:**
   - Check `docs/adr/` for existing ADR files
   - Find the highest numbered ADR (files named `NNNN-*.md`)
   - Increment by 1 for the new ADR
   - If no ADRs exist, start at `0001`
   - Create the `docs/adr/` directory if it doesn't exist

3. **Analyze the codebase** for context relevant to the decision:
   - Current tech stack and architecture patterns
   - Existing similar decisions or patterns
   - Dependencies that relate to the decision
   - Configuration that would be affected

4. **Generate the ADR** following the standard format:

   ```markdown
   # ADR-[NNNN]: [Decision Title]

   **Date:** [today's date]
   **Status:** Proposed
   **Deciders:** [detect from git config user.name]

   ## Context

   Describe the forces at play. What is the issue that is motivating this decision?
   Include:
   - Current state of the system
   - Problem or opportunity being addressed
   - Technical and business constraints
   - Requirements driving the decision

   ## Decision

   State the decision clearly and concisely.

   **We will [decision statement].**

   Explain the key aspects of the decision:
   - What specifically will be done
   - How it will be implemented at a high level
   - Key technical details of the approach

   ## Consequences

   ### Positive
   - Benefit 1
   - Benefit 2
   - Benefit 3

   ### Negative
   - Tradeoff 1 (with mitigation strategy)
   - Tradeoff 2 (with mitigation strategy)

   ### Neutral
   - Side effect that is neither clearly positive nor negative

   ## Alternatives Considered

   ### Alternative 1: [Name]
   - **Description:** Brief description of the approach
   - **Pros:** What's good about it
   - **Cons:** What's problematic
   - **Why rejected:** Key reason(s) this wasn't chosen

   ### Alternative 2: [Name]
   - **Description:** Brief description of the approach
   - **Pros:** What's good about it
   - **Cons:** What's problematic
   - **Why rejected:** Key reason(s) this wasn't chosen

   ### Alternative 3: Do Nothing / Status Quo
   - **Description:** Keep the current approach
   - **Pros:** No migration effort, no learning curve, no risk of new issues
   - **Cons:** Current pain points persist
   - **Why rejected:** Why the status quo is insufficient

   ## Implementation Plan

   1. **Phase 1:** First step (proof of concept, spike, or pilot)
   2. **Phase 2:** Second step (gradual rollout or migration)
   3. **Phase 3:** Final step (completion and cleanup)

   ### Risks and Mitigations
   | Risk | Likelihood | Impact | Mitigation |
   |------|-----------|--------|------------|
   | Risk 1 | Low/Medium/High | Low/Medium/High | How to mitigate |

   ## References
   - Links to relevant documentation, RFCs, or discussions
   - Related ADRs: ADR-XXXX
   ```

5. **If an ADR index exists** (`docs/adr/README.md` or `docs/adr/index.md`), update it with the new entry.

6. **If no ADR index exists**, create `docs/adr/README.md`:
   ```markdown
   # Architecture Decision Records

   This directory contains Architecture Decision Records (ADRs) for [Project Name].

   ## ADR Status Lifecycle
   - **Proposed**: Decision is under discussion
   - **Accepted**: Decision has been agreed upon by stakeholders
   - **Deprecated**: Decision is no longer relevant
   - **Superseded by ADR-NNNN**: Replaced by a newer decision

   ## Index

   | Number | Title | Status | Date |
   |--------|-------|--------|------|
   | [NNNN] | [Title](NNNN-slug.md) | Proposed | [Date] |
   ```

7. **Writing guidelines:**
   - Write in first person plural ("We decided..." not "I decided...")
   - Be specific with concrete numbers where possible (benchmarks, cost comparisons)
   - Keep the tone neutral and objective
   - The "Context" section should be understandable by someone unfamiliar with the project
   - Always include at least 2 alternatives plus "Do Nothing"

8. **Write the ADR file** to `docs/adr/NNNN-[slugified-title].md`. Report the file path and ADR number to the user.
