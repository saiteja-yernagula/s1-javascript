# Daily push scheduling

This folder contains `daily_push.ps1`, a PowerShell script that commits (message `dailynotes`) and pushes the repository.

Script path (relative to repo): `scripts/daily_push.ps1`

Quick test (run from repo root):

```powershell
# run the script directly
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\daily_push.ps1"
```

Register a Windows Scheduled Task (run in an elevated or standard PowerShell depending on your environment):

Option A — use `schtasks` (works in most environments):

```powershell
schtasks /Create /SC DAILY /TN "DailyGitPush" /TR "powershell -NoProfile -ExecutionPolicy Bypass -File \"c:\teja\s1-javascript\scripts\daily_push.ps1\"" /ST 14:00 /F
```

Option B — use Task Scheduler cmdlets (PowerShell 3+). Run this in PowerShell as the current user:

```powershell
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "c:\teja\s1-javascript\scripts\daily_push.ps1"'
$trigger = New-ScheduledTaskTrigger -Daily -At 14:00
Register-ScheduledTask -TaskName "DailyGitPush" -Action $action -Trigger $trigger -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable)
```

Notes:
- Ensure `git` is in PATH and the account running the task has the necessary Git credentials (credential manager, SSH key, or stored credentials) so `git push` can authenticate non-interactively.
- If you prefer to run under a specific user, adjust the scheduled task creation accordingly and provide credentials when prompted.
- You can edit the task in Task Scheduler to change behavior (run only when user logged on / run whether user is logged on or not) and to run with highest privileges if needed.
