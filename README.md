# Claude Code Skills

143 production-ready slash command skills for [Claude Code](https://claude.com/claude-code), covering 18 categories across software engineering, DevOps, AI/ML, marketing, SEO, e-commerce, and more.

## Quick Install

```bash
git clone https://github.com/tusharparikofficial/claude-code-skills.git
cd claude-code-skills
./install.sh
```

This copies all skills to `~/.claude/commands/`, making them available as slash commands in any Claude Code session.

## Skills Overview (143 total)

| Category | Count | Examples |
|----------|-------|---------|
| **gen** (generators) | 31 | `/gen:crud`, `/gen:form`, `/gen:api-client`, `/gen:migration`, `/gen:readme`, `/gen:tech-spec`, `/gen:landing-page` |
| **review** (code quality) | 16 | `/review:pr`, `/review:security`, `/review:architecture`, `/review:types`, `/review:deps`, `/review:dead-code` |
| **devops** (infrastructure) | 10 | `/devops:dockerfile`, `/devops:compose`, `/devops:github-action`, `/devops:k8s-deploy`, `/devops:terraform-module` |
| **scaffold** (project starters) | 9 | `/scaffold:nextjs`, `/scaffold:api`, `/scaffold:monorepo`, `/scaffold:cli`, `/scaffold:mcp-server` |
| **test** (testing) | 8 | `/test:unit`, `/test:e2e`, `/test:coverage`, `/test:regression`, `/test:flaky-fix` |
| **debug** (troubleshooting) | 8 | `/debug:error`, `/debug:build`, `/debug:docker`, `/debug:ci`, `/debug:memory` |
| **ai** (AI/ML) | 7 | `/ai:chatbot`, `/ai:rag-setup`, `/ai:agent-build`, `/ai:embedding-pipeline`, `/ai:cost-optimize` |
| **mkt** (marketing) | 7 | `/mkt:landing-page`, `/mkt:analytics`, `/mkt:og-image`, `/mkt:waitlist`, `/mkt:social-share` |
| **seo** | 6 | `/seo:audit`, `/seo:structured-data`, `/seo:programmatic`, `/seo:core-vitals` |
| **meta** (self-improvement) | 6 | `/meta:skill-create`, `/meta:batch-skill-create`, `/meta:skill-chain`, `/meta:skill-catalog` |
| **agency** (client work) | 5 | `/agency:proposal`, `/agency:estimate`, `/agency:report`, `/agency:handoff`, `/agency:launch-checklist` |
| **ecom** (e-commerce) | 5 | `/ecom:checkout`, `/ecom:subscription`, `/ecom:product-catalog`, `/ecom:inventory`, `/ecom:search` |
| **ui** (frontend) | 5 | `/ui:design-system`, `/ui:data-table`, `/ui:a11y-audit`, `/ui:form-wizard`, `/ui:responsive` |
| **sec** (security) | 4 | `/sec:audit`, `/sec:auth-implement`, `/sec:headers`, `/sec:fix-vuln` |
| **perf** (performance) | 4 | `/perf:audit`, `/perf:optimize-bundle`, `/perf:optimize-images`, `/perf:optimize-api` |
| **db** (database) | 4 | `/db:design-schema`, `/db:optimize-query`, `/db:migration-safe`, `/db:seed` |
| **data** (data/analytics) | 3 | `/data:pipeline`, `/data:dashboard`, `/data:export` |
| **workflow** | 3 | `/workflow:pre-commit`, `/workflow:dev-setup`, `/workflow:release` |

## Usage

After installing, use any skill in Claude Code by typing its slash command:

```
/gen:crud User name:string email:string age:number
/review:pr 42
/debug:build
/scaffold:nextjs myapp --auth --db --payments
/seo:audit
/test:unit src/services/auth.ts
/devops:dockerfile
/ai:chatbot anthropic
/agency:proposal "Build a SaaS dashboard for HR teams"
```

## Key Features

- **Auto-detection**: Skills detect your project's tech stack and adapt (TypeScript, Python, Go, Java, Rust)
- **Framework-aware**: Works with Next.js, Django, FastAPI, Express, Spring Boot, Gin, and more
- **Production-ready**: Each skill generates code with error handling, validation, types, and tests
- **Composable**: Chain skills together with `/meta:skill-chain`
- **Self-expanding**: Create new skills with `/meta:skill-create` or batch-create with `/meta:batch-skill-create`

## Creating New Skills

Use the meta-skills to expand the collection:

```
# Create a single skill
/meta:skill-create payments/stripe-webhook "Handle Stripe webhook events"

# Create multiple skills from a spec file
/meta:batch-skill-create skills-spec.md

# Chain skills into workflows
/meta:skill-chain build-and-deploy scaffold:nextjs -> test:unit -> devops:dockerfile -> devops:deploy-vps
```

## Updating

```bash
cd claude-code-skills
git pull origin main
./install.sh
```

The installer only overwrites changed files and reports what was updated.

## Uninstall

```bash
./uninstall.sh
```

## Roadmap

See `SKILLS-CATALOG.md` and `SKILLS-CATALOG-EXTENDED.md` for a 2,000-skill roadmap covering additional domains: blockchain/web3, gaming, IoT, healthcare, education, legal, finance, and more.

## License

MIT
