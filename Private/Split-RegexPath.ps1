function Split-RegexPath {
    param(
        [Parameter(Mandatory)]
        [string] $RegexPath
    )
    $separator = "(?:\/|\\\\)"
    $validName = "[^\\/:*?<>|]+?"
    $drive = "(?:" + (((Get-PSDrive -PSProvider FileSystem) | ForEach-Object { $_.Name }) -join "|") + "):"

    if ($RegexPath -match "^(.+)$separator$") { $RegexPath = $Matches[1] }

    # UNC Path
    if ($RegexPath -match "^($separator{2}$validName$separator$validName)$separator(.+)$") {
        $tokens = @()
        $tokens += $Matches[1]
        $tokens += $Matches[2] -split $separator
        return $tokens
    }

    # DOS Absolute Path
    if ($RegexPath -match "^$separator(?!\/|\\\\)$validName.+$") {
        $currentDrive = (Get-Location).Drive.Name
        $RegexPath = $currentDrive + ":" + $RegexPath
    }
    if ($RegexPath -match "^($drive)$separator(.+)$") {
        $tokens = @()
        $tokens += $Matches[1]
        $tokens += $Matches[2] -split $separator
        return $tokens
    }

    # Relative Path
    $tokens = @()
    $tokens += [Regex]::Escape((Get-Location).Path)
    $tokens += $RegexPath -split $separator
    return $tokens
}