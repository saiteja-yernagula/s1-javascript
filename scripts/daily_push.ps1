param()

# Move to repo root (assumes this script is in the repository under `scripts/`)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")
Set-Location $repoRoot

Write-Output "Repository root: $repoRoot"

try {
    git --version > $null 2>&1
} catch {
    Write-Error "git not found in PATH. Aborting."
    exit 1
}

# Stage all changes
git add -A

# Check for any changes to commit
$status = git status --porcelain

if ($status -and $status.Trim()) {
    Write-Output "Changes detected. Creating commit with message 'dailynotes'."
    $commitResult = git commit -m 'dailynotes' 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git commit failed: $commitResult"
        exit $LASTEXITCODE
    }
} else {
    Write-Output "No changes detected. Creating an empty commit with message 'dailynotes'."
    git commit --allow-empty -m 'dailynotes' 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git empty commit failed"
        exit $LASTEXITCODE
    }
}

Write-Output "Pushing to remote..."
git push
if ($LASTEXITCODE -ne 0) {
    Write-Error "git push failed (exit code $LASTEXITCODE)"
    exit $LASTEXITCODE
}

Write-Output "Daily push complete."
