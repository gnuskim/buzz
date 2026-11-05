# Buzz 팀 캘린더 미리보기 (0.5.28-team.11.1)

공식 Team Release 전에 patch 103(스프린트 보드 · 팀원 일정 · 배포)을 먼저 쓰기 위한 빌드입니다.
`.github/workflows/team-cal-preview.yml`이 공식 `desktop-v0.5.28` + `team-patches/*.patch`로 빌드해서
이 저장소의 `team-cal-preview` 릴리스에 올립니다.

- macOS (M 칩 · 인텔 자동 선택): `curl -fsSL https://github.com/gnuskim/buzz/releases/download/team-cal-preview/install.sh | bash`
- Windows: `powershell -ExecutionPolicy Bypass -Command "iex ([Text.Encoding]::UTF8.GetString((iwr https://github.com/gnuskim/buzz/releases/download/team-cal-preview/install.ps1 -UseBasicParsing).Content))"`

macOS 앱은 팀 업데이트 주소(EugeneBot01/buzz `team-latest`)를 그대로 써서, 이보다 새 공식 팀 빌드가 나오면 자동으로 넘어갑니다.
Windows는 팀 업데이트 피드가 없어 자동 업데이트되지 않습니다(새 빌드가 나오면 같은 명령을 다시 실행).
