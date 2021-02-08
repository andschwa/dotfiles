# Set-PsDebug -Trace 1

if (Get-Module PSReadLine) {
  Set-PSReadLineOption -EditMode Emacs
  Set-PSReadLineOption -Colors @{
    "Command"            = [ConsoleColor]::DarkBlue
    "Default"            = [ConsoleColor]::Blue
    "Member"             = [ConsoleColor]::DarkYellow
    "Number"             = [ConsoleColor]::Magenta
    "Operator"           = [ConsoleColor]::DarkGreen
    "Parameter"          = [ConsoleColor]::DarkCyan
    "Type"               = [ConsoleColor]::DarkMagenta
    "Variable"           = [ConsoleColor]::DarkGreen
    "ContinuationPrompt" = [ConsoleColor]::DarkGray
  }
}

function Update-Profile() {
  . $PROFILE.CurrentUserAllHosts
}

function Test-IsAdmin() {
  if ($IsWindows) {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $id
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  } else {
    $id = id -u
    $id -eq 0
  }
}

$isAdmin = Test-IsAdmin
$hostname = $(hostname)
try {
  Import-Module -Name posh-git -MinimumVersion 1.0.0 -ErrorAction Stop
  # Use a minimalish Git status.
  $GitPromptSettings.BeforeStatus = ""
  $GitPromptSettings.AfterStatus = ""
  $GitPromptSettings.PathStatusSeparator = ""
  $GitPromptSettings.BranchIdenticalStatusSymbol.ForegroundColor = [ConsoleColor]::DarkGreen
  $GitPromptSettings.BranchAheadStatusSymbol.ForegroundColor = [ConsoleColor]::DarkYellow
  $GitPromptSettings.BranchBehindAndAheadStatusSymbol.ForegroundColor = [ConsoleColor]::DarkMagenta
} catch {
  Write-Warning "posh-git is not installed! Try:"
  Write-Warning "Install-Module -Name posh-git -AllowPrerelease -Scope CurrentUser"
}

function prompt() {
  # Save the status before overwriting it.
  $originalLastExitCode = $global:LASTEXITCODE

  # Abbreviate home in the current path.
  # TODO: Limit the path length displayed.
  $regex = "^" + [regex]::Escape($HOME)
  $path = $executionContext.SessionState.Path.CurrentLocation.Path -replace $regex, '~'
  $path = $path.Replace('\', '/')
  $pathLength = 32
  if ($path.Length -gt $pathLength) {
    $path = "..." + $path.Substring($path.Length - $pathLength)
  }

  # Uncolored prompt string since posh-git is missing.
  if (!(Get-Command Write-Prompt)) {
    $global:LASTEXITCODE = $originalLastExitCode
    return "@$hostname $path $ "
  }

  # Otherwise build a colorized prompt string.
  $prompt = ""

  if (Test-Path variable:/PSDebugContext) {
    $prompt += Write-Prompt "[DBG] " -ForegroundColor ([ConsoleColor]::Yellow)
  }

  # Only print non-zero exit codes.
  if ($originalLastExitCode -ne 0) {
    $prompt += Write-Prompt "$originalLastExitCode " -ForegroundColor ([ConsoleColor]::Magenta)
  }

  # TODO: Use green if SSH connection.
  $prompt += Write-Prompt "@" -ForegroundColor ([ConsoleColor]::DarkBlue)
  $prompt += Write-Prompt "$hostname "
  $prompt += Write-Prompt "$path " -ForegroundColor ([ConsoleColor]::DarkBlue)
  $prompt += Write-VcsStatus
  $promptColor = if ($isAdmin) { [ConsoleColor]::Red } else { [ConsoleColor]::DarkCyan }
  $prompt += Write-Prompt "`n>" -ForegroundColor $promptColor

  $global:LASTEXITCODE = $originalLastExitCode

  # Always return a space even if Write-Prompt uses Write-Host.
  return "$prompt "
}

Set-Alias g git
Set-Alias grep Select-String
Set-Alias less more
Set-Alias zip Compress-Archive
Set-Alias unzip Expand-Archive

function e { emacsclient -n @args }
function which { (Get-Command @args).Source }
function find { rg -i -uuu -l @args }
function rg { rg.exe -i --colors 'path:bg:white' @args }
function ls {
  if ($IsWindows) {
    Get-ChildItem
  } else {
    & /bin/ls --color @args
  }
}
function ln {
  param([switch]$s, [string]$target, [string]$link)
  New-Item -ItemType SymbolicLink -Target $target -Name $link
}

function Show-Colors() {
  $colors = [Enum]::GetValues([ConsoleColor])
  $max = ($colors | ForEach-Object { "$_ ".Length } | Measure-Object -Maximum).Maximum
  foreach ($color in $colors) {
    Write-Host (" {0,2} {1,$max} " -f [int]$color, $color) -NoNewline
    Write-Host "$color" -Foreground $color
  }
}

function Edit-Path() {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateScript({ Test-Path -Path $_ -IsValid })]
    [string[]]$Path,
    [switch]$Front = $false
  )
  begin { $NewPath = $env:PATH.split([IO.Path]::PathSeparator) }
  process {
    foreach ($p in $Path) {
      if ($PSCmdlet.ShouldProcess($p)) {
        if (-not (Test-Path $p)) {
          Write-Warning "$p does not exist!"
          continue
        }
        $p = [string](Resolve-Path $p)
        $NewPath = $NewPath -ne $p
        $NewPath = if ($Front) { @($p; $NewPath) } else { @($NewPath; $p) }
      }
    }
  }
  end { $env:PATH = $NewPath -join [IO.Path]::PathSeparator }
}

$local = "$PSScriptRoot/profile_local.ps1"
(Test-Path $local) -And (. $local) > $null
