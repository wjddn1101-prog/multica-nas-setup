#!/bin/bash

# Multica daemon 시작 스크립트

set -e

MULTICA_BIN="${MULTICA_BIN:./multica}"
MULTICA_HOME="${MULTICA_HOME:~/.multica}"

echo "=== Multica daemon 시작 ==="
echo ""

# Multica 바이너리 확인
if [ ! -x "$MULTICA_BIN" ]; then
  echo "오류: $MULTICA_BIN를 찾을 수 없거나 실행 불가능합니다."
  echo ""
  echo "다음 중 하나를 시도하세요:"
  echo "1. ./install-multica.sh를 실행하여 Multica를 설치합니다."
  echo "2. MULTICA_BIN 환경 변수를 설정합니다:"
  echo "   export MULTICA_BIN=/path/to/multica"
  exit 1
fi

# 로그인 확인
if [ ! -f "$MULTICA_HOME/.auth" ]; then
  echo "아직 로그인하지 않았습니다."
  echo "먼저 로그인하세요:"
  echo "  $MULTICA_BIN login"
  echo ""
  echo "또는 API 토큰을 환경 변수로 설정하세요:"
  echo "  export MULTICA_API_TOKEN=<your-token>"
  exit 1
fi

echo "Multica Home: $MULTICA_HOME"
echo ""

# daemon 옵션 설정
DAEMON_OPTS=""

# 설정 파일이 있으면 사용
if [ -f "$MULTICA_HOME/config/daemon.yaml" ]; then
  DAEMON_OPTS="--config=$MULTICA_HOME/config/daemon.yaml"
  echo "설정 파일: $MULTICA_HOME/config/daemon.yaml"
fi

# 로그 파일 설정
LOG_DIR="$MULTICA_HOME/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/daemon.log"

echo "로그 파일: $LOG_FILE"
echo ""

# daemon 시작
echo "daemon을 시작합니다..."
echo "Ctrl+C를 눌러서 종료할 수 있습니다."
echo ""

"$MULTICA_BIN" daemon start $DAEMON_OPTS

echo ""
echo "daemon이 종료되었습니다."
