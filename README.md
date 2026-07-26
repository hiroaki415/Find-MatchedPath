# Find-MatchedPath
---
PowerShell module which provides a command to search file or directory matched with specified path including regular expression.

You can embed regular expressions into folder and file names using a proprietary DSL `<<regex>>` to perform hierarchical searches.


## Usage
---
```powershell
Find-MatchedPath -Expression "C:\directory\to\seek\foler<<[ABC]>>\file<<06\d{2}>>.jpg"
```

## Example：
---
Here is sample directory structure for test.
```
$PSScriptRoot\Tests\TestFiles (current directory)
├── Dir1
└── Dir2
└── Dir3
    └── Folder{A}
    └── Folder{B}
    └── Folder{C}
        └── @2024
        └── @2025
        └── @2026
            └── File-[0001](#0809).txt
            └── File-[0011](#0408).txt
            └── File-[0111](#0516).txt
```
First of all, get all `.\Dir\*\Folder{\*}\@202\*\File-\[\*\](#\*).txt`.
```powershell
Find-MatchedPath -Expression "$PSScriptRoot\TestFiles\Dir<<[123]>>\Folder{<<[ABC]>>}\@20<<(?:24|25|26)>>\File-[<<[01]{4}>>](#<<\d{4}>>).txt"
```
```
Path                                                                      1 2 3  4    5
----                                                                      - - -  -    -
$PSScriptRoot\Tests\TestFiles\Dir1\Folder{A}\@2024\File-[0000](#0301).txt 1 A 24 0000 0301
$PSScriptRoot\Tests\TestFiles\Dir1\Folder{A}\@2024\File-[0100](#1016).txt 1 A 24 0100 1016
$PSScriptRoot\Tests\TestFiles\Dir1\Folder{A}\@2024\File-[1100](#0127).txt 1 A 24 1100 0127
$PSScriptRoot\Tests\TestFiles\Dir1\Folder{A}\@2025\File-[0011](#0510).txt 1 A 25 0011 0510
$PSScriptRoot\Tests\TestFiles\Dir1\Folder{A}\@2025\File-[0110](#0227).txt 1 A 25 0110 0227
...
```

Of course, you can use relative path expression instead.
```powershell
Find-MatchedPath -Expression "TestFiles\Dir<<[123]>>\Folder{<<[ABC]>>}\@20<<(?:24|25|26)>>\File-[<<[01]{4}>>](#<<\d{4}>>).txt"
```
Or
```powershell
Find-MatchedPath -Expression ".\TestFiles\Dir<<[123]>>\Folder{<<[ABC]>>}\@20<<(?:24|25|26)>>\File-[<<[01]{4}>>](#<<\d{4}>>).txt"
```
If your location is `$PSScriptRoot\Tests\TestFiles\Dir3\` now, command below returns same result.
```powershell
Find-MatchedPath -Expression "..\..\TestFiles\Dir<<[123]>>\Folder{<<[ABC]>>}\@20<<(?:24|25|26)>>\File-[<<[01]{4}>>](#<<\d{4}>>).txt"
```

## Output
---
Find-MatchedPath Cmdlet returns System.Array of PSCustomObject.

Each object has properties below:

- Path : FullName of file or directory matched with Expression
- \<capture goups\> : String captured by regular expression (1, 2, 3,..)


## License
---
MIT License


## Author
---
hiroaki415

PowerShell / Search / Path / Regex / RegExp / Regular Expression /
