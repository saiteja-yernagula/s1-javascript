param()

# Move to repo root (assumes this script is in the repository under `scripts/`)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")
Set-Location $repoRoot

# Logging
$logFile = Join-Path $scriptDir 'daily_push.log'
function Log {
    param([string]$msg)
    $time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "$time `t $msg"
    $line | Out-File -FilePath $logFile -Encoding utf8 -Append
}

Log "Repository root: $repoRoot"

try {
    git --version > $null 2>&1
} catch {
    Log "git not found in PATH. Aborting."
    Write-Error "git not found in PATH. Aborting."
    exit 1
}

Log "GIT STATUS BEFORE:"; git status --porcelain | ForEach-Object { Log "  $_" }

# list day* folders (helpful to see what the scheduled task saw)
Get-ChildItem -Name -Directory day* -ErrorAction SilentlyContinue | ForEach-Object { Log "DIR: $_" }

# Stage all changes
Log "Running: git add -A"
git add -A 2>&1 | ForEach-Object { Log "git add: $_" }

# Check for any changes to commit
$status = git status --porcelain

if ($status -and $status.Trim()) {
    Log "Changes detected. Creating commit with message 'dailynotes'."
    $commitResult = git commit -m 'dailynotes' 2>&1
    if ($LASTEXITCODE -ne 0) {
        Log "git commit failed: $commitResult"
        Write-Error "git commit failed: $commitResult"
        exit $LASTEXITCODE
    } else {
        $commitResult | ForEach-Object { Log "git commit: $_" }
    }
} else {
    Log "No changes detected. Creating an empty commit with message 'dailynotes'."
    $commitResult = git commit --allow-empty -m 'dailynotes' 2>&1
    if ($LASTEXITCODE -ne 0) {
        Log "git empty commit failed: $commitResult"
        Write-Error "git empty commit failed"
        exit $LASTEXITCODE
    } else {
        $commitResult | ForEach-Object { Log "git commit (empty): $_" }
    }
}

Log "Pushing to remote..."
$pushResult = git push 2>&1
if ($LASTEXITCODE -ne 0) {
    $pushResult | ForEach-Object { Log "git push error: $_" }
    Write-Error "git push failed (exit code $LASTEXITCODE)"
    exit $LASTEXITCODE
} else {
    $pushResult | ForEach-Object { Log "git push: $_" }
}

Log "Daily push complete."
Write-Output "Daily push complete. See $logFile for details."
