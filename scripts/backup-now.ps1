param(
    [string]$Stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
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

$outDir = Join-Path "backups" $Stamp
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$pgUser = if ($env:PG_USER) { $env:PG_USER } else { "authentik" }
$pgDb = if ($env:PG_DB) { $env:PG_DB } else { "authentik" }

docker compose exec -T postgresql pg_dump -U $pgUser -d $pgDb -Fc -f "/backups/$Stamp/authentik.dump"
tar -czf (Join-Path $outDir "static.tar.gz") data certs custom-templates blueprints

Write-Host "Backup written to $outDir"
Write-Host "Database dump: $outDir/authentik.dump"
Write-Host "Static archive: $outDir/static.tar.gz"
