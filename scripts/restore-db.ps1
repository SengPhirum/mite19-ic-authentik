param(
    [Parameter(Mandatory = $true)]
    [string]$DumpPath
)

$ErrorActionPreference = "Stop"
$envFile = Join-Path (Get-Location) ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
        $name, $value = $_ -split '=', 2
        [Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim(), "Process")
    }
}

if (-not (Test-Path $DumpPath)) {
    throw "Dump file not found: $DumpPath"
}

$pgUser = if ($env:PG_USER) { $env:PG_USER } else { "authentik" }
$pgDb = if ($env:PG_DB) { $env:PG_DB } else { "authentik" }
$backupDir = Split-Path -Leaf (Split-Path -Parent $DumpPath)
$dumpFile = Split-Path -Leaf $DumpPath
$containerDump = "/backups/$backupDir/$dumpFile"

docker compose stop server worker grafana
docker compose exec -T postgresql dropdb --if-exists -U $pgUser $pgDb
docker compose exec -T postgresql createdb -U $pgUser $pgDb
docker compose exec -T postgresql pg_restore -U $pgUser -d $pgDb --clean --if-exists $containerDump
docker compose up -d server worker grafana

Write-Host "Database restored from $DumpPath"
