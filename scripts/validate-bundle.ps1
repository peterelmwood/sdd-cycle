#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Validates that the SDD Cycle bundle is internally consistent and installable.

.DESCRIPTION
    Read-only guardrail (constitution Principle V). Asserts:
      1. The four manifests parse.
      2. Each bundle-pinned component version equals that component's own manifest version.
      3. Declared speckit_version floors are consistent across manifests.
      4. Every file referenced by a manifest exists.
      5. The constitution is ratified (no placeholder tokens; has a Version line).
      6. The sdd workflow begins with the mandatory `branch` step (constitution IV).

    Exits 0 when all assertions pass; non-zero with a specific message otherwise.
    Contract: specs/001-extension-readiness/contracts/validation-check.md

.EXAMPLE
    pwsh ./scripts/validate-bundle.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Resolve repo root as the parent of this script's directory.
$RepoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()
$checks   = [System.Collections.Generic.List[string]]::new()

function Add-Failure([string]$m) { $script:failures.Add($m) }
function Add-Pass([string]$m)    { $script:checks.Add($m) }

function Read-Manifest([string]$relPath) {
    $full = Join-Path $RepoRoot $relPath
    if (-not (Test-Path $full)) {
        Add-Failure "MISSING FILE: manifest '$relPath' does not exist."
        return $null
    }
    $text = Get-Content -Raw -Path $full
    # Minimal YAML sanity: reject hard tabs (invalid YAML indentation).
    if ($text -match "`t") {
        Add-Failure "PARSE: '$relPath' contains tab characters (invalid YAML indentation)."
        return $null
    }
    if ([string]::IsNullOrWhiteSpace($text)) {
        Add-Failure "PARSE: '$relPath' is empty."
        return $null
    }
    return $text
}

# Line-based scalar readers (no multiline regex -> no catastrophic backtracking).

function Get-ValueLine([string]$line) {
    # Returns the unquoted value from a "key: value" line, or $null.
    $m = [regex]::Match($line, ':\s*"?([^"\r\n]+?)"?\s*$')
    if ($m.Success) { return $m.Groups[1].Value.Trim() }
    return $null
}

function Get-BlockScalar([string]$text, [string]$block, [string]$key, [string]$label) {
    # Value of `key:` nested under a top-level `block:` header.
    $lines = $text -split "`r?`n"
    $inBlock = $false
    foreach ($line in $lines) {
        if ($line -match "^$([regex]::Escape($block)):\s*$") { $inBlock = $true; continue }
        if ($inBlock) {
            if ($line -match '^\S') { break }  # dedent to next top-level block
            if ($line -match "^\s+$([regex]::Escape($key)):") { return (Get-ValueLine $line) }
        }
    }
    Add-Failure "PARSE: could not read $label."
    return $null
}

function Get-PinnedVersion([string]$text, [string]$section, [string]$label) {
    # First `version:` appearing after a `  $section:` line (under provides:).
    $lines = $text -split "`r?`n"
    $seen = $false
    foreach ($line in $lines) {
        if (-not $seen) {
            if ($line -match "^\s+$([regex]::Escape($section)):\s*$") { $seen = $true }
            continue
        }
        if ($line -match '^\s+version:') { return (Get-ValueLine $line) }
        # stop if we reach the sibling section without finding a version
        if ($line -match '^\s+\w+:\s*$' -and $line -notmatch '^\s+version:') {
            if ($line -notmatch "^\s+$([regex]::Escape($section)):") { break }
        }
    }
    Add-Failure "PARSE: could not read $label."
    return $null
}

function Get-FirstStepId([string]$text, [string]$label) {
    # Id of the first list item under a top-level `steps:` block. Line-based to
    # stay consistent with the other readers (no multiline regex).
    $lines = $text -split "`r?`n"
    $inSteps = $false
    foreach ($line in $lines) {
        if ($line -match '^steps:\s*$') { $inSteps = $true; continue }
        if ($inSteps) {
            if ($line -match '^\S') { break }  # dedent out of steps block
            $m = [regex]::Match($line, '^\s*-\s*id:\s*"?([^"\r\n]+?)"?\s*$')
            if ($m.Success) { return $m.Groups[1].Value.Trim() }
        }
    }
    Add-Failure "PARSE: could not read $label."
    return $null
}

# --- Load manifests (Assertion 1) -------------------------------------------
$bundle    = Read-Manifest 'bundle.yml'
$extension = Read-Manifest 'extensions/sdd/extension.yml'
$workflow  = Read-Manifest 'workflows/sdd/workflow.yml'
$registry  = Read-Manifest '.specify/extensions.yml'

if ($null -ne $bundle -and $null -ne $extension -and $null -ne $workflow -and $null -ne $registry) {
    Add-Pass 'PARSE: all four manifests parse.'
}

# --- Extract values ---------------------------------------------------------
$bundleExtVer = if ($bundle) { Get-PinnedVersion $bundle 'extensions' 'bundle.yml extension pin (sdd)' } else { $null }
$bundleWfVer  = if ($bundle) { Get-PinnedVersion $bundle 'workflows'  'bundle.yml workflow pin (sdd)' } else { $null }
$bundleFloor  = if ($bundle) { Get-BlockScalar $bundle 'requires' 'speckit_version' 'bundle.yml speckit_version' } else { $null }

