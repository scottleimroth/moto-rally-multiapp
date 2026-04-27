# CLAUDE.md - Project Instructions for Claude Code

---

## Section 1: Coding Principles

> Based on [Andrej Karpathy's CLAUDE.md guidelines](https://github.com/forrestchang/andrej-karpathy-skills) (MIT License). See LICENSE-KARPATHY.

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1.1 Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 1.2 Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 1.3 Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 1.4 Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- "Refactor X" -> "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

### 1.5 Examples

<details>
<summary>Click to expand real-world examples of these principles</summary>

#### Think Before Coding - Hidden Assumptions

**User:** "Add a feature to export user data"

**Bad** - writes immediately with hidden assumptions:
```python
def export_users(format='json'):
    """Export all users to a file."""
    users = User.query.all()
    if format == 'json':
        with open('users.json', 'w') as f:
            json.dump([u.to_dict() for u in users], f)
    elif format == 'csv':
        with open('users.csv', 'w') as f:
            writer = csv.DictWriter(f, fieldnames=['id', 'email', 'name'])
            writer.writeheader()
            writer.writerows([u.to_dict() for u in users])
    return f"Exported {len(users)} users"
```
Problems: Assumed ALL users (privacy?), assumed file location, assumed fields, assumed CSV fieldnames.

**Good** - surface assumptions first:
```
Before implementing, I need to clarify:
1. Scope: Export all users or filtered subset? (privacy implications)
2. Format: Download file in browser? Background job? API endpoint?
3. Fields: Which user fields? (some might be sensitive)
4. Volume: How many users typically? (affects approach)

Simplest approach: Add an API endpoint that returns paginated JSON.
What's your preference?
```

#### Think Before Coding - Multiple Interpretations

**User:** "Make the search faster"

**Bad** - picks silently, adds caching + indexes + async without asking which "faster" matters.

**Good** - present options:
```
"Make the search faster" could mean:
1. Faster response time (add indexes, cache) - 2 hours
2. Handle more concurrent searches (async, pooling) - 4 hours
3. Faster perceived speed (partial results, progressive loading) - 3 hours

Current search: ~500ms for typical queries. Which aspect matters most?
```

#### Simplicity First - Over-abstraction

**User:** "Add a function to calculate discount"

**Bad** - overengineered:
```python
class DiscountStrategy(ABC):
    @abstractmethod
    def calculate(self, amount: float) -> float: pass

class PercentageDiscount(DiscountStrategy):
    def __init__(self, percentage: float):
        self.percentage = percentage
    def calculate(self, amount: float) -> float:
        return amount * (self.percentage / 100)

class FixedDiscount(DiscountStrategy):
    # ... another 10 lines

@dataclass
class DiscountConfig:
    strategy: DiscountStrategy
    min_purchase: float = 0.0
    max_discount: float = float('inf')

class DiscountCalculator:
    # ... another 20 lines
```

**Good** - minimum code:
```python
def calculate_discount(amount: float, percent: float) -> float:
    """Calculate discount amount. percent should be 0-100."""
    return amount * (percent / 100)
```
Add complexity only when you actually need multiple discount types.

#### Simplicity First - Speculative Features

**User:** "Save user preferences to database"

**Bad** - adds caching, validation, merge logic, notifications nobody asked for (100+ lines).

**Good** - just what was asked:
```python
def save_preferences(db, user_id: int, preferences: dict):
    """Save user preferences to database."""
    db.execute(
        "UPDATE users SET preferences = ? WHERE id = ?",
        (json.dumps(preferences), user_id)
    )
```

#### Surgical Changes - Drive-by Refactoring

**User:** "Fix the bug where empty emails crash the validator"

**Bad** - also adds type hints, docstrings, changes quote style, adds username validation, reformats whitespace. Every changed line should trace to the request - these don't.

**Good** - only fix the bug:
```diff
  def validate_user(user_data):
      # Check email format
-     if not user_data.get('email'):
+     email = user_data.get('email', '')
+     if not email or not email.strip():
          raise ValueError("Email required")

      # Basic email validation
-     if '@' not in user_data['email']:
+     if '@' not in email:
          raise ValueError("Invalid email")
```

#### Surgical Changes - Style Drift

**User:** "Add logging to the upload function"

**Bad** - changes quote style (''->""), adds type hints, adds docstring, reformats boolean logic.

**Good** - match existing style, only add logging lines:
```diff
+ import logging
+ logger = logging.getLogger(__name__)
+
  def upload_file(file_path, destination):
+     logger.info(f'Starting upload: {file_path}')
      try:
          # ... existing code unchanged ...
          if response.status_code == 200:
+             logger.info(f'Upload successful: {file_path}')
              return True
          else:
+             logger.error(f'Upload failed: {file_path}, status={response.status_code}')
              return False
      except Exception as e:
-         print(f"Error: {e}")
+         logger.exception(f'Upload error: {file_path}')
          return False
```

#### Goal-Driven Execution - Vague vs. Verifiable

**User:** "Fix the authentication system"

**Bad** - "I'll review the code, identify issues, make improvements, and test." No clear success criteria.

**Good** - define verifiable goals:
```
What specific issue? If it's "users stay logged in after password change":

1. Write test: Change password -> verify old session invalidated
   Verify: Test fails (reproduces bug)
2. Implement: Invalidate sessions on password change
   Verify: Test passes
3. Check edge cases: Multiple sessions, concurrent changes
   Verify: Additional tests pass
4. Verify no regression: Existing auth tests still pass
   Verify: Full test suite green
```

#### Goal-Driven Execution - Test-First

**User:** "The sorting breaks when there are duplicate scores"

**Bad** - immediately changes sort logic without confirming the bug exists.

**Good** - reproduce first, then fix:
```python
# 1. Write test that reproduces the issue
def test_sort_with_duplicate_scores():
    scores = [
        {'name': 'Alice', 'score': 100},
        {'name': 'Bob', 'score': 100},
        {'name': 'Charlie', 'score': 90},
    ]
    result = sort_scores(scores)
    # Verify: Run 10 times, fails with inconsistent ordering

# 2. Fix with stable sort
def sort_scores(scores):
    return sorted(scores, key=lambda x: (-x['score'], x['name']))
    # Verify: Test passes consistently
```

#### Anti-Patterns Summary

| Principle | Anti-Pattern | Fix |
|-----------|-------------|-----|
| Think Before Coding | Silently assumes format, fields, scope | List assumptions, ask for clarification |
| Simplicity First | Strategy pattern for single calculation | One function until complexity is needed |
| Surgical Changes | Reformats quotes, adds type hints while fixing bug | Only change lines that fix the issue |
| Goal-Driven | "I'll review and improve the code" | "Write test -> make it pass -> verify" |

**Key insight:** The overcomplicated examples aren't obviously wrong - they follow design patterns. The problem is **timing**: they add complexity before it's needed, making code harder to understand, more buggy, and slower to implement. Simple code can always be refactored later when complexity is actually required.

</details>

---

## Section 2: Repository Standards

This repo follows Scott Leimroth's standard repository format. All AI agents (Claude Code, Sid, Alex, sub-agents) must follow these rules.

### Required Files

Every repo MUST contain:
1. **README.md** - With a download/demo badge at the top (see badge rules below)
2. **CREDENTIALS.md** - API keys and secrets (ALWAYS .gitignored, NEVER committed)
3. **SECURITY_AUDIT.md** - Security checklist
4. **TODO.md** - Development log and task tracker
5. **.gitignore** - Must include CREDENTIALS.md, .env, .env.*, *.key, *.pem
6. **CLAUDE.md** - This file

If any of these files are missing, create them immediately before doing other work.

### README Badge Rules

The first thing after the title MUST be a prominent link to whatever the user can actually use:

- **Downloadable (APK/EXE):** `[![Download](https://img.shields.io/badge/DOWNLOAD-APK-green?style=for-the-badge)](RELEASE-URL)`
- **Web app/demo:** `[![Live Demo](https://img.shields.io/badge/LIVE-DEMO-blue?style=for-the-badge)](URL)`
- **Website:** `[![Visit Site](https://img.shields.io/badge/VISIT-SITE-blue?style=for-the-badge)](URL)`
- **Library/package:** `[![npm](https://img.shields.io/npm/v/PACKAGE?style=for-the-badge)](URL)`
- **Docs/research:** `[![Read Docs](https://img.shields.io/badge/READ-DOCS-orange?style=for-the-badge)](URL)`

**Rule: If someone visits the repo, they must immediately know how to try it.**

### TODO.md Format

```markdown
# PROJECT NAME - Development Log

## Last Session
- **Date:** YYYY-MM-DD
- **Summary:** What was worked on
- **Key changes:** What was added/fixed/modified
- **Stopped at:** Exactly where work left off
- **Blockers:** Anything preventing progress

## Current Status
### Working Features
### In Progress
### Known Bugs

## TODO - Priority
1. [ ] Task

## TODO - Nice to Have
- [ ] Enhancement

## Completed
- [x] Task (YYYY-MM-DD)

## Notes
```

### Workflow

1. **Start session** - Read TODO.md first to pick up where you left off
2. **During work** - Update TODO.md as features are built
3. **Before commit** - Run SECURITY_AUDIT.md checklist, confirm CREDENTIALS.md is NOT staged
4. **On release** - Ensure README badge links to latest release/demo
5. **End of session** - Update TODO.md "Last Session" section

### Code Style

- Clear, descriptive variable names
- Comments explaining WHY, not WHAT
- No hardcoded secrets - use environment variables
- Keep functions small and focused

### Repo Naming

- Sid's repos: `sid-` prefix
- Alex's repos: `alex-` prefix
- Scott's personal repos: no prefix

### Quality Bar

- README clear enough to understand in 30 seconds
- No broken links
- No placeholder text
- Download/demo links must work
- Concise - no walls of text

---

## Section 3: Project-Specific Instructions

<!-- Add project-specific instructions, context, and notes below this line. -->
<!-- This section is preserved when the template is updated across repos. -->
