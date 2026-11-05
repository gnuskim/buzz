# Buzz 팀 캘린더 미리보기 설치 (Windows)
# 사용: PowerShell에서
#   powershell -ExecutionPolicy Bypass -Command "iex ([Text.Encoding]::UTF8.GetString((iwr https://github.com/gnuskim/buzz/releases/download/team-cal-preview/install.ps1 -UseBasicParsing).Content))"
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$base = 'https://github.com/gnuskim/buzz/releases/download/team-cal-preview'
$file = 'Buzz-windows-x64-setup.exe'
$tmp = Join-Path $env:TEMP ('buzz-preview-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null

try {
  Write-Host '▶ Buzz 설치 파일을 받는 중…' -ForegroundColor Cyan
  $exe = Join-Path $tmp $file
  Invoke-WebRequest "$base/$file" -OutFile $exe -UseBasicParsing
  $sums = (Invoke-WebRequest "$base/SHA256SUMS.txt" -UseBasicParsing).Content
  $line = ($sums -split "`n") | Where-Object { $_ -match [regex]::Escape($file) + '\s*$' } | Select-Object -First 1
  if (-not $line) { throw '체크섬 파일에서 설치 파일을 찾지 못했어요.' }
  $expected = ($line -split '\s+')[0].ToLower()
  $actual = (Get-FileHash $exe -Algorithm SHA256).Hash.ToLower()
  if ($expected -ne $actual) { throw '받은 파일이 손상됐어요. 다시 시도해 주세요.' }

  $running = Get-Process -Name 'buzz-desktop' -ErrorAction SilentlyContinue
  if ($running) {
    Write-Host '▶ Buzz를 잠시 종료합니다…' -ForegroundColor Cyan
    $running | ForEach-Object { $_.CloseMainWindow() | Out-Null }
    Start-Sleep -Seconds 5
    Get-Process -Name 'buzz-desktop' -ErrorAction SilentlyContinue | Stop-Process -Force
  }

  Write-Host '▶ 설치하는 중… (잠시 기다려 주세요)' -ForegroundColor Cyan
  $p = Start-Process -FilePath $exe -ArgumentList '/S' -Wait -PassThru
  if ($p.ExitCode -ne 0) { throw "설치 프로그램이 오류로 끝났어요 (코드 $($p.ExitCode))." }

  $candidates = @(
    (Join-Path $env:LOCALAPPDATA 'Buzz\buzz-desktop.exe'),
    (Join-Path $env:ProgramFiles 'Buzz\buzz-desktop.exe')
  )
  $app = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
  if ($app) {
    Start-Process $app
    Write-Host '✔ 완료! Buzz가 실행됐어요. 캘린더 → 스프린트/달력을 확인해 보세요.' -ForegroundColor Green
  } else {
    Write-Host '✔ 설치는 끝났어요. 시작 메뉴에서 Buzz를 실행해 주세요.' -ForegroundColor Green
  }
} catch {
  Write-Host ('✖ ' + $_.Exception.Message) -ForegroundColor Red
  exit 1
} finally {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
