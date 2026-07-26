function Resolve-Expression {
    param(
        [Parameter(Mandatory)]
        [string] $Expression
    )
    $rePath= ""
    while ($Expression -match "^([^<>]*?)\<\<(.+?)\>\>") {
        $rePath+= [Regex]::Escape($Matches[1])
        $rePath+= "($($Matches[2]))"
        $Expression = $Expression.Substring($Matches[0].Length)
    }
    $rePath+= [Regex]::Escape($Expression)
    return $rePath
}

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

function ConverTo-FullRegexPath {
    param(
        [Parameter(Mandatory)]
        [string[]] $Tokens,
        [Parameter(Mandatory)]
        [string] $ItemPath
    )
    $currentPath = $ItemPath
    for ($i = $Tokens.Count - 1; $i -ge 0; $i--) {
        if ($Tokens[$i] -match "^(?:\\\.){1,2}$") { break }
        $currentPath = Split-Path -Path $currentPath -Parent
    }
    $rePath = ""
    if ($currentPath -ne "") { $rePath += [Regex]::Escape($currentPath) + "\\" }
    return $rePath + ($Tokens[($i + 1)..($Tokens.Count - 1)] -join "\\")
}
