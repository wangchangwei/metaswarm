# Start Task

Determine task complexity and use appropriate workflow for efficient development.

## Usage

```text
/start-task <task-description>
```

## Steps

### 0. Pre-Task Checklist

Before starting any new task:

**Context Recovery Check**:

- [ ] Check if `.beads/plans/active-plan.md` exists with `status: in-progress`
- [ ] If YES: An interrupted execution exists. Ask user: "There's an active plan from a previous session. Resume it or start fresh?"
  - Resume → run `bd prime --work-type recovery` and pick up where execution stopped
  - Start fresh → mark the old plan as `status: abandoned` and proceed normally

**Knowledge Priming (CRITICAL)**:

- [ ] Run BEADS prime: `bd prime --keywords "<task-keywords>" --work-type planning`
- [ ] Review MUST FOLLOW rules and GOTCHAS before proceeding
- [ ] Note any relevant patterns or decisions that constrain the approach

**PR Check**:

- [ ] Check if there are active PRs with pending comments
- [ ] Ask: "Before we start the new task, should we check if there are any PR comments to address?"
- [ ] If yes, run: `gh pr list --author @me --state open`
- [ ] Check each PR for new CodeRabbit comments

### 0.5. External Tools Check (informational only — never blocks the task)

Check if external AI tools (Codex, Gemini) are available for cost savings and cross-model review:

- Run the health check scripts to detect installed tools:
  ```bash
  command -v codex >/dev/null 2>&1 && echo "codex: available" || echo "codex: not found"
  command -v gemini >/dev/null 2>&1 && echo "gemini: available" || echo "gemini: not found"
  ```
- **If tools are detected but `.metaswarm/external-tools.yaml` does not exist**: Suggest the user enable them:
  > "External tools (Codex/Gemini) are installed but not configured. Run `mkdir -p .metaswarm && cp templates/external-tools.yaml .metaswarm/` to enable cost-saving delegation."
- **If no tools are detected**: Briefly mention they can be installed:
  > "Optional: Install Codex and Gemini CLIs for cost savings and cross-model review — see `templates/external-tools-setup.md`."
- **If tools are configured and working**: No message needed — proceed silently.

This check is informational only. Always proceed to the task regardless of the result.

### 1. Task Assessment

**Use extended thinking** to analyze the task complexity before asking the user.

Consider:

- Number of files likely to be modified
- Whether database changes are needed
- Impact on existing functionality
- Testing requirements
- Integration points

Then ask the user to confirm your assessment:

> **Proposed complexity**: [Simple / Complex] - Does this match your expectation?

**Simple Task (streamlined flow):**

- Bug fixes
- Small UI tweaks
- Minor text/copy changes
- Simple configuration updates
- Adding basic validation
- Fixing linting/test issues

**Complex Task (full checklist + BEADS epic):**

- New features with database changes
- New API endpoints
- Complex UI components
- Background job modifications
- Onboarding flow changes
- Multi-file refactoring
- Performance optimizations

### 1.5. Problem Definition Phase

Before implementation, ensure the problem is well-defined:

**If a GitHub Issue exists:**

```bash
# Read the issue
gh issue view <number> --json title,body,labels,comments

# Extract and verify:
# - Clear scope (what's in, what's out)
# - Definition of Done items (verifiable acceptance criteria)
# - File scope (which files will be affected)
# - Human checkpoints (where should we pause for review?)
```

If the issue lacks DoD items or clear scope, ask the user to clarify before proceeding.

**If no GitHub Issue exists:**

- For **simple tasks**: No issue needed. Proceed directly.
- For **complex tasks**: An issue is ALWAYS needed. Ask the user:
  > "This is a complex task. Should I create a GitHub Issue to track it?"

**If the problem is unclear:**

- Route to `superpowers:brainstorming` first to refine the idea into a design
- **MANDATORY HANDOFF**: After brainstorming commits a design document, you MUST:
  1. STOP — do NOT proceed directly to `writing-plans` or implementation
  2. Run the Design Review Gate (`/review-design` or invoke the `design-review-gate` skill)
  3. Wait for all 5 review agents (PM, Architect, Designer, Security, CTO) to APPROVE
  4. Only after ALL APPROVED, proceed to PRD Writing

**PRD Workflow (After Design Review Gate):**

After Design Review Gate approves, follow this sequence before implementation:

1. **PRD Writing** — Write the Product Requirements Document using `docs/PRD.md` template:
   - Product Vision (what problem does this solve, why does it exist)
   - User Personas (who uses it, what are their goals/pain points)
   - User Stories (P0/P1/P2 with acceptance criteria)
   - Requirements (functional and non-functional)
   - Metrics & Success Criteria
   - Timeline & Milestones

