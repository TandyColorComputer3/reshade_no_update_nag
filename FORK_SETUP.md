# Setting Up Your Fork

## Step 1: Fork on GitHub
1. Go to https://github.com/crosire/reshade
2. Click the "Fork" button
3. Choose your GitHub account/organization

## Step 2: Update Local Repository Remote

After forking, update your local repository to point to your fork:

```bash
# Add your fork as the new origin (replace YOUR_USERNAME with your GitHub username)
git remote set-url origin https://github.com/YOUR_USERNAME/reshade.git

# Keep the original as upstream for easy updates
git remote add upstream https://github.com/crosire/reshade.git

# Verify remotes
git remote -v
```

## Step 3: Push Your Changes

```bash
# Commit your changes if not already committed
git add .
git commit -m "Add custom modifications: disable update checks, suppress popups, auto-focus Home tab, auto-reload effects"

# Push to your fork
git push -u origin main
```

## Step 4: Update README (Optional)

You may want to add a note at the top of README.md indicating this is a modified version:

```markdown
> **Note**: This is a custom fork with modifications. See [CHANGES.md](CHANGES.md) for details.
```

## Keeping Up-to-Date with Upstream

To pull updates from the original ReShade repository:

```bash
# Fetch upstream changes
git fetch upstream

# Merge upstream changes into your branch
git merge upstream/main

# Resolve any conflicts if they occur
# Then push to your fork
git push origin main
```

