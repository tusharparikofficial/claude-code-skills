# Skill: edu-system

## Description
Complete Academic Coaching System Generator. Creates a production-ready educational content system for any board, class, and subject(s) — from research through syllabus planning, lesson plans, teacher aids, chapter notes, practice questions (200+ per chapter), multi-tier test series, answer keys, and branded A4 PDFs.

## Trigger
- `/edu-system` or user asks to create educational content, coaching materials, academic system, test papers, question banks, or lesson plans for any board/class/subject combination.
- Examples: "create study material for CBSE Class 12 Physics", "build coaching system for SSC Board Class 10", "generate test papers for ICSE Class 9 Mathematics"

## Arguments
```
/edu-system <board> <class> [--subjects <list>] [--brand <name>] [--contact <phone>] [--dir <path>] [--hours <daily_hours>] [--deadline <date>]
```

**Required:**
- `board` — Education board (ICSE, CBSE, Maharashtra SSC, Karnataka SSLC, IGCSE, IB, AP, etc.)
- `class` — Class/Grade level (e.g., "10", "12", "9")

**Optional:**
- `--subjects` — Comma-separated subjects. Default: ALL subjects for that board/class
- `--brand` — Coaching institute name (default: "Bright Tutorials")
- `--contact` — Contact number (default: "9403781999")
- `--dir` — Output directory (default: current working directory)
- `--hours` — Daily coaching hours (default: 2)
- `--deadline` — Syllabus completion deadline (default: "Sep 30")
- `--colors` — Primary,accent hex colors (default: "#1a5276,#f39c12")
- `--skip-pdf` — Skip PDF generation (faster, HTML only)
- `--questions-per-chapter` — Questions per chapter (default: 200)
- `--tiers` — Number of student tiers (default: 3 → Weak/Average/Topper)

## Execution

When this skill is invoked, follow this EXACT pipeline in order. Each phase MUST complete before moving to the next. Use parallel agents aggressively within each phase.

---

### PHASE 0: Parse Arguments & Set Variables

Extract from the user's command or prompt:

```
BOARD = (e.g., "ICSE", "CBSE", "SSC Maharashtra", "IGCSE")
CLASS = (e.g., "10", "12")
SUBJECTS = (e.g., "all" or "Mathematics,Physics,Chemistry")
BRAND_NAME = (e.g., "Bright Tutorials")
CONTACT = (e.g., "9403781999")
OUTPUT_DIR = (e.g., "/home/projects/bright/bt_2027")
DAILY_HOURS = (e.g., 2)
SYLLABUS_DEADLINE = (e.g., "Sep 30")
PRIMARY_COLOR = (e.g., "#1a5276")
ACCENT_COLOR = (e.g., "#f39c12")
QUESTIONS_PER_CHAPTER = (e.g., 200)
ACADEMIC_YEAR = (derive from current date, e.g., "2026-2027")
```

If any required argument is missing, use AskUserQuestion to ask for it.

---

### PHASE 1: Deep Research (Use WebSearch + WebFetch)

Launch parallel research agents for:

**Agent 1: Syllabus Research**
- Search "[BOARD] Class [CLASS] syllabus [ACADEMIC_YEAR]" on official board website, Vedantu, BYJU'S, Toppr, Allen, PW
- For EACH subject, extract: complete chapter list, topic breakdown, paper pattern, marks distribution, exam duration, internal assessment structure
- Check for recent additions/deletions to syllabus
- Identify prescribed textbooks and reference books

**Agent 2: Exam Pattern & Strategy**
- Search "[BOARD] Class [CLASS] exam pattern [ACADEMIC_YEAR]"
- Extract: paper structure (sections, marks per section, choice), passing criteria, grading system
- Search for mark weightage per chapter from previous years
- Identify high-scoring vs difficult chapters
- Research "Best of Five" or equivalent rules

**Agent 3: Teaching & Coaching Strategy**
- Search "how to score 95% in [BOARD] Class [CLASS]"
- Research differentiated instruction strategies for 3 tiers
- Find optimal study schedules given DAILY_HOURS constraint
- Identify best reference books per subject
- Research revision techniques, spaced repetition, exam anxiety management

**Output:** Save all research to `docs/planning/` as:
- `syllabus-research.md` — Complete syllabus data
- `exam-patterns.md` — Exam structure and strategy
- `coaching-strategy.md` — Teaching approach and schedule
- `master-plan.md` — Comprehensive implementation plan

---

### PHASE 2: Project Setup

