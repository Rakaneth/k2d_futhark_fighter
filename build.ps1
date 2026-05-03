Param(
    [string]$Task
)

$dbg = "./out/Debug"
$rls = "./out/Release"
$exe = "futhark_fighter.exe"
$renderer = "-define:KARL2D_RENDER_BACKEND=gl"
$size = "-o:size"

@($dbg, $rls) | ForEach-Object { 
    if (-not (Test-Path $_)) {
        mkdir $_
    }
}

switch ($Task.ToLower()) {
    "debug" { odin build src -debug -out:$dbg/$exe $renderer }
    "release" { odin build src -out:$rls/$exe $renderer }
    "web" { odin run vendor/karl2d/build_web -- src $size }
    "clean" { 
        Remove-Item out -Recurse -Force 
        foreach ($webFld in @("bin", "build")) {
            if (Test-Path src/$webFld) {
                Remove-Item src/$webFld -Recurse -Force
            }
        }
    }
    default { Write-Host "Usage: ./build.ps1 (debug|release|web|clean)" }
}
