# Agency Proposal Generator

Generate a professional, comprehensive client project proposal from project requirements, including scope, timeline, technical approach, team, costs, and terms.

## Arguments

$ARGUMENTS - Required: `<project-description>` (inline text describing the project) or `<requirements-file>` (path to a requirements document)

## Instructions

You are generating a professional agency project proposal. Follow each step carefully.

### Step 1: Parse Requirements

1. **Input source**: Determine if `$ARGUMENTS` is:
   - A file path: Read the file and extract requirements
   - Inline text: Parse the project description directly

2. **Extract key information**:
   - Project name / client name (use placeholder if not provided)
   - Project type: web application, mobile app, API/backend, e-commerce, SaaS platform, marketing site, redesign, etc.
   - Core features and requirements
   - Target audience / end users
   - Technical constraints (specific tech stack, integrations, existing systems)
   - Timeline expectations
   - Budget range (if mentioned)

3. **Detect project context**: If inside a codebase, scan for:
   - Existing tech stack (package.json, requirements.txt, go.mod, etc.)
   - Project structure and architecture
   - Current state of development (greenfield vs existing)

### Step 2: Generate Proposal Document

Create a comprehensive proposal markdown file at `docs/proposal.md` (or output to console if no docs directory).

---

#### Section 1: Cover Page

```markdown
# Project Proposal

## {Project Name}

Prepared for: {Client Name}
Prepared by: {Agency Name}
Date: {Current Date}
Version: 1.0
Confidential

---
```

#### Section 2: Executive Summary

Write 2-3 paragraphs covering:

- **Project overview**: What is being built and why
- **Goals**: What success looks like (quantifiable where possible)
- **Expected outcomes**: Business impact, user experience improvements, technical capabilities
- **High-level approach**: Brief mention of methodology and timeline

The executive summary should be compelling and client-facing. Avoid technical jargon. Focus on business value.

#### Section 3: Understanding of Requirements

Restate the client's requirements in organized fashion:

```markdown
## Understanding of Requirements

### Business Goals
1. {Goal 1}
2. {Goal 2}
3. {Goal 3}

### User Stories / Functional Requirements
- As a {user type}, I want to {action} so that {benefit}
- As a {user type}, I want to {action} so that {benefit}
- ...

### Non-Functional Requirements
- Performance: {response time, concurrent users, uptime}
- Security: {compliance, authentication, data protection}
- Scalability: {expected growth, peak loads}
- Accessibility: {WCAG level, supported devices}
- Internationalization: {languages, locales}
```

#### Section 4: Scope of Work

Break the project into clearly defined phases:

```markdown
## Scope of Work

### Phase 1: Discovery & Planning (Week 1-2)
- Requirements refinement and user research
- Information architecture and user flow diagrams
- Technical architecture design
- Project plan and sprint backlog creation
- Design system foundation

**Deliverables:**
- [ ] Requirements document (finalized)
- [ ] User flow diagrams
- [ ] Technical architecture document
- [ ] Project plan with sprint schedule
- [ ] Design system tokens and guidelines

### Phase 2: Design (Week 3-5)
- Wireframes for all key screens/pages
- Visual design (high-fidelity mockups)
- Responsive design specifications
- Interactive prototype
- Design review and iteration

**Deliverables:**
- [ ] Wireframes (all screens)
- [ ] High-fidelity design mockups
- [ ] Interactive prototype (Figma/InVision)
- [ ] Design system components
- [ ] Design specification document

### Phase 3: Development (Week 6-12)
- Frontend development
- Backend/API development
- Database design and implementation
- Third-party integrations
- Unit and integration testing

**Deliverables:**
- [ ] Functional frontend application
- [ ] Backend API with documentation
- [ ] Database with migrations
- [ ] Integration test suite
- [ ] Development environment setup

### Phase 4: Testing & QA (Week 13-14)
- End-to-end testing
- Performance testing
- Security testing
- Cross-browser/device testing
- Bug fixes and optimization

**Deliverables:**
- [ ] QA test report
- [ ] Performance benchmark results
- [ ] Security audit report
- [ ] Bug fix log

### Phase 5: Launch & Handoff (Week 15-16)
- Production deployment
- DNS and SSL configuration
- Monitoring and alerting setup
- Documentation and knowledge transfer
- Team training sessions

**Deliverables:**
- [ ] Production deployment
- [ ] Operations runbook
- [ ] Technical documentation
- [ ] Training materials
- [ ] Source code repository access
```

Adjust phases based on project type and complexity. Add or remove phases as appropriate.

#### Section 5: Technical Approach

