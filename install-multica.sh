#!/bin/bash

# Multica Cloud daemon 설치 스크립트
# NAS 환경에서 Multica를 설치하고 초기 설정

set -e

echo "=== Multica Cloud 설치 시작 ==="

# 시스템 정보 확인
ARCH=$(uname -m)
OS=$(uname -s)

echo "시스템 정보:"
echo "OS: $OS"
echo "아키텍처: $ARCH"

# 아키텍처 맞게 변환
case "$ARCH" in
  x86_64)
    ARCH="amd64"
    ;;
  aarch64)
    ARCH="arm64"
    ;;
esac

INSTALL_DIR="${INSTALL_DIR:-.}"
MULTICA_HOME="${MULTICA_HOME:~/.multica}"

echo "설치 디렉토리: $INSTALL_DIR"
echo "Multica Home: $MULTICA_HOME"

# Multica 홈 디렉토리 생성
mkdir -p "$MULTICA_HOME"

# 최신 버전 확인
echo ""
echo "최신 버전 확인 중..."

# GitHub API에서 최신 릴리스 정보 조회
LATEST_VERSION=$(curl -s https://api.github.com/repos/multicastcloud/multica/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": "v\(.*\)".*/\1/' | head -n1)

if [ -z "$LATEST_VERSION" ]; then
  echo "경고: 최신 버전을 확인할 수 없습니다."
  LATEST_VERSION="latest"
fi

echo "설치 버전: $LATEST_VERSION"

# 바이너리 다운로드
echo ""
echo "Multica 바이너리 다운로드 중..."

DOWNLOAD_URL="https://github.com/multicastcloud/multica/releases/download/v${LATEST_VERSION}/multica-${OS,,}-${ARCH}"

if ! curl -fL "$DOWNLOAD_URL" -o "$INSTALL_DIR/multica"; then
  echo "다운로드 실패: $DOWNLOAD_URL"
  echo "수동 설치를 시도합니다..."

  # 대체 다운로드 URL 시도
  DOWNLOAD_URL="https://github.com/multicastcloud/multica/releases/download/v${LATEST_VERSION}/multica"
  if ! curl -fL "$DOWNLOAD_URL" -o "$INSTALL_DIR/multica"; then
    echo "오류: Multica 바이너리를 다운로드할 수 없습니다."
    echo "수동으로 설치하세요: https://github.com/multicastcloud/multica/releases"
    exit 1
  fi
fi

# 실행 권한 부여
chmod +x "$INSTALL_DIR/multica"

# 전역 경로에 링크 생성 (선택사항)
if [ -w /usr/local/bin ]; then
  ln -sf "$(pwd)/multica" /usr/local/bin/multica
  echo "✓ /usr/local/bin/multica 링크 생성"
fi

# 버전 확인
echo ""
echo "설치 확인:"
"$INSTALL_DIR/multica" --version || echo "경고: 버전 확인 실패"

# 설정 파일 템플릿 생성
echo ""
echo "설정 파일 생성..."

mkdir -p "$MULTICA_HOME/config"

# daemon 설정 파일
cat > "$MULTICA_HOME/config/daemon.yaml" << 'EOF'
# Multica daemon 설정
# 이 파일을 편집한 후 daemon을 시작하세요

# daemon 리스닝 포트
port: 6000

# 로그 레벨 (debug, info, warn, error)
log_level: info

# 로그 파일 경로
log_file: /var/log/multica/daemon.log

# TLS 설정 (선택사항)
# tls:
#   enabled: false
#   cert_file: ""
#   key_file: ""
EOF

echo "✓ $MULTICA_HOME/config/daemon.yaml 생성"

# 로그 디렉토리 생성
mkdir -p /var/log/multica 2>/dev/null || mkdir -p "$MULTICA_HOME/logs"

echo ""
echo "=== 설치 완료 ==="
echo ""
echo "다음 단계:"
echo "1. 로그인: $INSTALL_DIR/multica login"
echo "2. daemon 시작: $INSTALL_DIR/multica daemon start"
echo "3. 상태 확인: $INSTALL_DIR/multica status"
echo ""
echo "설정 파일: $MULTICA_HOME/config/daemon.yaml"
echo "로그 디렉토리: /var/log/multica (또는 $MULTICA_HOME/logs)"
