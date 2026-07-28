# Find-MatchedPath
A PowerShell module that provides a command for searching files and directories using path expressions that include embedded regular expressions.

You can embed regular expressions into folder and file names using the custom DSL `<<regex>>`, enabling flexible hierarchical searches.


## Usage
```powershell
Find-MatchedPath -Expression "C:\directory\to\search\folder<<[ABC]>>\file<<06\d{2}>>.jpg"
```

## Example：
Below is a sample directory structure used for testing.
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
As a starting point, try to get all files matching `.\Dir*\Folder{*}\@202*\File-[*](#*).txt`.
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

You can also use relative path expressions.
```powershell
Find-MatchedPath -Expression "Dir<<[123]>>\Folder{<<[ABC]>>}\@20<<(?:24|25|26)>>\File-[<<[01]{4}>>](#<<\d{4}>>).txt"
```
Or
```powershell
Find-MatchedPath -Expression ".\Dir<<[123]>>\Folder{<<[ABC]>>}\@20<<(?:24|25|26)>>\File-[<<[01]{4}>>](#<<\d{4}>>).txt"
```
If your location is `$PSScriptRoot\Tests\TestFiles\Dir3\Folder{B}`, the following command returns the same results.
```powershell
Find-MatchedPath -Expression "..\..\Dir<<[123]>>\Folder{<<[ABC]>>}\@20<<(?:24|25|26)>>\File-[<<[01]{4}>>](#<<\d{4}>>).txt"
```

For example, if you want to search for files that contain `[*1*1]` only under `Folder{A}` or `Folder{B}`, you can use:
```powershell
Find-MatchedPath -Expression ".\Dir<<[123]>>\Folder{<<[AB]>>}\@20<<(?:24|25|26)>>\File-[<<[01]1[01]1>>](#<<\d{4}>>).txt"
```
```
Path                                                                      1 2 3  4    5
----                                                                      - - -  -    -
$PSScriptRoot\Tests\TestFiles\Dir1\Folder{A}\@2025\File-[0111](#1225).txt 1 A 25 0111 1225
$PSScriptRoot\Tests\TestFiles\Dir1\Folder{B}\@2026\File-[0101](#0210).txt 1 B 26 0101 0210
$PSScriptRoot\Tests\TestFiles\Dir1\Folder{B}\@2026\File-[0101](#0617).txt 1 B 26 0101 0617
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{A}\@2025\File-[0111](#0809).txt 2 A 25 0111 0809
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{A}\@2025\File-[1111](#0312).txt 2 A 25 1111 0312
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{A}\@2026\File-[0101](#1201).txt 2 A 26 0101 1201
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{B}\@2025\File-[1101](#0411).txt 2 B 25 1101 0411
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{B}\@2025\File-[1101](#0612).txt 2 B 25 1101 0612
$PSScriptRoot\Tests\TestFiles\Dir3\Folder{A}\@2024\File-[0101](#1013).txt 3 A 24 0101 1013
$PSScriptRoot\Tests\TestFiles\Dir3\Folder{A}\@2026\File-[1111](#0930).txt 3 A 26 1111 0930
$PSScriptRoot\Tests\TestFiles\Dir3\Folder{B}\@2025\File-[1101](#0430).txt 3 B 25 1101 0430
$PSScriptRoot\Tests\TestFiles\Dir3\Folder{B}\@2026\File-[1101](#0716).txt 3 B 26 1101 0716
```

## Output
Find-MatchedPath Cmdlet returns `System.Array` of `PSCustomObject`.

Each object contains the following properties:

- Path : FullName of file or directory matched with Expression
- \<capture groups\> : String captured by regular expression (1, 2, 3,..)

## Other Specification
- `<<regex>>` segments are automatically captured by the command. If you want to define capture groups manually, you need to pay attention to the order of capture.
```powershell
Find-MatchedPath -Expression ".\Dir2\Folder{C}\@2024\File-[<<[01]{4}>>](#<<(\d{2})(\d{2})>>).txt"
```
```
Path                                                                      1    2    3  4
----                                                                      -    -    -  -
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{C}\@2024\File-[0101](#1212).txt 0101 1212 12 12
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{C}\@2024\File-[0111](#0713).txt 0111 0713 07 13
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{C}\@2024\File-[1101](#0522).txt 1101 0522 05 22
```

- `<<regex>>` capturing is available only after last `.\` or `..\`.
```powershell
Find-MatchedPath -Expression "..\Test<<.>>iles\..\<<.>>estFiles\Dir2\Folder{C}\@2024\File-[<<[01]{4}>>](#<<\d{4}>>).txt"
# (Note: Although this pattern is supported, its practical use cases may be limited.)
```
```
Path                                                                      1 2    3
----                                                                      - -    -
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{C}\@2024\File-[0101](#1212).txt T 0101 1212
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{C}\@2024\File-[0111](#0713).txt T 0111 0713
$PSScriptRoot\Tests\TestFiles\Dir2\Folder{C}\@2024\File-[1101](#0522).txt T 1101 0522
```


## Limitations
- `<<regex>>` cannot be used in drive letter.
```powershell
Find-MatchedPath -Expression "<<[CDE]>>:\directory\folder2\folderC\file0621.jpg"
# matched nothing
```
- `<<regex>>` cannot be used in hostname and shared foleder (in case of UNC).
```powershell
Find-MatchedPath -Expression "\\host<<[123]>>\shared<<[ABC]>>\folder2\folderC\file0621.jpg"
# matched nothing
```
- `<<regex>>` cannot span across path separators.
```powershell
Find-MatchedPath -Expression "C:\directory\<<folder[123]\\folder[ABC]>>\file0621.jpg"
# "C:\directory\folder2\folderC\file0621.jpg" will not match with Expression above.
```

## License
MIT License

PowerShell / Search / Path / Regex / RegExp / Regular Expression