```markdown
## Technical Approach

### Architecture Overview
{Describe the high-level architecture: monolith vs microservices, client-server, serverless, etc.}

### Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Frontend | {e.g., Next.js + React} | {Why this choice} |
| Styling | {e.g., Tailwind CSS} | {Why this choice} |
| Backend | {e.g., Node.js + Express} | {Why this choice} |
| Database | {e.g., PostgreSQL} | {Why this choice} |
| Authentication | {e.g., NextAuth.js} | {Why this choice} |
| Hosting | {e.g., Vercel + AWS} | {Why this choice} |
| CI/CD | {e.g., GitHub Actions} | {Why this choice} |
| Monitoring | {e.g., Sentry + Datadog} | {Why this choice} |

### Development Methodology
- Agile/Scrum with 2-week sprints
- Continuous integration and deployment
- Code review for all changes
- Automated testing (unit, integration, E2E)
- Test-driven development for critical business logic

### Infrastructure
- {Describe hosting, scaling, redundancy approach}
- {Describe backup and disaster recovery strategy}
- {Describe security measures}

### Third-Party Integrations
- {List all required integrations with brief description}
```

#### Section 6: Timeline

```markdown
## Timeline

| Phase | Duration | Start | End | Key Milestone |
|-------|----------|-------|-----|---------------|
| Discovery & Planning | 2 weeks | Week 1 | Week 2 | Requirements signed off |
| Design | 3 weeks | Week 3 | Week 5 | Design approved |
| Development Sprint 1 | 2 weeks | Week 6 | Week 7 | Core features |
| Development Sprint 2 | 2 weeks | Week 8 | Week 9 | Secondary features |
| Development Sprint 3 | 2 weeks | Week 10 | Week 11 | Integrations |
| Development Sprint 4 | 1 week | Week 12 | Week 12 | Polish & optimization |
| Testing & QA | 2 weeks | Week 13 | Week 14 | QA sign-off |
| Launch & Handoff | 2 weeks | Week 15 | Week 16 | Go live |

**Total Duration: ~16 weeks**

### Key Milestones
1. **Week 2**: Requirements and architecture finalized
2. **Week 5**: Design approved by client
3. **Week 7**: MVP / core features demo
4. **Week 12**: Feature complete
5. **Week 14**: QA complete, launch-ready
6. **Week 16**: Production launch and handoff
```

Adjust timeline based on project scope. Provide realistic estimates.

#### Section 7: Team

```markdown
## Team

| Role | Responsibilities | Allocation |
|------|-----------------|------------|
| Project Manager | Client communication, sprint planning, risk management | 50% |
| Lead Developer | Architecture, code review, technical decisions | 100% |
| Frontend Developer | UI implementation, responsive design, performance | 100% |
| Backend Developer | API development, database, integrations | 100% |
| UI/UX Designer | Wireframes, visual design, prototyping | 50-100% |
| QA Engineer | Test planning, execution, automation | 50% (Phase 4: 100%) |
| DevOps Engineer | Infrastructure, CI/CD, deployment | 25% |

### Communication Plan
- **Weekly status meetings**: Every {day} at {time}
- **Sprint demos**: Every 2 weeks
- **Slack/Teams channel**: Daily async communication
- **Monthly stakeholder review**: Progress and roadmap discussion
- **Response time**: Within 4 business hours for queries
```

#### Section 8: Assumptions & Dependencies

```markdown
## Assumptions & Dependencies

### Assumptions
- Client will provide timely feedback (within 2 business days)
- Content (text, images, branding assets) will be provided by client
- Client has existing accounts for required third-party services
- Requirements are finalized at end of Phase 1 (changes after are managed via change request)
- Client designates a single point of contact for decisions

### Dependencies
- {Third-party API availability and documentation}
- {Client's existing system access and credentials}
- {Brand guidelines and design assets}
- {Legal/compliance requirements clarification}

### Out of Scope
- {Explicitly list what is NOT included}
- Content creation (copywriting, photography)
- SEO campaign management (beyond technical SEO)
- Ongoing maintenance (covered in separate retainer proposal)
- Native mobile app development (web-only scope)
- Data migration from legacy systems
```

#### Section 9: Risk Assessment

```markdown
## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Scope creep | High | High | Formal change request process, clear scope document |
| Delayed client feedback | Medium | High | Agreed SLAs, async decision-making protocol |
| Technical integration issues | Medium | Medium | Early integration prototyping, vendor communication |
| Key team member unavailability | Low | High | Knowledge sharing, documentation, backup resources |
| Third-party API changes | Low | Medium | API version pinning, abstraction layers |
| Performance requirements not met | Medium | Medium | Performance testing from Sprint 2, optimization budget |
| Security vulnerabilities | Low | High | Security review at each phase, automated scanning |
```

