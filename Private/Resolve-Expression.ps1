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
