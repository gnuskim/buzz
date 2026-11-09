#!/bin/bash
# Buzz 공식 팀 빌드 설치 (macOS, Apple Silicon / Intel 자동 선택)
# 미리보기 빌드(team.11.1)에는 업데이트 기능이 빠져 있어서, 공식 team.12로 한 번 옮깁니다.
# 그 뒤로는 앱의 업데이트 배너로 새 버전을 받습니다.
# 사용: curl -fsSL https://github.com/gnuskim/buzz/releases/download/team-cal-preview/install.sh | bash
set -euo pipefail

VERSION="0.5.28-team.12"
BASE="https://github.com/EugeneBot01/buzz/releases/download/team-v$VERSION"
APP="/Applications/Buzz.app"
BUNDLE_ID="xyz.block.buzz.app"

say() { printf '\033[1m▶ %s\033[0m\n' "$*"; }
fail() { printf '\033[31m✖ %s\033[0m\n' "$*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || fail "macOS에서만 쓰는 스크립트입니다. Windows는 install.ps1을 쓰세요."

# 이미 이 버전이거나 더 새 버전이면 건드리지 않는다.
if [[ -f "$APP/Contents/Info.plist" ]]; then
  CURRENT="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Contents/Info.plist" 2>/dev/null || true)"
  if [[ -n "$CURRENT" && "$(printf '%s\n%s\n' "$CURRENT" "$VERSION" | sort -V | tail -1)" == "$CURRENT" ]]; then
    say "이미 Buzz $CURRENT 을 쓰고 있어요. 설치할 필요가 없습니다."
    exit 0
  fi
fi

# 터미널이 Rosetta로 열려 있어도 M 칩이면 arm64를 고른다.
if [[ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" == "1" ]]; then
  FILE="Buzz_${VERSION}_aarch64.app.tar.gz"; KIND="Apple Silicon (M 칩)"
  EXPECTED="919f41ca72b32956017b9731cc4e26b7ca3d1f93577e4a2728679f6c38b20ce2"
else
  FILE="Buzz_${VERSION}_x64.app.tar.gz"; KIND="Intel"
  EXPECTED="f0f1218a57518a6a2947b2ced9c5753cea32f2d2cd83d8f360a6c48fda126b0a"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

say "$KIND 용 Buzz $VERSION 을 받는 중…"
curl -fL --progress-bar "$BASE/$FILE" -o "$TMP/$FILE" || fail "다운로드에 실패했어요. 인터넷 연결을 확인해 주세요."
ACTUAL="$(shasum -a 256 "$TMP/$FILE" | awk '{print $1}')"
[[ "$EXPECTED" == "$ACTUAL" ]] || fail "받은 파일이 손상됐어요. 다시 시도해 주세요."

mkdir -p "$TMP/x"
tar -xzf "$TMP/$FILE" -C "$TMP/x"
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

INSTALLED="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Contents/Info.plist")"
open -a "$APP"
say "완료! Buzz $INSTALLED 이 실행됐어요. 다음 버전부터는 앱의 업데이트 배너로 받을 수 있어요."
