# 🚀 Releasing & Versioning

`frame-journey` uses **Semantic Release** to automate versioning and GitHub releases based on commit messages.

## 📝 Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. The commit type determines if a new release is triggered and what the new version number will be.

| Commit Type | Description | Resulting Version Bump |
| :--- | :--- | :--- |
| `feat:` | A new feature | **Minor** (e.g., 1.0.0 → 1.1.0) |
| `fix:` | A bug fix | **Patch** (e.g., 1.0.0 → 1.0.1) |
| `perf:` | Performance improvement | **Patch** |
| `feat!:` or `fix!:` | Breaking change | **Major** (e.g., 1.0.0 → 2.0.0) |
| `chore:` | Internal maintenance | **No Release** |
| `docs:` | Documentation changes | **No Release** |
| `style:` | Code formatting | **No Release** |
| `refactor:` | Code restructuring | **No Release** |
| `test:` | Adding/Fixing tests | **No Release** |
| `ci:` | CI/CD changes | **No Release** |

## ⚙️ How it Works

1. **Pull Requests**: When you merge a PR into `main`, the "Release" GitHub Action runs.
2. **Analysis**: It analyzes all new commits since the last tag.
3. **Decision**:
    - If there are only `chore`, `docs`, etc., **no release** is made.
    - If there is at least one `feat` or `fix`, a **new release** is triggered.
4. **Action**: 
    - The `VERSION` in `bin/frame-journey` is automatically updated.
    - A new Git tag is created.
    - A GitHub Release is published with auto-generated notes.

## 💡 Examples

- `feat: add support for HEVC encoding` -> Triggers a **Minor** release.
- `fix: correct audio stream selection logic` -> Triggers a **Patch** release.
- `docs: update installation instructions` -> **No release** triggered.
- `chore: update dependencies` -> **No release** triggered.
