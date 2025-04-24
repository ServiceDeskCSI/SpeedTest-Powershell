# --------------------------------------------
# CONFIGURATION
# --------------------------------------------

# Set to "true" to write the log file, or "false" to skip logging
$SaveLog          = "true"
# Set to "true" to save the raw JSON, or "false" to skip saving JSON
$SaveJson         = "false"

# How many times to retry on failure
$MaxRetries       = 3
# Delay between retries (seconds)
$RetryDelaySeconds= 5

# Ookla Speedtest CLI download URL (win64)
$Url              = "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-win64.zip"

# Where to store everything
$TargetFolder     = "C:\temp"
$ExtractFolder    = Join-Path $TargetFolder "speedtest"
$TempZip          = Join-Path $TargetFolder "speedtest.zip"
$ExePath          = Join-Path $ExtractFolder "speedtest.exe"

# --------------------------------------------
# PREP: ensure folders exist
# --------------------------------------------
if (-not (Test-Path $ExtractFolder)) {
    New-Item -Path $ExtractFolder -ItemType Directory -Force | Out-Null
}

# --------------------------------------------
# DOWNLOAD & EXTRACT (once)
# --------------------------------------------
if (-not (Test-Path $ExePath)) {
    #Write-Host "Downloading Speedtest CLI to $TempZip..."
    Invoke-WebRequest -Uri $Url -OutFile $TempZip -UseBasicParsing

    #Write-Host "Extracting to $ExtractFolder..."
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($TempZip, $ExtractFolder)
}

# --------------------------------------------
# RUN SPEEDTEST WITH RETRIES & PARSE OUTPUT
# --------------------------------------------
$attempt = 0
do {
    $attempt++
    #Write-Host "Running Speedtest (attempt $attempt of $MaxRetries)…"
    # capture stdout+stderr as objects
    $rawObjects = & $ExePath --accept-license --accept-gdpr --format json 2>&1
    # convert everything to string
    $rawLines  = $rawObjects | ForEach-Object { $_.ToString() }
    $rawText   = $rawLines -join "`n"

    # locate JSON object within the output
    $startIndex = $rawText.IndexOf('{')
    $endIndex   = $rawText.LastIndexOf('}')
    if ($startIndex -lt 0 -or $endIndex -lt $startIndex) {
        Write-Warning "  → no JSON payload detected."
        if ($attempt -lt $MaxRetries) { Start-Sleep -Seconds $RetryDelaySeconds; continue }
        else { Write-Error "All $MaxRetries attempts failed: no JSON returned."; exit 1 }
    }

    # extract JSON substring
    $json = $rawText.Substring($startIndex, $endIndex - $startIndex + 1)

    # try parse
    try {
        $data = $json | ConvertFrom-Json
    } catch {
        Write-Warning "  → failed to parse JSON."
        if ($attempt -lt $MaxRetries) { Start-Sleep -Seconds $RetryDelaySeconds; continue }
        else { Write-Error "All $MaxRetries attempts failed parsing JSON."; exit 1 }
    }

    # check for speedtest error
    if ($null -ne $data.error) {
        Write-Warning "  → Speedtest returned error: $($data.error)"
        if ($attempt -lt $MaxRetries) { Start-Sleep -Seconds $RetryDelaySeconds; continue }
        else { Write-Error "All $MaxRetries attempts failed: $($data.error)"; exit 1 }
    }

    # success!
    break

} while ($attempt -lt $MaxRetries)

# --------------------------------------------
# EXTRACT METRICS
# --------------------------------------------
$Latency    = [math]::Round($data.ping.latency,  2)
$Download   = [math]::Round(($data.download.bandwidth * 8) / 1MB, 2)
$Upload     = [math]::Round(($data.upload.bandwidth   * 8) / 1MB, 2)
$ResultURL  = $data.result.url

# --------------------------------------------
# SAVE RAW JSON (if enabled)
# --------------------------------------------
$Date = Get-Date -Format 'yyyy-MM-dd'
if ($SaveJson -eq "true") {
    $JsonFile = Join-Path $ExtractFolder "$Date-Speedtest.json"
    $json | Out-File -FilePath $JsonFile -Encoding UTF8
    #Write-Host "`nRaw JSON saved to: $JsonFile"
}

# --------------------------------------------
# LOGGING (if enabled)
# --------------------------------------------
if ($SaveLog -eq "true") {
    $LogFile = Join-Path $ExtractFolder "$Date-Speedtest.txt"
    $LogContent = @(
        "Timestamp     : $(Get-Date -Format 'u')"
        ""
        "=== Full JSON Results ==="
        $json
        ""
        "=== Summary ==="
        "Latency    : $Latency ms"
        "Download   : $Download Mbps"
        "Upload     : $Upload Mbps"
        ""
        "Result URL : $ResultURL"
    )
    $LogContent | Out-File -FilePath $LogFile -Encoding UTF8
    #Write-Host "`nResults have been logged to: $LogFile"
}

# --------------------------------------------
# CONSOLE OUTPUT
# --------------------------------------------
Write-Host ""
Write-Host "Latency    : $Latency ms"
Write-Host "Download   : $Download Mbps"
Write-Host "Upload     : $Upload Mbps"
Write-Host "Result URL : $ResultURL"