#### Section 10: Investment

```markdown
## Investment

### Option A: Fixed Price

| Phase | Effort (hours) | Rate | Cost |
|-------|---------------|------|------|
| Discovery & Planning | {X} hrs | ${rate}/hr | ${total} |
| Design | {X} hrs | ${rate}/hr | ${total} |
| Development | {X} hrs | ${rate}/hr | ${total} |
| Testing & QA | {X} hrs | ${rate}/hr | ${total} |
| Launch & Handoff | {X} hrs | ${rate}/hr | ${total} |
| Project Management | {X} hrs | ${rate}/hr | ${total} |
| **Total** | **{X} hrs** | | **${total}** |

### Option B: Time & Materials
- Estimated range: ${min} - ${max}
- Billed {weekly/bi-weekly} based on actual hours
- Hourly rates: ${rate} (development), ${rate} (design), ${rate} (PM)
- Weekly progress reports with hour tracking

### Payment Schedule
| Milestone | % of Total | Amount | Due |
|-----------|-----------|--------|-----|
| Project kickoff | 25% | ${amount} | Upon signing |
| Design approval | 25% | ${amount} | End of Phase 2 |
| Feature complete | 25% | ${amount} | End of Phase 3 |
| Launch | 25% | ${amount} | End of Phase 5 |

*Note: Use placeholder rates/amounts -- these should be customized per project and client.*
```

#### Section 11: Terms & Conditions

```markdown
## Terms & Conditions

### Payment Terms
- Invoices are due within 30 days of receipt
- Late payments incur a 1.5% monthly fee
- Work may be paused if payments are more than 15 days overdue

### Intellectual Property
- All custom code and design assets become client property upon final payment
- Open-source components retain their original licenses
- Agency retains the right to use the project in portfolio (unless NDA restricts)

### Warranty
- 30-day warranty period after launch for bug fixes
- Bugs are defined as deviations from the agreed requirements
- Feature requests and enhancements are not covered under warranty

### Change Requests
- Changes outside the agreed scope require a formal change request
- Change requests include effort estimate and cost impact
- Approved changes may affect timeline and budget

### Confidentiality
- Both parties agree to keep project details confidential
- NDAs can be provided upon request

### Termination
- Either party may terminate with 14 days written notice
- Client pays for all work completed up to termination date
- All deliverables completed to date are transferred to client
```

#### Section 12: Next Steps

```markdown
## Next Steps

1. **Review this proposal** and provide feedback or questions
2. **Schedule a call** to discuss any concerns or modifications
3. **Sign the agreement** and submit initial payment
4. **Kick off** with a discovery session within {X} business days of signing

### Contact

{Agency Name}
{Contact Person}
{Email}
{Phone}
{Website}
```

### Step 3: Customize Based on Project Type

Adjust the proposal based on the detected project type:

#### Web Application / SaaS
- Emphasize architecture, scalability, authentication
- Include subscription/billing integration in scope
- Add ongoing maintenance/support as optional add-on

#### E-Commerce
- Include product catalog, cart, checkout, payment integration
- Add inventory management, order management scope
- Include SEO and analytics setup
- Address PCI compliance

#### Marketing / Landing Page
- Shorter timeline (4-8 weeks)
- Emphasize design, conversion optimization, SEO
- Include CMS setup, A/B testing capability
- Lower development complexity, higher design focus

#### Mobile App
- Address platform support (iOS, Android, or cross-platform)
- Include app store submission process
- Address push notifications, offline support
- Include device testing matrix

#### API / Backend
- Emphasize documentation (OpenAPI/Swagger)
- Include load testing and benchmarks
- Address authentication, rate limiting, versioning
- Include integration testing with client systems

### Step 4: Output

1. Write the proposal to `docs/proposal.md`
2. If no `docs/` directory exists, create it
3. Output a summary of the proposal to the console

### Important Notes

- Use professional, client-facing language throughout
- Avoid excessive technical jargon -- the proposal may be read by non-technical stakeholders
- All costs should use placeholder values that the user can customize
- Timeline estimates should be realistic -- add buffer for unknowns
- Always include an "Out of Scope" section to manage expectations
- The proposal should be self-contained and make sense without additional context
- Include enough detail to demonstrate competence without overwhelming the reader
- Use tables and structured formatting for easy scanning
- Keep the total document under 15 pages when rendered
