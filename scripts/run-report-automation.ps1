param(
    [string]$GroupName = "GroupName",
    [switch]$SkipDockerStart,
    [switch]$SkipBrowserInstall,
    [switch]$NoVideo,
    [switch]$SkipBackupRestore,
    [switch]$Headful
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir "..")
$venvDir = Join-Path $repoRoot ".venv-report"
$pythonExe = Join-Path $venvDir "Scripts\python.exe"

Push-Location $repoRoot
try {
    if (-not (Test-Path $pythonExe)) {
        Write-Host "Creating local report automation environment..."
        python -m venv $venvDir
    }

    Write-Host "Installing report automation dependencies..."
    & $pythonExe -m pip install --upgrade pip
    & $pythonExe -m pip install -r (Join-Path $scriptDir "requirements-report.txt")

    if (-not $SkipBrowserInstall) {
        Write-Host "Installing Playwright Chromium browser..."
        & $pythonExe -m playwright install chromium
    }

    $automationArgs = @(
        (Join-Path $scriptDir "automate-report.py"),
        "--group-name", $GroupName
    )

    if ($SkipDockerStart) { $automationArgs += "--skip-docker-start" }
    if ($NoVideo) { $automationArgs += "--no-video" }
    if ($SkipBackupRestore) { $automationArgs += "--skip-backup-restore" }
    if ($Headful) { $automationArgs += "--headful" }

    & $pythonExe @automationArgs
}
finally {
    Pop-Location
}