$extVer   = if ($extension) { Get-BlockScalar $extension 'extension' 'version' 'extension.yml version' } else { $null }
$extFloor = if ($extension) { Get-BlockScalar $extension 'requires' 'speckit_version' 'extension.yml speckit_version' } else { $null }

$wfVer   = if ($workflow) { Get-BlockScalar $workflow 'workflow' 'version' 'workflow.yml version' } else { $null }
$wfFloor = if ($workflow) { Get-BlockScalar $workflow 'requires' 'speckit_version' 'workflow.yml speckit_version' } else { $null }

# --- Assertion 2: version matches ------------------------------------------
if ($bundleExtVer -and $extVer) {
    if ($bundleExtVer -eq $extVer) {
        Add-Pass "VERSION: extension sdd pinned $bundleExtVer matches extension.yml."
    } else {
        Add-Failure "VERSION: bundle.yml pins extension sdd@$bundleExtVer but extensions/sdd/extension.yml declares $extVer."
    }
}
if ($bundleWfVer -and $wfVer) {
    if ($bundleWfVer -eq $wfVer) {
        Add-Pass "VERSION: workflow sdd pinned $bundleWfVer matches workflow.yml."
    } else {
        Add-Failure "VERSION: bundle.yml pins workflow sdd@$bundleWfVer but workflows/sdd/workflow.yml declares $wfVer."
    }
}

# --- Assertion 3: speckit_version floor consistency ------------------------
$floors = @($bundleFloor, $extFloor, $wfFloor) | Where-Object { $_ }
if ($floors.Count -eq 3) {
    $distinct = @($floors | Select-Object -Unique)
    if ($distinct.Count -eq 1) {
        Add-Pass "FLOOR: speckit_version consistent across manifests ($($distinct[0]))."
    } else {
        Add-Failure "FLOOR: speckit_version floors differ across manifests: $($floors -join ', ')."
    }
}

# --- Assertion 4: manifest file references exist ---------------------------
if ($extension) {
    $cmdFiles = [regex]::Matches($extension, '(?m)^\s*file:\s*"?([^"\r\n]+)"?')
    if ($cmdFiles.Count -eq 0) {
        Add-Failure "REFERENCE: extension.yml declares no command 'file:' entries."
    }
    foreach ($cf in $cmdFiles) {
        $rel = $cf.Groups[1].Value.Trim()
        $resolved = Join-Path (Join-Path $RepoRoot 'extensions/sdd') $rel
        if (Test-Path $resolved) {
            Add-Pass "REFERENCE: extension command file exists ($rel)."
        } else {
            Add-Failure "REFERENCE: extension.yml command file '$rel' not found (expected at extensions/sdd/$rel)."
        }
    }
}
# The bundle ships this workflow path; confirm it exists.
if (Test-Path (Join-Path $RepoRoot 'workflows/sdd/workflow.yml')) {
    Add-Pass 'REFERENCE: workflow file exists (workflows/sdd/workflow.yml).'
} else {
    Add-Failure 'REFERENCE: workflows/sdd/workflow.yml not found.'
}

# --- Assertion 5: constitution ratified ------------------------------------
$constPath = Join-Path $RepoRoot '.specify/memory/constitution.md'
if (Test-Path $constPath) {
    $const = Get-Content -Raw -Path $constPath
    $placeholders = [regex]::Matches($const, '\[[A-Z][A-Z0-9_ ]{2,}\]')
    if ($placeholders.Count -gt 0) {
        $sample = ($placeholders | Select-Object -First 3 | ForEach-Object { $_.Value }) -join ', '
        Add-Failure "CONSTITUTION: contains $($placeholders.Count) placeholder token(s) (e.g. $sample)."
    } elseif ($const -notmatch '\*\*Version\*\*:\s*\d+\.\d+\.\d+') {
        Add-Failure 'CONSTITUTION: missing a **Version**: X.Y.Z line.'
    } else {
        Add-Pass 'CONSTITUTION: ratified (no placeholders; has a Version line).'
    }
} else {
    Add-Failure 'CONSTITUTION: .specify/memory/constitution.md not found.'
}

# --- Assertion 6: workflow begins with the mandatory branch step -----------
if ($workflow) {
    $firstStep = Get-FirstStepId $workflow 'workflow.yml first step id'
    if ($firstStep) {
        if ($firstStep -eq 'branch') {
            Add-Pass 'CYCLE: sdd workflow begins with the mandatory branch step.'
        } else {
            Add-Failure "CYCLE: sdd workflow's first step is '$firstStep', expected 'branch' (the mandatory feature-branch step must run before specify)."
        }
    }
}

# --- Report -----------------------------------------------------------------
Write-Host ''
Write-Host 'SDD Cycle bundle validation' -ForegroundColor Cyan
Write-Host '---------------------------'
foreach ($c in $checks)   { Write-Host "  PASS  $c" -ForegroundColor Green }
foreach ($f in $failures) { Write-Host "  FAIL  $f" -ForegroundColor Red }
Write-Host ''

if ($failures.Count -gt 0) {
    Write-Host "$($failures.Count) failure(s), $($checks.Count) check(s) passed." -ForegroundColor Red
    exit 1
}
Write-Host "All $($checks.Count) checks passed." -ForegroundColor Green
exit 0
