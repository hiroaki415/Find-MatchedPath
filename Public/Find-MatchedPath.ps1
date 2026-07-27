function Find-MatchedPath {
    <#
    .SYNOPSIS
      Search files and directories using path expressions that include embedded regular expressions.
    .DESCRIPTION
      Search files and directories using path expressions that include embedded regular expressions.
    .PARAMETER Expresion
      Path expression that includes regular expression.
      Regular expression must be surrounded them by << >>.
    .EXAMPLE
      PS> Find-MatchedPath -Expression C:\directory\to\seek\foler<<[ABC]>>\file<<06\d{2}>>.jpg
    .EXAMPLE
      PS> Find-MatchedPath -Expression file<<06\d{2}>>.jpg
    .EXAMPLE
      PS> Find-MatchedPath -Expression ..\..\foler<<[ABC]>>\file<<06\d{2}>>.jpg
    .EXAMPLE
      PS> Find-MatchedPath -Expression \\host\shared\directory\foler<<[ABC]>>\file<<06\d{2}>>.jpg
    .OUTPUTS
      System.Array of PSCustomObject.
      Each object contains the following properties:
        - Path : FullName of file or directory matched with Expression
        - <capture goups> : String captured by regular expression (1, 2, 3,..)
    .LINK
      https://github.com/hiroaki415/Find-MatchedPath/tree/main
    .NOTES
      Author: hiroaki415
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$Expression
    )
    $repath = Resolve-Expression -Expression $Expression
    $tokens = Split-RegexPath -RegexPath $repath

    $currentItems = @(Get-ChildItem -LiteralPath  ([Regex]::Unescape($tokens[0]) + "\") -ErrorAction SilentlyContinue)
    $i = 1
    for (; $i -lt ($tokens.Count - 1); $i++) {
        $pattern = "^$($tokens[$i])$"
        $nextItems = @()
        foreach ($item in $currentItems) {
            if ($tokens[$i] -eq "\.") {
                $nextItems += $item
            }
            elseif ($tokens[$i] -eq "\.\.") {
                $parentPath = Split-Path -Path $item.PSParentPath -Parent
                $children = @(Get-ChildItem -LiteralPath $parentPath -ErrorAction SilentlyContinue)
                # $nextItems = @(($nextItems + $children) | Select-Object -Unique)
                $nextItems = @(($nextItems + $children) | Group-Object FullName | ForEach-Object { $_.Group[0] })
            }
            elseif ($item.PSIsContainer -and $item.Name -match $pattern) {
                $children = @(Get-ChildItem -LiteralPath $item.FullName -ErrorAction SilentlyContinue)
                # $nextItems = @(($nextItems + $children) | Select-Object -Unique)
                $nextItems = @(($nextItems + $children) | Group-Object FullName | ForEach-Object { $_.Group[0] })
            }
        }
        if ($nextItems.Count -le 0) { return , @() }
        $currentItems = $nextItems
    }

    $matchedPaths = @()
    foreach ($item in $currentItems) {
        $fullPattern = ConvertTo-FullRegexPath -Tokens $tokens -ItemPath $item.FullName
        if ($item.FullName -match "^$fullPattern$") {
            $obj = [PSCustomObject]@{ Path = $item.FullName }
            for ($j = 1; $Matches.ContainsKey($j); $j++) {
                $obj | Add-Member -MemberType NoteProperty -Name $j -Value $Matches[$j]
            }
            $matchedPaths += $obj
        }
    }

    return , $matchedPaths
}
