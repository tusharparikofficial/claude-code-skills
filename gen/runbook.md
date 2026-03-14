# Create Operational Runbook

Generate a detailed operational runbook with step-by-step procedures for a specific operational topic.

## Arguments

$ARGUMENTS - Required: the topic area. Common values: `deployment`, `incident`, `scaling`, `maintenance`, `backup`, `migration`, `monitoring`, `security`. Can also be a specific scenario like "database failover" or "SSL certificate renewal".

## Instructions

1. **Determine the runbook topic** from `$ARGUMENTS`. If the topic is unclear, ask the user for clarification.

2. **Analyze the project** to understand:
   - Deployment method: Docker, Kubernetes, serverless, bare metal, PaaS
   - Infrastructure: cloud provider, services used, regions
   - CI/CD: pipeline configuration, deployment stages
   - Monitoring: logging, metrics, alerting tools
   - Database: type, hosting, backup configuration
   - Environment configuration: env vars, secrets management
   - Dependencies: external APIs, third-party services

3. **Generate the runbook** based on the topic:

   ```markdown
   # Runbook: [Topic Title]

   **Last Updated:** [today's date]
   **Owner:** [team or role]
   **Review Frequency:** Quarterly

   ## Purpose
   When and why to use this runbook.

   ## Prerequisites
   - Required access and permissions
   - Required tools installed
   - Required knowledge or training

   ## Procedure

   ### Step 1: [Action]
   **Description:** What this step accomplishes.
   **Who:** Role responsible.
   **When:** Trigger condition.

   ```bash
   # Command to execute
   command --with-flags
   ```

   **Verification:**
   ```bash
   # How to verify this step succeeded
   verification-command
   ```

   **Expected output:**
   ```
   Expected output here
   ```

   **If this fails:**
   - Troubleshooting step 1
   - Troubleshooting step 2
   - Escalation: contact [role/person]

   ### Step 2: [Action]
   ...

   ## Decision Trees

   ### Scenario: [Common Decision Point]
   ```
   Is condition X true?
   ├── YES: Do action A
   │   └── Did it work?
   │       ├── YES: Proceed to step N
   │       └── NO: Escalate to [role]
   └── NO: Do action B
       └── Continue to step M
   ```

   ## Rollback Procedure

   ### When to Roll Back
   - Criteria that indicate rollback is needed

   ### Rollback Steps
   1. Step-by-step rollback commands
   2. Verification after rollback
   3. Communication steps

   ## Common Issues & Fixes

   | Symptom | Likely Cause | Fix |
   |---------|-------------|-----|
   | ... | ... | ... |

   ## Escalation Matrix

   | Severity | Response Time | Contact | Channel |
   |----------|---------------|---------|---------|
   | P1 - Critical | 15 min | ... | ... |
   | P2 - High | 1 hour | ... | ... |
   | P3 - Medium | 4 hours | ... | ... |
   | P4 - Low | Next business day | ... | ... |

   ## Post-Procedure Checklist
   - [ ] All verification steps passed
   - [ ] Monitoring confirmed normal
   - [ ] Team notified of completion
   - [ ] Runbook updated if procedure changed
   - [ ] Incident report filed (if applicable)

   ## Appendix

   ### Useful Commands
   | Command | Purpose |
   |---------|---------|
   | ... | ... |

   ### Related Runbooks
   - Link to related runbooks

   ### Change Log
   | Date | Author | Change |
   |------|--------|--------|
   | [today] | [author] | Initial creation |
   ```

4. **Topic-specific additions:**

   - **Deployment runbook:** Include pre-deploy checklist, deployment commands per environment, smoke test procedures, canary/blue-green steps, feature flag toggles.
   - **Incident runbook:** Include severity classification, communication templates, incident commander duties, post-mortem template, SLA reference.
   - **Scaling runbook:** Include scaling triggers and thresholds, horizontal vs vertical scaling procedures, auto-scaling configuration, load testing commands, capacity planning reference.
   - **Maintenance runbook:** Include maintenance window scheduling, pre-maintenance notifications, system health checks, dependency update procedures, cleanup scripts.

5. **Tailor to the actual project:**
   - Use real service names, URLs, and infrastructure details found in the codebase
   - Reference actual Docker/K8s/CI configuration
   - Include real commands that work with the project's tooling
   - Reference actual monitoring and logging setup

6. **Write the file** to `docs/runbooks/[topic].md`. Create directories if needed. Inform the user of the file path.
