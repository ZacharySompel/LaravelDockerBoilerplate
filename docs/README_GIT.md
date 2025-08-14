# Git Basics for This Project

Git tracks changes to your code. You’ll mostly use:

* **clone** – download the repo
* **status** – see what changed
* **add/commit** – save your changes
* **pull** – get latest changes from the remote repo
* **push** – upload your changes
* **branch/checkout** – work on a separate line of development
* **merge/rebase** – bring changes together
* **fetch** – download changes without altering your local files

> Commands assume you’re in the repo folder.

---

## 1) Getting the repo

### Clone (first time)

```bash
git clone <YOUR_REPO_URL> laravel-stack
cd laravel-stack
```

### Check your current branch

```bash
git branch
```

An asterisk `*` marks the current branch (often `main`).

---

## 2) Keeping your branch up to date

### See what’s changed locally

```bash
git status
```

### Fetch (check for remote updates without changing local files)

```bash
git fetch
```

### Get latest changes from remote

```bash
git pull
```

* Pull = **fetch** (download) + **merge** (combine) remote changes into your current branch.

### Alternative: rebase instead of merge (tidier history)

```bash
git pull --rebase
```

* Rebase = replay your local commits on top of what’s new upstream.

---

## 3) Making changes safely with branches

### Create and switch to a new branch

```bash
git checkout -b feature/my-task
```

### Switch between branches

```bash
git checkout main
git checkout feature/my-task
```

---

## 4) Saving your work

### Stage (pick files to include)

```bash
git add .            # add everything
# or pick specific files:
git add app/README.md
```

### Commit (save a snapshot with a message)

```bash
git commit -m "Add contact form validation and tests"
```

### Push (upload your branch to the remote)

```bash
git push -u origin feature/my-task
```

---

## 5) Bringing main into your feature branch

While on `feature/my-task`:

### Option A: merge main into your branch

```bash
git checkout feature/my-task
git fetch origin
git merge origin/main
```

### Option B (preferred): rebase onto main (clean history)

```bash
git checkout feature/my-task
git fetch origin
git rebase origin/main
```

If conflicts happen:

1. Fix the files (look for `<<<<<<<` markers).
2. `git add <fixed-files>`
3. `git rebase --continue`

---

## 6) Pull Requests (PRs)

1. Push your branch:

   ```bash
   git push -u origin feature/my-task
   ```
2. In GitHub, click **Compare & pull request**.
3. Request a review, address comments, and merge when approved.

---

## 7) Common fixes

* **Undo last commit but keep changes staged**

  ```bash
  git reset --soft HEAD~1
  ```
* **Undo last commit and unstage changes**

  ```bash
  git reset --mixed HEAD~1
  ```
* **Throw away local changes (⚠ careful)**

  ```bash
  git reset --hard
  ```

---

## 8) Quick glossary

* **origin** – the default name of your remote repository (GitHub).
* **branch** – a separate line of development.
* **merge** – combine two branches.
* **rebase** – replay commits on top of another branch.
* **fetch** – download remote changes without merging.
* **pull** – fetch + merge (or rebase).
