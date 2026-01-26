# GitHub Actions Workflow Setup

## Quick Start: Available Workflows

### 1. Package and Release
**Two trigger modes:**

**Tag trigger (automatic release)**:
- **When it runs**: Automatically when you create and push a tag (e.g., `v1.0.0`)
- **What it does**:
  - Packages the addon into a zip file
  - Creates a GitHub release with the zip attached (permanent)
  - Fetches latest external libraries from CurseForge
- **How to trigger**:
  ```bash
  git tag -a v1.0.0 -m "Release version 1.0.0"
  git push origin v1.0.0
  ```
  Or create a release on GitHub (which creates the tag automatically).

**Manual trigger (testing)**:
- **When it runs**: Only when manually triggered via GitHub Actions
- **What it does**:
  - Packages the addon into a zip file
  - Uploads zip as workflow artifact (temporary, expires in 7 days)
  - Does NOT create a GitHub release
  - Fetches latest external libraries from CurseForge
- **How to trigger**:
  1. Go to your repository on GitHub
  2. Click the **Actions** tab
  3. Select **"Package and Release"** from the left sidebar
  4. Click **"Run workflow"** dropdown button
  5. Select your branch
  6. Click the green **"Run workflow"** button
- **When to use**: Test packaging on branches before merging to main

---

### 2. Sync External Libraries (Manual)
**When it runs**: Only when you manually trigger it

**What it does**:
- Fetches latest library versions from CurseForge and GitHub
- Updates bundled library files in your repository
- Commits changes automatically if libraries were updated

**How to run**:
1. Go to your repository on GitHub
2. Click the **Actions** tab
3. Select **"Sync External Libraries"** from the left sidebar
4. Click **"Run workflow"** dropdown button
5. Select your branch (usually `main`)
6. Click the green **"Run workflow"** button

**When to use**: Run this periodically to keep your bundled library versions up-to-date with the latest bugfixes.

---

## Detailed Documentation

### How It Works

**Tag trigger (release)**:
1. **Trigger**: When you create and push an annotated tag (e.g., `v1.0.0`), the workflow automatically runs
2. **Packaging**: Uses [BigWigs Packager](https://github.com/BigWigsMods/packager) to create a zip file
3. **Release**: Creates a GitHub release with the zip file attached (permanent)
4. **External Libraries**: Fetches latest versions from CurseForge during packaging (see `.pkgmeta`)

**Manual trigger (testing)**:
1. **Trigger**: Manually via GitHub Actions UI
2. **Packaging**: Uses [BigWigs Packager](https://github.com/BigWigsMods/packager) to create a zip file (skips release creation)
3. **Artifact**: Uploads zip file as workflow artifact (temporary, 7 days retention)
4. **External Libraries**: Fetches latest versions from CurseForge during packaging (see `.pkgmeta`)

### Setup Instructions

#### 1. Configure Repository Permissions

Go to your repository → Settings → Actions → General → Workflow permissions:
- Select "Read and write permissions"
- Check "Allow GitHub Actions to create and approve pull requests" (if needed)

#### 2. Create Release Tag

Create an annotated tag (not a lightweight tag):
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

Or create the tag directly on GitHub when creating a release.

#### 3. Optional: Enable Auto-Upload to Other Platforms

Currently, the workflow only creates GitHub releases. The API keys for other platforms are commented out in the workflow file.

**To enable uploads to CurseForge, WoWInterface, or Wago:**

1. Uncomment the corresponding lines in `.github/workflows/release.yml`:
   ```yaml
   CF_API_KEY: ${{ secrets.CF_API_KEY }}
   WOWI_API_TOKEN: ${{ secrets.WOWI_API_TOKEN }}
   WAGO_API_TOKEN: ${{ secrets.WAGO_API_TOKEN }}
   ```

2. Add the secrets to your repository:
   **Repository → Settings → Secrets and variables → Actions → New repository secret**
   - `CF_API_KEY`: CurseForge API key (if uploading to CurseForge)
   - `WOWI_API_TOKEN`: WoWInterface API token (if uploading to WoWInterface)
   - `WAGO_API_TOKEN`: Wago API token (if uploading to Wago)

**Note**: The `GITHUB_TOKEN` is automatically provided by GitHub Actions and doesn't need to be added manually.

### External Libraries

The workflow uses **external libraries** from CurseForge as defined in `.pkgmeta`:
- `LibStub` - Fetched from CurseForge during packaging
- `CallbackHandler-1.0` - Fetched from CurseForge during packaging
- `LibSharedMedia-3.0` - Fetched from CurseForge during packaging

**Bundled libraries** in `Libs/` will be **overwritten** by externals during packaging. This ensures you always get the latest bugfixes.

**LibDataBroker-1.1** is bundled in `Libs/Broker_SmartBuff/` and is not available as a standard external, so it remains bundled.

### What Gets Packaged

The packager reads the `.pkgmeta` file which defines:
- Package name: `SmartBuff`
- External libraries (fetched from CurseForge during packaging)

The final zip will contain all files needed for the addon to work, with external libraries at their latest versions.

### Current Configuration

- ✅ **GitHub Releases**: Enabled (automatic)
- ✅ **External Libraries**: Enabled (fetched from CurseForge)
- ❌ **CurseForge**: Disabled (commented out)
- ❌ **WoWInterface**: Disabled (commented out)
- ❌ **Wago**: Disabled (commented out)

To enable any of the disabled platforms, uncomment the corresponding environment variable in `release.yml` and add the required secret.