2. **PRD Review** — Have PM Agent (or user as PM) review the PRD:
   - Is the scope clear (what's in, what's out)?
   - Are success metrics measurable?
   - Are user stories testable?
   - Iterate if needed (max 2 rounds)

3. **Task Decomposition** — Break PRD into discrete BEADS tasks:
   ```bash
   bd create "PRD Task: <feature-area>" --type task --parent <epic-id> \
     --description "From: <PRD-section>\nUser Story: <story>\nAcceptance Criteria: <AC>\nPriority: P0/P1"
   ```

4. **Test Case Writing** — Spawn Test Automator Agent for each BEADS task:
   ```bash
   # Spawn Test Automator Agent
   Task({
     subagent_type: "general-purpose",
     description: "Write tests for task <task-id>",
     prompt: `You are the TEST AUTOMATOR AGENT.

   Read the task: bd show <task-id> --json
   Read the PRD for requirements context

   Your job:
   1. Write unit tests FIRST (RED phase) - tests must fail before implementation
   2. Write integration tests for component interactions
   3. Write E2E tests for user flows (from PRD user stories)
   4. Ensure 100% coverage (lines, branches, functions, statements)
   5. Use shared mock factories from src/test-utils/factories/

   Follow TDD: RED (write failing tests) → GREEN (implement to pass) → REFACTOR

   Use Test Automator Agent definition: skills/start/agents/test-automator-agent.md

   Report: Coverage report + test files created`
   })
   ```

   Test types for each task:
   - **Unit tests**: Each component's logic (service, utility)
   - **Integration tests**: How components interact
   - **E2E tests**: User flows from PRD user stories

5. **Planning** — After test cases are written and passing, proceed to Architect for implementation plan

**PRD is the source of truth** — all tasks, test cases, and implementation must trace back to PRD requirements.

**Problem Definition outputs:**

- [ ] Clear scope (what's in, what's out)
- [ ] DoD items (enumerated, independently verifiable)
- [ ] File scope (which files will be affected)
- [ ] Human checkpoints (where to pause for review)

### 2. Simple Task Flow

If user confirms it's a simple task:

#### Essential Steps

- [ ] Read relevant docs if unfamiliar with area
- [ ] Check existing patterns for similar functionality
- [ ] Make the change following existing patterns
- [ ] Write/update tests if logic changes
- [ ] Run tests, lint, and build
- [ ] Create simple PR with clear description

### 3. Complex Task Flow

If it's a complex task:

- Create a BEADS epic: `bd create --title "<task>" --type epic --priority 2`
- Use the full task completion checklist
- Consider breaking into smaller tasks as BEADS sub-issues
- Use extended thinking for planning
- Create detailed implementation plan

#### Orchestrated Execution (for tasks with DoD items)

When the task has a spec with Definition of Done items, use the orchestrated execution pattern:

1. **Create implementation plan** — decompose into work units with DoD items, file scopes, dependencies
2. **Plan Review Gate (BLOCKING)** — submit plan to adversarial review (3 reviewers: Feasibility, Completeness, Scope & Alignment must all PASS). This gate is MANDATORY — do NOT present the plan to the user or begin implementation until all 3 reviewers PASS. See `skills/plan-review-gate/SKILL.md`
3. **Execute** the 4-phase loop per work unit: IMPLEMENT → VALIDATE → ADVERSARIAL REVIEW → COMMIT
4. **Final review** after all work units: cross-unit integration check
5. **Self-reflect**: Run `/self-reflect` to extract learnings, then commit knowledge base updates
6. **Create PR** — knowledge base changes are included in the PR

See the `orchestrated-execution` skill for the full pattern. Key principles:
- **Trust nothing, verify everything**: Run quality gates independently, never trust subagent self-reports
- **Adversarial review**: Fresh reviewer checks each DoD item with file:line evidence
- **Human checkpoints**: Pause at planned review points before continuing
- **Recovery**: Max 3 retries per work unit, then escalate with failure history
- **No shortcuts**: NEVER use `--no-verify` on commits, NEVER skip coverage gates, NEVER self-certify

#### Multi-Agent Orchestration (for large features)

For complex tasks requiring multiple phases, consider spawning sub-agents:

**Model specialization guidance:**

| Model  | Best For                                                  |
| ------ | --------------------------------------------------------- |
| Opus   | Orchestration, architecture, security analysis, synthesis |
| Sonnet | Code analysis, implementation, code review, feature work  |
| Haiku  | Metrics collection, simple analysis, data processing      |

**Pattern**: Spawn parallel sub-agents for independent work (e.g., code review + security audit), sequential agents for dependent phases (research -> planning -> implementation).

### 4. Task Escalation

If a "simple task" becomes complex during implementation:

- Stop and reassess
- Create a BEADS epic: `bd create --title "<task>" --type epic --priority 2`
- Switch to full checklist workflow
- Inform user of complexity change
- Consider breaking into multiple PRs