**2.1 Create folder structure:**
```
{OUTPUT_DIR}/
├── assets/
│   ├── styles/
│   │   ├── common.css        # Shared CSS (use PRIMARY_COLOR, ACCENT_COLOR)
│   │   ├── print.css         # A4 print/PDF CSS (anti-overlap measures)
│   │   └── test-paper.css    # Test paper specific styles
│   ├── images/
│   │   └── logo.svg          # Generated SVG logo with BRAND_NAME
│   └── templates/
│       ├── base.html         # Base HTML template
│       └── test-paper.html   # Test paper template
├── {BOARD}/
│   └── Class{CLASS}/
│       ├── _overview/        # Master schedule, subject overview, exam patterns
│       │   ├── student-tracking/
│       │   └── parent-communication/
│       └── {Subject}/        # One folder per subject
│           ├── 01-syllabus-planning/
│           ├── 02-lesson-plans/
│           ├── 03-teacher-aid/
│           ├── 04-chapter-notes/
│           ├── 05-practice-questions/
│           ├── 06-tests/
│           │   ├── chapter-tests-30marks/
│           │   ├── multi-chapter-tests-50marks/
│           │   ├── term-exams-80marks/
│           │   └── mock-board-80marks/
│           └── 07-answer-keys/
├── pdf/                      # Generated PDFs (mirror structure)
├── scripts/
│   ├── generate-pdf.js       # Puppeteer HTML→PDF converter
│   └── build-all.sh          # Master build script
├── docs/planning/            # Research and planning docs
└── CLAUDE.md                 # Project documentation
```

**2.2 Create CSS files** with BRAND_NAME, PRIMARY_COLOR, ACCENT_COLOR variables.

Key CSS requirements (CRITICAL for PDF quality):
- `.bt-footer` must use `position: static` (NOT fixed — prevents overlap)
- All text elements need `overflow-wrap: break-word`
- `pre` blocks need `white-space: pre-wrap` for code
- Tables use `page-break-inside: auto` with `thead { display: table-header-group }`
- Watermark at 4% opacity (visible but non-interfering)
- Card grids switch to single column in print

**2.3 Create SVG logo** with BRAND_NAME

**2.4 Create PDF generation script** (Puppeteer):
- A4 format, 22mm top/bottom margins, 15mm left/right
- Branded header: "{BRAND_NAME} | {BOARD} Class {CLASS} | Contact: {CONTACT}"
- Footer: page numbers "Page X / Y"
- Runtime CSS injection to force `position: static` on all fixed elements
- Batch processing with 4 concurrent conversions
- `--subject` flag for per-subject conversion

---

### PHASE 3: Overview Documents

Create in `{BOARD}/Class{CLASS}/_overview/`:

1. **master-schedule.html** — Complete academic calendar with:
   - Phase breakdown (Teaching → Tests → Revision → Relaxation)
   - Weekly timetable based on DAILY_HOURS
   - Subject-wise hour allocation
   - Monthly milestones with progress bars
   - Test schedule timeline

2. **subject-overview.html** — All subjects at a glance:
   - Subject cards with duration, marks, chapters, difficulty
   - Scoring rules (Best of Five, etc.)
   - Priority matrix
   - Reference books table

3. **exam-pattern-guide.html** — Board exam patterns for ALL subjects:
   - Paper structure per subject
   - Time management strategy
   - Passing criteria and grading
   - Exam-day tips

