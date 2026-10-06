# 홈페이지 미리보기 캡처:  .\tools\preview.ps1                 (데스크톱 1440px)
#                          .\tools\preview.ps1 -Width 390      (모바일)
#                          .\tools\preview.ps1 -States         (탭·상자를 눌러 둔 상태까지 함께)
# 결과는 tools\_preview 폴더에 조각 PNG 로 저장된다 (저장소에는 올리지 않는다).
param([int]$Width = 1440, [int]$Height = 11000, [int]$Chunk = 2600, [switch]$States)
$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$root = Split-Path $PSScriptRoot -Parent
$out = Join-Path $PSScriptRoot "_preview"
New-Item -ItemType Directory -Force $out | Out-Null
Add-Type -AssemblyName System.Drawing

function Capture([string]$pageUrl, [string]$tag) {
  $wrap = Join-Path $out "_wrap.html"
  "<!doctype html><meta charset='utf-8'><style>html,body{margin:0;background:#fff}iframe{border:0;display:block}</style><iframe src='$pageUrl' width='$Width' height='$Height'></iframe>" | Out-File $wrap -Encoding utf8
  $raw = Join-Path $out "_raw.png"
  $winW = [Math]::Max($Width, 600)
  Start-Process -FilePath $chrome -ArgumentList @("--headless=new","--disable-gpu","--hide-scrollbars","--allow-file-access-from-files","--window-size=$winW,$Height","--force-device-scale-factor=1","--virtual-time-budget=12000","--screenshot=`"$raw`"","`"file:///$($wrap.Replace('\','/'))`"") -Wait -WindowStyle Hidden
  $src = New-Object System.Drawing.Bitmap $raw
  $bottom = $src.Height - 1   # 아래쪽 빈 여백(흰색)을 잘라낸다
  while ($bottom -gt 0) { $c = $src.GetPixel([int]($Width / 2), $bottom); if ($c.R -lt 250 -or $c.G -lt 250 -or $c.B -lt 250) { break }; $bottom -= 4 }
  $total = [Math]::Min($src.Height, $bottom + 8)
  $n = 0
  for ($y = 0; $y -lt $total; $y += $Chunk) {
    $h = [Math]::Min($Chunk, $total - $y)
    $part = $src.Clone((New-Object System.Drawing.Rectangle 0, $y, $Width, $h), $src.PixelFormat)
    $part.Save((Join-Path $out ("w{0}{1}_{2:00}.png" -f $Width, $tag, $n))); $part.Dispose(); $n++
  }
  $src.Dispose(); Remove-Item $raw, $wrap -Force
  "{0,-8} page height: {1} px, parts: {2}" -f ($(if ($tag) { $tag } else { "default" })), $total, $n
}

$base = "file:///" + $root.Replace('\', '/')
Capture "$base/index.html" ""

if ($States) {
  # 상호작용 확인용 사본: 지정한 버튼을 눌러 둔 채로 그린다.
  $html = [IO.File]::ReadAllText((Join-Path $root "index.html"), [Text.Encoding]::UTF8)
  $sets = @{
    "B" = @("#why-t2", "#scr-t3", "#pf-t2", "[data-switch] [data-value=normalization]", ".principles .pick:nth-child(2)", ".roadmap .pick:nth-child(3)")
    "C" = @("#scr-t4", "#pf-t3")
  }
  foreach ($k in $sets.Keys | Sort-Object) {
    $list = ($sets[$k] | ForEach-Object { "'" + $_ + "'" }) -join ","
    $script = "<script>window.addEventListener('load',()=>{[$list].forEach(s=>{const e=document.querySelector(s);if(e)e.click();});});</script>"
    $page = $html.Replace("<head>", "<head><base href='../../'>").Replace("</body>", "$script</body>")
    $file = Join-Path $out "_state$k.html"
    [IO.File]::WriteAllText($file, $page, (New-Object Text.UTF8Encoding $false))
    Capture ("$base/tools/_preview/_state$k.html") $k
    Remove-Item $file -Force
  }
}
"-> $out"
