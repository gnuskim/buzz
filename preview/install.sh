#!/bin/bash
# Buzz 팀 캘린더 미리보기 설치 (macOS, Apple Silicon / Intel 자동 선택)
# 사용: curl -fsSL https://github.com/gnuskim/buzz/releases/download/team-cal-preview/install.sh | bash
set -euo pipefail

BASE="https://github.com/gnuskim/buzz/releases/download/team-cal-preview"
APP="/Applications/Buzz.app"
BUNDLE_ID="xyz.block.buzz.app"

say() { printf '\033[1m▶ %s\033[0m\n' "$*"; }
fail() { printf '\033[31m✖ %s\033[0m\n' "$*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || fail "macOS에서만 쓰는 스크립트입니다. Windows는 install.ps1을 쓰세요."

# 터미널이 Rosetta로 열려 있어도 M 칩이면 arm64를 고른다.
if [[ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" == "1" ]]; then
  FILE="Buzz-macos-arm64.zip"; KIND="Apple Silicon (M 칩)"
else
  FILE="Buzz-macos-x64.zip"; KIND="Intel"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

say "$KIND 용 Buzz를 받는 중…"
curl -fL --progress-bar "$BASE/$FILE" -o "$TMP/$FILE" || fail "다운로드에 실패했어요. 인터넷 연결을 확인해 주세요."
curl -fsSL "$BASE/SHA256SUMS.txt" -o "$TMP/SHA256SUMS.txt" || fail "체크섬 파일을 받지 못했어요."
EXPECTED="$(grep " $FILE\$" "$TMP/SHA256SUMS.txt" | awk '{print $1}')"
ACTUAL="$(shasum -a 256 "$TMP/$FILE" | awk '{print $1}')"
[[ -n "$EXPECTED" && "$EXPECTED" == "$ACTUAL" ]] || fail "받은 파일이 손상됐어요. 다시 시도해 주세요."

ditto -x -k "$TMP/$FILE" "$TMP/x"
[[ -d "$TMP/x/Buzz.app" ]] || fail "압축 파일에 Buzz.app이 없어요."

if pgrep -f "$APP/Contents/MacOS/buzz-desktop" >/dev/null 2>&1; then
  say "Buzz를 잠시 종료합니다…"
  osascript -e "tell application id \"$BUNDLE_ID\" to quit" >/dev/null 2>&1 || true
  for _ in $(seq 1 30); do
    pgrep -f "$APP/Contents/MacOS/buzz-desktop" >/dev/null 2>&1 || break
    sleep 1
  done
  pgrep -f "$APP/Contents/MacOS/buzz-desktop" >/dev/null 2>&1 && fail "Buzz가 종료되지 않았어요. Buzz를 직접 끈 뒤 다시 실행해 주세요."
fi

SUDO=""
if [[ -e "$APP" && ! -w "$APP" ]] || [[ ! -w "/Applications" ]]; then
  say "관리자 암호가 필요해요 (응용 프로그램 폴더에 쓰기 위해)."
  SUDO="sudo"
fi

if [[ -d "$APP" ]]; then
  BACKUP="$HOME/.Trash/Buzz-이전버전-$(date +%Y%m%d-%H%M%S).app"
  say "이전 Buzz는 휴지통으로 옮겨 둡니다 (되돌리려면 휴지통에서 꺼내면 돼요)."
  $SUDO mv "$APP" "$BACKUP"
fi

say "새 Buzz를 설치하는 중…"
$SUDO ditto "$TMP/x/Buzz.app" "$APP"
$SUDO xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Contents/Info.plist")"
open -a "$APP"
say "완료! Buzz $VERSION 이 실행됐어요. 캘린더 → 스프린트/달력을 확인해 보세요."