4. **student-tracking/** — Progress trackers per tier:
   - tier1-weak.html (Target: passing to 65%)
   - tier2-average.html (Target: 80-90%)
   - tier3-topper.html (Target: 95%+ / board rank)

5. **parent-communication/** — Templates:
   - monthly-report.html
   - progress-card.html

---

### PHASE 4: Subject Content Generation (PARALLEL — All Subjects Simultaneously)

For EACH subject, launch parallel agents to create ALL 7 content types. Use this priority order within each subject:

**4.1 Syllabus Planning (01-syllabus-planning/)**
- `syllabus-coverage.html` — Full chapter-by-chapter syllabus
- `chapter-wise-weightage.html` — Infographic marks distribution
- `monthly-targets.html` — Week-by-week teaching plan

**4.2 Lesson Plans (02-lesson-plans/)**
One file per chapter. Each lesson plan MUST include:
- **A. Lesson Meta** — Subject, chapter, unit, duration, weightage, difficulty, prerequisites
- **B. Learning Objectives** — 5-8 measurable objectives
- **C. Key Concepts** — Full explanations with formulas and 3-4 worked examples
- **D. Teaching Flow** — Session-by-session timeline (warm-up → teach → practice → wrap-up)
- **E. Differentiated Instruction** — Tier 1 (scaffolded), Tier 2 (application), Tier 3 (challenge)
- **F. Practice Problems** — 10 problems (3 easy, 4 medium, 3 hard) with answers
- **G. Homework** — 5 problems per tier (15 total)
- **H. Assessment Checklist** — Understanding checks, common mistakes, remediation

**4.3 Teacher Aids (03-teacher-aid/)**
- `formula-sheet.html` — ALL formulas/key facts organized by unit
- `common-mistakes.html` — Top mistakes per chapter with WRONG/RIGHT examples
- `differentiated-strategies.html` — Subject-specific teaching strategies per tier

**4.4 Chapter Notes (04-chapter-notes/)**
One file per chapter. Student-facing comprehensive notes including:
1. Chapter overview with board weightage
2. Key definitions in colored boxes
3. ALL formulas with explanations
4. Detailed concept explanations
5. 6-8 solved examples (2 easy, 3 medium, 2-3 hard) with full step-by-step solutions
6. Quick revision bullet points
7. Common mistakes to avoid
8. Board exam tips
9. Visual summary (formula card, concept map)

**4.5 Practice Questions (05-practice-questions/)**
QUESTIONS_PER_CHAPTER questions per chapter, organized as:
- **Section A: MCQ** (25% of total) — 4 options each, answer key at end
- **Section B: Fill in the Blanks** (15%) — Answer key at end
- **Section C: True/False with Reason** (10%) — Answer key at end
- **Section D: Short Answer** (25%) — 2-3 marks, answers at end
- **Section E: Long Answer** (15%) — 4-5 marks, key steps + answer at end
- **Section F: HOTS/Challenge** (10%) — 5 marks, answers at end

**4.6 Tests (06-tests/)**

**Chapter Tests (30 marks, 45 min):**
- Section A: MCQ 10×1=10
- Section B: Short Answer 5×2=10
- Section C: Long Answer 2×5=10

**Multi-Chapter Tests (50 marks, 1 hr):**
- Section A: MCQ 10×1=10
- Section B: Short Answer 5×2=10
- Section C: Application/HOTS 3×5=15
- Section D: Long Answer 3×5=15 (attempt 2 of 3)

**Term Exams (80 marks, exam duration):**
- Mirror EXACT board paper format for the specific BOARD
- Include proper instructions matching board style

**Mock Board Papers (80 marks, full duration):**
- 4 papers per subject, exact board format
- Progressive difficulty (standard → harder → weak-area focus → board simulation)

**4.7 Answer Keys (07-answer-keys/)**
Matching answer key for EVERY test. Each includes:
- Full step-by-step solutions
- Marking scheme (where to award partial marks)
- Common mistakes to watch for (teacher notes)
- Alternative correct answers where applicable

---

### PHASE 5: Quality Verification

Run verification checks:
1. **File count** — Verify all subjects have all 7 folder types populated
2. **Branding** — Spot-check 3 files per subject for BRAND_NAME, CONTACT, watermark
3. **Content** — Verify question counts, test mark distributions, answer key matching
4. **Report** — Print completion dashboard showing files per subject per type

---

### PHASE 6: PDF Generation

1. Install Puppeteer: `npm init -y && npm install puppeteer`
2. Run: `node scripts/generate-pdf.js`
3. Verify: Count PDFs matches HTML count, check for 0 failures
4. Report: Total PDFs, size, time taken

---

### PHASE 7: Git Repository (if requested)

1. Initialize git repo with `.gitignore` (exclude node_modules)
2. Create comprehensive CLAUDE.md with project docs
3. Copy planning docs into `docs/planning/`
4. Commit all files
5. Create private GitHub repo: `gh repo create {user}/{repo-name} --private`
6. Push to remote

---

## Agent Orchestration Strategy

**Maximize parallelism.** For a 10-subject system:

```
Wave 1 (Phase 1): 3 research agents in parallel
Wave 2 (Phase 2): Setup (sequential, fast)
Wave 3 (Phase 3): Overview docs (1-2 agents)
Wave 4 (Phase 4): Launch 2-3 agents PER SUBJECT simultaneously
  - Agent A: Syllabus + Lesson Plans + Teacher Aids
  - Agent B: Chapter Notes
  - Agent C: Practice Questions
Wave 5 (Phase 4 cont): Tests + Answer Keys
  - Agent D: All test types per subject
  - Agent E: Answer keys per subject
Wave 6 (Phase 5-6): Verification + PDF generation
```

**Agent prompt template for content generation:**

Each agent MUST receive:
- Exact file paths to create
- CSS paths relative to file location
- Logo path relative to file location
- BRAND_NAME and CONTACT for header/footer
- Watermark div: `<div class="watermark">{BRAND_NAME}</div>`
- CSS classes to use: bt-header, bt-subheader, bt-content, bt-footer, watermark, box (box-concept, box-important, box-tip, box-formula, box-example, box-warning), badge, table, formula, tier-section (tier1, tier2, tier3), question-block, lesson-meta, card-grid, card, timeline, progress-bar
- For tests: exam-header, student-info, exam-instructions, exam-section-header, exam-question, exam-footer
- Explicit instruction: "Write ALL files completely. NO PLACEHOLDERS."
- Chapter-specific content details (topics, formulas, weightage)

---

## Board-Specific Adaptations

### ICSE (CISCE)
- Paper: 80 marks external + 20 internal = 100
- Format: Section A (40 compulsory) + Section B (4 of 6 × 10)
- Passing: 33% per subject
- Best of Five rule for aggregate
- Shakespeare drama + Treasure Trove anthology for English Lit

### CBSE
- Paper: 80 marks external + 20 internal = 100 (most subjects)
- Format: Varies — typically 5 sections (MCQ, SA-I, SA-II, LA, Case-based)
- Passing: 33% per subject
- Best of Five for aggregate
- NCERT textbooks are primary source

### Maharashtra SSC
- Paper: 80 marks (most subjects), some 40+40 (semester)
- Format: Q1 (MCQ), Q2-Q6 (structured, choice within)
- Passing: 35% per subject
- Marathi medium option for notes

### Karnataka SSLC
- Paper: 80 marks external + 20 internal
- Format: 4 sections (1-mark, 2-mark, 3-mark, 4-mark)
- Passing: 35% per subject

### IGCSE (Cambridge)
- Paper: Multiple components (Paper 1, 2, 3, 4)
- Format: MCQ + Structured + Extended + Practical
- Grading: A* to G (9-1 in new spec)
- CIE textbooks as primary source

### IB (International Baccalaureate)
- Paper: Multiple papers per subject (P1, P2, P3)
- Format: MCQ + Short Answer + Extended Response + IA
- Grading: 1-7 scale
- Internal Assessment component significant

---

## CSS Anti-Overlap Checklist (CRITICAL)

Every project MUST have these in print.css:
```css
/* PREVENT OVERLAP */
.bt-footer, .exam-footer { position: static !important; }
body { overflow-wrap: break-word; }
pre { white-space: pre-wrap; }
table { page-break-inside: auto; }
thead { display: table-header-group; }
tr { page-break-inside: avoid; }
.watermark { color: rgba(primary, 0.04); z-index: -1; pointer-events: none; }
.card-grid { display: block; } /* single column in print */
```

---

## Output Verification Template

After completion, print this dashboard:
```
╔══════════════════════════════════════════════════════╗
║  {BRAND_NAME} - {BOARD} Class {CLASS}               ║
║  Academic Year {ACADEMIC_YEAR}                       ║
╚══════════════════════════════════════════════════════╝

