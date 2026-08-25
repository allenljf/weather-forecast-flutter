# Delivery

What to do when a ticket's work is done. Applies to `/implement` and to any session that finishes a ticket.

## Steps

1. **Commit** to `main` — no branch, no PR (Q14). End the message with `Refs #<n>`.
2. **Push.**
3. **Close the ticket**: tick the acceptance criteria in the body, then `gh issue close <n> --comment "..."` with the commit sha and how each criterion was verified.
4. **Hand off**: name the next ticket and print the prompt below, filled in, so a fresh session can start from a paste.

Step 3 is load-bearing: tickets are wired with GitHub's native dependencies, so the rest of the backlog only becomes reachable once its blockers are **closed**. Commits alone move nothing. Find the next ticket with the frontier query in [issue-tracker.md](issue-tracker.md).

## Handoff prompt

```
規格在 #14，決策脈絡在 docs/GRILL_LOG.md，詞彙在 CONTEXT.md。先讀這三份。

/implement #<n>

- 用 /tdd，只在 #14 列出的五個接縫上測
- 只做這一張票
```

The delivery steps above need no restating in the prompt: this file is reached from `AGENTS.md` on every session.

## Code review runs once, at the end

`/implement` ends by calling `/code-review`. Here that review runs **after the last implementation ticket**, covering the whole delivery in one pass, and its report is published as a GitHub issue (Q37).

## When reality contradicts a decision

Implementation sometimes disproves a decision made during grilling (see F41–F44 under Q30). Record the correction in all three places, each in its own voice — `docs/GRILL_LOG.md` carries the reasoning, the ticket carries the acceptance criteria, the code carries a one-line comment. Copying one wording into all three produces contradictory specs; see the Further Notes in #14.
