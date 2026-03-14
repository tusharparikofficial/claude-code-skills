# Generate Client Project Proposal

Generate a comprehensive client project proposal in Markdown format based on the provided project description.

## Arguments

$ARGUMENTS - A description of the project to generate a proposal for (e.g., "e-commerce platform for artisan goods with subscription boxes")

## Instructions

1. **Understand the project.** Parse the project description from `$ARGUMENTS`. If the description is too vague, make reasonable assumptions and document them in the Assumptions section.

2. **Research before writing.** Search the current codebase (if any) to understand existing tech stack, patterns, and conventions that should inform the proposal.

3. **Generate the proposal** with the following sections in Markdown:

### Output Structure

```markdown
# Project Proposal: [Project Name]

**Prepared for:** [Client Name - use placeholder if unknown]
**Date:** [Current Date]
**Version:** 1.0

---

## 1. Executive Summary
- 2-3 paragraph overview of the project vision, goals, and value proposition
- Highlight the business problem being solved
- Summarize the recommended approach

## 2. Scope of Work

### Phase 1: Discovery & Planning (Week 1-2)
- Requirements gathering and stakeholder interviews
- User research and persona development
- Technical architecture planning
- Project plan finalization

### Phase 2: Design (Week 3-4)
- Wireframes and user flows
- UI/UX design mockups
- Design system/component library
- Client design review and approval

### Phase 3: Development (Week 5-10)
- Sprint-based development (2-week sprints)
- Feature implementation by priority
- API development and integrations
- Database design and implementation

### Phase 4: Testing & QA (Week 11-12)
- Unit and integration testing
- User acceptance testing (UAT)
- Performance and security testing
- Bug fixes and refinements

### Phase 5: Launch & Handoff (Week 13-14)
- Staging deployment and final review
- Production deployment
- Documentation and training
- Post-launch monitoring

## 3. Technical Approach
- Architecture overview (monolith vs microservices, serverless, etc.)
- Development methodology (Agile/Scrum)
- Testing strategy
- CI/CD pipeline
- Monitoring and observability

## 4. Tech Stack Rationale
- Frontend: [Choice] - Why this over alternatives
- Backend: [Choice] - Why this over alternatives
- Database: [Choice] - Why this over alternatives
- Infrastructure: [Choice] - Why this over alternatives
- Third-party services: List with justification

## 5. Timeline & Milestones
| Milestone | Target Date | Deliverables |
|-----------|-------------|--------------|
| Discovery Complete | Week 2 | Requirements doc, architecture plan |
| Design Approved | Week 4 | Final mockups, design system |
| MVP Ready | Week 8 | Core features functional |
| Beta Release | Week 10 | All features, internal testing |
| Launch | Week 14 | Production deployment |

## 6. Team Composition
| Role | Responsibility | Allocation |
|------|---------------|------------|
| Project Manager | Client communication, timeline, deliverables | 50% |
| Lead Developer | Architecture, code reviews, core features | 100% |
| Frontend Developer | UI implementation, responsive design | 100% |
| Backend Developer | API, database, integrations | 100% |
| UI/UX Designer | Design, user testing | 50% |
| QA Engineer | Testing, automation | 50% (Phase 4: 100%) |

## 7. Deliverables
- [ ] Requirements documentation
- [ ] Architecture diagram
- [ ] UI/UX designs (Figma/Sketch)
- [ ] Source code (Git repository)
- [ ] API documentation
- [ ] Test suite with 80%+ coverage
- [ ] Deployment scripts and CI/CD pipeline
- [ ] User documentation / admin guide
- [ ] Training session (2 hours)
- [ ] 30-day post-launch support

## 8. Assumptions & Exclusions

### Assumptions
- Client will provide timely feedback (within 2 business days)
- Content and assets will be provided by the client
- Third-party APIs are stable and documented
- [Project-specific assumptions]

### Exclusions
- Content creation (copywriting, photography)
- Ongoing maintenance beyond 30-day support window
- Hardware procurement
- [Project-specific exclusions]

## 9. Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Scope creep | Medium | High | Strict change request process |
| Third-party API changes | Low | Medium | Abstraction layer, fallback plans |
| Key personnel unavailability | Low | High | Cross-trained team, documentation |
| Client feedback delays | Medium | Medium | Buffer time in schedule |

## 10. Investment & Cost Breakdown
| Phase | Hours | Rate | Cost |
|-------|-------|------|------|
| Discovery & Planning | XX hrs | $XXX/hr | $X,XXX |
| Design | XX hrs | $XXX/hr | $X,XXX |
| Development | XX hrs | $XXX/hr | $XX,XXX |
| Testing & QA | XX hrs | $XXX/hr | $X,XXX |
| Launch & Handoff | XX hrs | $XXX/hr | $X,XXX |
| **Total** | **XX hrs** | | **$XX,XXX** |

### Additional Costs
- Infrastructure (monthly): $XXX/mo
- Third-party services (monthly): $XXX/mo
- Domain and SSL: $XXX/yr

## 11. Payment Terms
- 30% upfront upon contract signing
- 30% upon design approval (end of Phase 2)
- 30% upon beta release (end of Phase 4)
- 10% upon final delivery and launch

Payment due within 15 business days of invoice.

## 12. Next Steps
1. Review this proposal and provide feedback
2. Schedule a Q&A call to discuss details
3. Sign statement of work (SOW) and MSA
4. Kick-off meeting and project initiation
```

4. **Customize all sections** based on the specific project description. Do not leave generic placeholders where specific recommendations can be made.

5. **Estimate hours realistically.** Base estimates on the complexity of the described project. Small projects: 200-400 hours. Medium: 400-800 hours. Large: 800+ hours.

6. **Output the complete proposal** as formatted Markdown directly to the user.