Subject             Syl  Les  Aid  Not  Que  Tst  Key  TOTAL
────────────────────────────────────────────────────────────
{Subject 1}          3   XX    3   XX   XX   XX   XX   XXX
{Subject 2}          3   XX    3   XX   XX   XX   XX   XXX
...
────────────────────────────────────────────────────────────
GRAND TOTAL                                           XXXX

HTML: XXX files | PDF: XXX files | Disk: XX MB
Questions: ~XX,XXX | Tests: XXX papers | Answer Keys: XXX
```

---

## Example Invocations

```bash
# Full ICSE Class 10 system (what we just built)
/edu-system ICSE 10 --brand "Bright Tutorials" --contact 9403781999

# CBSE Class 12 Science stream only
/edu-system CBSE 12 --subjects "Physics,Chemistry,Mathematics,Biology"

# Maharashtra SSC Class 10 all subjects
/edu-system "SSC Maharashtra" 10 --brand "Star Academy" --contact 9876543210

# CBSE Class 9 single subject
/edu-system CBSE 9 --subjects Mathematics --brand "MathGenius"

# IGCSE Grade 10 with custom colors
/edu-system IGCSE 10 --subjects "Mathematics,Physics,Chemistry" --colors "#2c3e50,#e74c3c"

# Quick HTML-only (skip PDFs)
/edu-system CBSE 10 --subjects Hindi --skip-pdf
```
