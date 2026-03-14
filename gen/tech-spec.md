# Generate Technical Specification

Generate a detailed technical specification document for a feature or system change.

## Arguments

$ARGUMENTS - Required: a description of the feature or change to specify (e.g., "user authentication with OAuth2", "real-time notifications system", "payment processing integration").

## Instructions

1. **Understand the feature** from `$ARGUMENTS`. If the description is too vague to write a meaningful spec, ask the user for clarification before proceeding.

2. **Analyze the existing codebase** to understand:
   - Current architecture and patterns in use
   - Existing data models and database schema
   - Authentication and authorization mechanisms
   - API patterns and conventions
   - Testing patterns
   - Deployment infrastructure
   - Dependencies and tech stack

3. **Generate the technical specification** with these sections:

   ```markdown
   # Technical Specification: [Feature Title]

   **Author:** [detect from git config user.name]
   **Date:** [today's date]
   **Status:** Draft
   **Reviewers:** TBD

   ## 1. Overview

   ### 1.1 Summary
   One paragraph description of what this feature does and why it matters.

   ### 1.2 Goals
   - Bulleted list of what this feature aims to achieve

   ### 1.3 Non-Goals
   - Bulleted list of what is explicitly out of scope

   ## 2. Background & Context

   ### 2.1 Current State
   How things work today. What problem exists.

   ### 2.2 Motivation
   Why this change is needed now.

   ### 2.3 Prior Art
   Similar solutions in the industry or within the codebase.

   ## 3. Proposed Solution

   ### 3.1 High-Level Design
   Overview of the approach.

   ```mermaid
   flowchart TD
       A[Component] --> B[Component]
       B --> C[Component]
   ```

   ### 3.2 Detailed Design

   #### 3.2.1 Component/Module Changes
   Describe each component that needs to change.

   #### 3.2.2 Sequence Diagram
   ```mermaid
   sequenceDiagram
       participant U as User
       participant A as API
       participant S as Service
       participant D as Database
       U->>A: Request
       A->>S: Process
       S->>D: Query
       D-->>S: Result
       S-->>A: Response
       A-->>U: Result
   ```

   ### 3.3 API Changes

   #### New Endpoints
   | Method | Path | Description |
   |--------|------|-------------|
   | ... | ... | ... |

   #### Request/Response Schemas
   ```json
   {
     "example": "schema"
   }
   ```

   #### Modified Endpoints
   List any existing endpoints that change.

   ### 3.4 Database Changes

   #### New Tables/Collections
   ```sql
   CREATE TABLE example (
     id UUID PRIMARY KEY,
     ...
   );
   ```

   #### Modified Tables
   List alterations to existing tables.

   #### Indexes
   New indexes needed for performance.

   ### 3.5 Migration Plan
   - Step-by-step data migration process
   - Backward compatibility considerations
   - Zero-downtime migration strategy

   ## 4. Testing Strategy

   ### 4.1 Unit Tests
   Key units to test and approach.

   ### 4.2 Integration Tests
   Integration points to test.

   ### 4.3 E2E Tests
   Critical user flows to validate.

   ### 4.4 Performance Tests
   Load and performance requirements.

   ## 5. Rollback Plan
   - How to revert the change safely
   - Data rollback considerations
   - Feature flag strategy if applicable

   ## 6. Security Considerations
   - Authentication/authorization changes
   - Data privacy implications
   - Input validation requirements
   - Potential attack vectors

   ## 7. Observability
   - New metrics to track
   - Logging requirements
   - Alerting rules
   - Dashboard updates

   ## 8. Timeline Estimate

   | Phase | Duration | Description |
   |-------|----------|-------------|
   | Design Review | X days | ... |
   | Implementation | X days | ... |
   | Testing | X days | ... |
   | Deployment | X days | ... |

   ## 9. Open Questions
   - [ ] Question 1
   - [ ] Question 2
   - [ ] Question 3

   ## 10. Alternatives Considered

   ### Alternative A: [Name]
   - **Approach:** Description
   - **Pros:** ...
   - **Cons:** ...
   - **Why rejected:** ...
   ```

4. **Tailor the spec to the project:**
   - Use the actual tech stack (don't suggest PostgreSQL if the project uses MongoDB)
   - Follow existing API conventions found in the codebase
   - Reference actual existing models, services, and modules by name
   - Use the project's actual testing framework and patterns
   - Match the project's deployment model

5. **Write the file** to `docs/specs/[slugified-feature-title].md`. Create directories if needed. Inform the user of the file path.
