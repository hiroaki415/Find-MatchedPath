Describe "Find-MatchedPath" {
    BeforeAll {
        # . $PSScriptRoot\..\Public\Find-MatchedPath.ps1
        $script:root = $PSScriptRoot
    }
    Context "Test absolute path" {
        It "Get objects matched with expression" {
            $exp = "$PSScriptRoot\TestFiles\Dir<<[123]>>\Folder{<<[ABC]>>}\@20<<(?:24|25|26)>>\File-[<<[01]{4}>>](#<<\d{4}>>).txt"
            $result = Find-MatchedPath -Expression $exp
            $result | Should -HaveCount 81
            $result[80].psobject.properties | Should -HaveCount 6
            $result[70]."4" | Should -Match "[01]{4}"
        }
    }
    Context "Test relative path" {
        It "Get objects matched with expression" {
            Set-Location "$root\TestFiles\Dir2\Folder{C}\"
            $exp = "..\..\Dir<<[123]>>\Folder{<<[ABC]>>}\@20<<(?:24|25|26)>>\File-[<<[01]{4}>>](#<<\d{4}>>).txt"
            $result = Find-MatchedPath -Expression $exp
            $result | Should -HaveCount 81
            $result[80].psobject.properties | Should -HaveCount 6
            $result[70]."4" | Should -Match "[01]{4}"
        }
    }
}
