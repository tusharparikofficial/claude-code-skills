# Generate Client Handoff Document

Generate a comprehensive handoff document by analyzing the project's codebase, configuration, and infrastructure.

## Arguments

$ARGUMENTS - Optional: specific focus areas or client name

## Instructions

1. **Analyze the project thoroughly.** Examine the codebase to understand:
   - Project structure and architecture
   - Tech stack (package.json, requirements.txt, go.mod, Cargo.toml, etc.)
   - Configuration files (docker-compose, nginx, CI/CD configs)
   - Environment variables (.env.example, .env.template)
   - Database setup (migrations, schema files)
   - Deployment configuration
   - Documentation that already exists

2. **Search for key files and patterns:**

   ```bash
   # Tech stack detection
   ls package.json requirements.txt go.mod Cargo.toml pom.xml build.gradle 2>/dev/null

   # Environment configuration
   ls .env.example .env.template .env.sample 2>/dev/null

   # Docker/deployment
   ls Dockerfile docker-compose*.yml 2>/dev/null

   # CI/CD
   ls -la .github/workflows/ .gitlab-ci.yml Jenkinsfile 2>/dev/null

   # Database
   find . -type d -name "migrations" -o -name "migrate" 2>/dev/null | head -5

   # Documentation
   find . -name "*.md" -maxdepth 2 2>/dev/null
   ```

3. **Generate the handoff document** with the following structure:

### Output Structure

```markdown
# Project Handoff Document

**Project:** [Project Name]
**Handoff Date:** [Current Date]
**Prepared by:** [Agency Name - placeholder]

---

## 1. Architecture Overview

### System Architecture
- High-level description of the system architecture
- Key components and how they interact
- Data flow between services
- Architecture diagram (text-based using ASCII or Mermaid)

### Directory Structure
```
project-root/
├── src/            # [Description]
├── tests/          # [Description]
├── config/         # [Description]
├── ...
```

### Key Design Decisions
- [Decision 1]: Why this approach was chosen
- [Decision 2]: Why this approach was chosen

## 2. Tech Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Frontend | [e.g., Next.js] | [Version] | [Purpose] |
| Backend | [e.g., Express] | [Version] | [Purpose] |
| Database | [e.g., PostgreSQL] | [Version] | [Purpose] |
| Cache | [e.g., Redis] | [Version] | [Purpose] |
| Queue | [e.g., BullMQ] | [Version] | [Purpose] |

### Key Dependencies
List critical third-party packages with their purpose.

## 3. Environment Setup

### Prerequisites
- [Runtime] version X.X (use [version manager])
- [Database] version X.X
- [Other tools]

### Local Development Setup
```bash
# Step-by-step commands to get running locally
git clone [repo-url]
cd [project]
[install dependencies command]
[setup database command]
[copy environment file command]
[start development server command]
```

### Environment Variables
| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| DATABASE_URL | Database connection string | Yes | - |
| [VAR_NAME] | [Description] | [Yes/No] | [Default] |

*Note: Actual secret values are stored in [secret management location].*

## 4. Deployment Procedures

### Environments
| Environment | URL | Branch | Auto-deploy |
|-------------|-----|--------|-------------|
| Development | [URL] | develop | Yes/No |
| Staging | [URL] | staging | Yes/No |
| Production | [URL] | main | Yes/No |

### Deployment Steps
1. [Step-by-step deployment process]
2. [Including any manual steps]
3. [Rollback procedure]

### CI/CD Pipeline
- Pipeline tool: [GitHub Actions / GitLab CI / etc.]
- Stages: [Build -> Test -> Deploy]
- Configuration file: [path to CI config]

## 5. Credentials & Access

### Important: Credential Locations
| Service | Credential Location | Access Level |
|---------|-------------------|--------------|
| Cloud Provider | [e.g., AWS IAM, 1Password vault] | Admin |
| Database | [Location of connection strings] | Read/Write |
| Domain Registrar | [e.g., Cloudflare account] | DNS Management |
| Email Service | [e.g., Resend dashboard] | Send |
| Payment Provider | [e.g., Stripe dashboard] | Full |

*Never store credentials in source code. All secrets should be in environment variables or a secret manager.*

## 6. Third-Party Services

| Service | Purpose | Dashboard URL | Account Owner |
|---------|---------|---------------|---------------|
| [e.g., Stripe] | Payments | [URL] | [Email] |
| [e.g., Resend] | Email | [URL] | [Email] |
| [e.g., Sentry] | Error tracking | [URL] | [Email] |
| [e.g., Cloudflare] | DNS/CDN | [URL] | [Email] |

## 7. Monitoring & Observability

### Error Monitoring
- Tool: [e.g., Sentry]
- Dashboard: [URL]
- Alert channels: [e.g., Slack #alerts, email]

### Uptime Monitoring
- Tool: [e.g., UptimeRobot, Better Stack]
- Dashboard: [URL]
- Monitored endpoints: [list]

### Logging
- Tool: [e.g., CloudWatch, Datadog]
- Log retention: [X days]
- Access: [How to view logs]

### Performance Monitoring
- Tool: [e.g., Vercel Analytics, New Relic]
- Key metrics tracked: [list]

## 8. Maintenance Procedures

### Regular Maintenance Tasks
| Task | Frequency | Procedure |
|------|-----------|-----------|
| Dependency updates | Monthly | Run [update command], test, deploy |
| Database backups | Daily (automated) | Verify at [backup location] |
| SSL certificate renewal | Annual (auto-renew) | Managed by [provider] |
| Log rotation | [Frequency] | [Procedure] |
| Security patches | As needed | [Procedure] |

### Database Operations
- Backup command: `[command]`
- Restore command: `[command]`
- Migration command: `[command]`

## 9. Known Issues & Technical Debt

| # | Issue | Severity | Workaround | Recommendation |
|---|-------|----------|------------|----------------|
| 1 | [Issue description] | [High/Med/Low] | [Current workaround] | [Suggested fix] |

## 10. Recommended Improvements

| # | Improvement | Priority | Estimated Effort | Business Impact |
|---|------------|----------|-----------------|-----------------|
| 1 | [Description] | [High/Med/Low] | [X hours/days] | [Impact] |

---

## Contact Information

For questions about this project during the transition period:
- **Technical Lead:** [Name] - [Email]
- **Project Manager:** [Name] - [Email]
- **Support window:** [X days/weeks post-handoff]
```

4. **Populate every section** with real data from the codebase analysis. Do not leave generic placeholders where specific information can be determined from the code.

5. **Flag any concerns** discovered during analysis (missing tests, no CI/CD, hardcoded secrets, etc.) in the Known Issues section.

6. **Output the complete handoff document** as formatted Markdown directly to the user.
