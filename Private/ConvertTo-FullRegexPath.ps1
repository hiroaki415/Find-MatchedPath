function ConvertTo-FullRegexPath {
    param(
        [Parameter(Mandatory)]
        [string[]] $Tokens,
        [Parameter(Mandatory)]
        [string] $ItemPath
    )
    $currentPath = $ItemPath
    for ($i = $Tokens.Count - 1; $i -gt 0; $i--) {
        if ($Tokens[$i] -match "^(?:\\\.){1,2}$") { break }
        $currentPath = Split-Path -Path $currentPath -Parent
    }
    $rePath = ""
    if ($currentPath -ne "") {
        $rePath += [Regex]::Escape($currentPath)
        if (-not ($rePath -match "\\\\$")) { $rePath += "\\" }
    }
    return $rePath + ($Tokens[($i + 1)..($Tokens.Count - 1)] -join "\\")
}