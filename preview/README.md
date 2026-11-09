# Buzz 팀 빌드 설치 (Windows 0.5.28-team.13)

- macOS (M 칩 · 인텔 자동 선택): `curl -fsSL https://github.com/gnuskim/buzz/releases/download/team-cal-preview/install.sh | bash`
  공식 팀 빌드(EugeneBot01/buzz)를 설치합니다. 이후 새 버전은 앱의 업데이트 배너로 받습니다.
- Windows: `powershell -ExecutionPolicy Bypass -Command "iex ([Text.Encoding]::UTF8.GetString((iwr https://github.com/gnuskim/buzz/releases/download/team-cal-preview/install.ps1 -UseBasicParsing).Content))"`
  팀 업데이트에 Windows용이 없어 자동 업데이트되지 않습니다. 새 빌드가 나오면 같은 명령을 다시 실행합니다.

Windows 설치 파일은 `.github/workflows/team-cal-preview.yml`이 공식 `desktop-v0.5.28` + `team-patches/*.patch`로 빌드합니다.
