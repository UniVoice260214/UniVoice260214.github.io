# 홈페이지 미리보기 캡처:  .\tools\preview.ps1            (데스크톱 1440px)
#                          .\tools\preview.ps1 -Width 390  (모바일)
# 결과는 tools\_preview 폴더에 조각 PNG 로 저장된다 (저장소에는 올리지 않는다).
param([int]$Width = 1440, [int]$Height = 13000, [int]$Chunk = 2600)
$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$root = Split-Path $PSScriptRoot -Parent
$out = Join-Path $PSScriptRoot "_preview"
New-Item -ItemType Directory -Force $out | Out-Null
$site = "file:///" + $root.Replace('\', '/') + "/index.html"
$wrap = Join-Path $out "_wrap.html"
"<!doctype html><meta charset='utf-8'><style>html,body{margin:0;background:#fff}iframe{border:0;display:block}</style><iframe src='$site' width='$Width' height='$Height'></iframe>" | Out-File $wrap -Encoding utf8
$raw = Join-Path $out "_raw.png"
$winW = [Math]::Max($Width, 600)
Start-Process -FilePath $chrome -ArgumentList @("--headless=new","--disable-gpu","--hide-scrollbars","--allow-file-access-from-files","--window-size=$winW,$Height","--force-device-scale-factor=1","--virtual-time-budget=12000","--screenshot=`"$raw`"","`"file:///$($wrap.Replace('\','/'))`"") -Wait -WindowStyle Hidden
Add-Type -AssemblyName System.Drawing
$src = New-Object System.Drawing.Bitmap $raw
# 아래쪽 빈 여백(흰색) 찾기
$bottom = $src.Height - 1
while ($bottom -gt 0) { $c = $src.GetPixel([int]($Width / 2), $bottom); if ($c.R -lt 250 -or $c.G -lt 250 -or $c.B -lt 250) { break }; $bottom -= 4 }
$total = [Math]::Min($src.Height, $bottom + 8)
$n = 0
for ($y = 0; $y -lt $total; $y += $Chunk) {
  $h = [Math]::Min($Chunk, $total - $y)
  $part = $src.Clone((New-Object System.Drawing.Rectangle 0, $y, $Width, $h), $src.PixelFormat)
  $part.Save((Join-Path $out ("w{0}_{1:00}.png" -f $Width, $n))); $part.Dispose(); $n++
}
$src.Dispose(); Remove-Item $raw, $wrap -Force
"page height: $total px, parts: $n  ->  $out"
