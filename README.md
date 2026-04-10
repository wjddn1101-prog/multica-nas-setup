# Multica Cloud NAS 설정 가이드

Multica Cloud를 NAS 224+에 설치하고 런타임으로 등록하는 방법입니다.

## 📋 필수 조건

- **NAS 장치**: NAS 224+ 또는 유사한 Linux 기반 NAS
- **SSH 접속**: NAS에 SSH로 접속 가능해야 함
- **Multica Cloud 계정**: https://cloud.multica.io에서 가입 필요
- **인터넷 연결**: daemon이 Multica Cloud와 통신할 수 있어야 함

## 🚀 빠른 시작

### 1단계: NAS에 접속

```bash
ssh [user@nas-address]
# 또는
ssh [user@192.168.x.x]
```

### 2단계: 스크립트 다운로드

```bash
# 방법 1: GitHub에서 클론 (권장)
git clone https://github.com/[your-username]/multica-nas-setup.git
cd multica-nas-setup

# 방법 2: 수동 다운로드
# GitHub에서 파일들을 다운로드하고 NAS에 업로드
```

### 3단계: 설치 스크립트 실행

```bash
chmod +x install-multica.sh
./install-multica.sh
```

**설치 내용:**
- Multica 바이너리 다운로드 및 설치
- 홈 디렉토리 생성
- 설정 파일 템플릿 생성

### 4단계: Multica 로그인

```bash
./multica login
```

프롬프트에 따라:
- **Multica Cloud 계정** 입력
- 또는 **API 토큰** 입력 (환경 변수 권장)

```bash
# API 토큰으로 로그인 (권장)
export MULTICA_API_TOKEN="your-api-token-here"
./multica auth set-token $MULTICA_API_TOKEN
```

### 5단계: daemon 시작

```bash
chmod +x start-daemon.sh
./start-daemon.sh
```

또는 직접 실행:

```bash
./multica daemon start
```

### 6단계: 확인

다른 터미널에서:

```bash
./multica status
```

Multica Cloud 대시보드에서도 확인:
1. https://cloud.multica.io 접속
2. "Runtimes" 섹션에서 NAS 장치가 "Available" 상태인지 확인

---

## 📁 파일 설명

| 파일 | 설명 |
|------|------|
| `install-multica.sh` | Multica 설치 스크립트 |
| `start-daemon.sh` | daemon 시작 스크립트 |
| `multica-daemon.yaml` | daemon 설정 파일 |
| `README.md` | 이 문서 |
| `.gitignore` | Git 무시 파일 |

---

## 🔧 상세 설정

### 설정 파일 위치

- **기본 위치**: `~/.multica/config/daemon.yaml`
- **커스텀**: `MULTICA_HOME` 환경 변수로 변경 가능

```bash
export MULTICA_HOME=/custom/path
```

### 주요 설정 옵션

```yaml
# daemon 포트
port: 6000

# 로그 레벨
log_level: info  # debug, info, warn, error

# 리소스 제한
max_concurrent_jobs: 10
# cpu_limit: 4
# memory_limit: 2048
```

[전체 설정 옵션은 `multica-daemon.yaml` 참고](#설정-파일-상세)

---

## 🔐 보안 설정

### API 토큰 관리

**권장: 환경 변수 사용**

```bash
# .bashrc 또는 .zshrc에 추가
export MULTICA_API_TOKEN="your-token"

# 또는 .env 파일 사용
source .env
```

**주의**: `.env` 파일을 `.gitignore`에 추가하세요

```bash
echo ".env" >> .gitignore
```

### TLS/SSL 설정

```yaml
tls:
  enabled: true
  cert_file: /etc/multica/cert.pem
  key_file: /etc/multica/key.pem
```

---

## 📊 daemon 관리

### 상태 확인

```bash
./multica status
./multica info
```

### 로그 확인

```bash
# 실시간 로그
tail -f ~/.multica/logs/daemon.log

# 또는
tail -f /var/log/multica/daemon.log
```

### daemon 재시작

```bash
./multica daemon restart
```

### daemon 중지

```bash
./multica daemon stop
```

---

## 🐛 문제 해결

### 설치 오류

**Q: "다운로드 실패" 오류**

A: 인터넷 연결 확인 후, 수동으로 바이너리 다운로드:

```bash
# GitHub releases에서 직접 다운로드
wget https://github.com/multicastcloud/multica/releases/download/v[VERSION]/multica-linux-amd64
chmod +x multica-linux-amd64
mv multica-linux-amd64 multica
```

### 로그인 오류

**Q: "인증 실패" 오류**

A: 토큰 확인 및 재로그인

```bash
# 기존 인증 정보 삭제
rm -rf ~/.multica/.auth

# 다시 로그인
./multica login
```

### daemon 실행 오류

**Q: daemon이 시작되지 않음**

A: 로그 확인

```bash
./multica daemon start --log-level debug
```

로그 파일 확인:

```bash
cat ~/.multica/logs/daemon.log
```

### 포트 충돌

**Q: "포트 이미 사용 중" 오류**

A: 포트 변경

```yaml
# multica-daemon.yaml에서
port: 6001  # 6000 대신 다른 포트 사용
```

---

## 🔄 systemd 서비스로 등록 (선택사항)

daemon을 자동으로 시작하려면 systemd 서비스로 등록:

```bash
# /etc/systemd/system/multica.service 생성
sudo nano /etc/systemd/system/multica.service
```

다음 내용 입력:

```ini
[Unit]
Description=Multica Cloud Runtime Daemon
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/multica-nas-setup
ExecStart=/root/multica-nas-setup/multica daemon start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

서비스 활성화:

```bash
sudo systemctl daemon-reload
sudo systemctl enable multica
sudo systemctl start multica

# 상태 확인
sudo systemctl status multica
```

---

## 📈 모니터링

### Multica Cloud 대시보드

1. https://cloud.multica.io 접속
2. "Runtimes" → NAS 장치 선택
3. 리소스 사용량, 작업 이력 확인

### 로컬 모니터링

```bash
# daemon 리소스 사용량
top -p $(pgrep -f multica)

# 네트워크 연결 확인
netstat -an | grep 6000
```

---

## 🆘 지원

### 공식 문서
- [Multica Cloud 문서](https://docs.multica.io)
- [GitHub Issues](https://github.com/multicastcloud/multica/issues)

### 로그 수집 (지원 요청 시)

```bash
# 상태 정보 수집
./multica info > multica-info.txt

# 로그 수집
cp ~/.multica/logs/daemon.log multica-logs.txt

# 설정 파일 (민감한 정보 제거 후)
cp ~/.multica/config/daemon.yaml multica-config.yaml
```

---

## 📝 변경 이력

- **v1.0** (2024-01-xx): 초기 버전 작성

---

## 📄 라이선스

이 설정 스크립트는 MIT 라이선스 하에 제공됩니다.

---

## 💬 피드백

이슈나 개선 제안은 GitHub Issues에 등록해주세요.
