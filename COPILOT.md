# GitHub Copilot

This root-level `COPILOT.md` restores the repository's Copilot instruction contract from the source-of-truth instruction set used by the repo's agent tooling.

When a repository-specific generated contract exists, it is the authority. If the repo contains a `MASTER/` constitution or an agent contract, follow it before any broader editing assumptions. Otherwise, use the repo's README and local docs, keep changes path-scoped, validate with the smallest relevant checks, and do not force-push.

Rules:
- Read the relevant repo contract and task context before editing.
- Prefer the smallest, path-scoped change.
- Do not overwrite generated files unless the source-of-truth is updated in the same change.
- Keep generated agent instructions, prompts, and root compatibility files synchronized.
- Validate with the smallest relevant command or test for the code you changed.
- Never force-push or claim completion without evidence.
