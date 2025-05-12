# Rootless-DevBox

sudo나 root 권한 없이 루트리스 환경에서 Devbox를 자동으로 설치할 수 있는 간단한 솔루션입니다.

[![GitHub License](https://img.shields.io/github/license/nebstudio/Rootless-DevBox)](https://github.com/nebstudio/Rootless-DevBox/blob/main/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/nebstudio/Rootless-DevBox?style=social)](https://github.com/nebstudio/Rootless-DevBox/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/nebstudio/Rootless-DevBox)](https://github.com/nebstudio/Rootless-DevBox/issues)

## Rootless-DevBox란?

Rootless-DevBox는 [Devbox](https://github.com/jetify-com/devbox)를 루트 권한이 없는 환경(공유 호스팅, 대학 시스템, 제한된 회사 환경 등)에서도 설치하고 사용할 수 있게 해주는 프로젝트입니다. [nix-user-chroot](https://github.com/nix-community/nix-user-chroot)를 활용하여 Nix와 Devbox가 권한 상승 없이 컨테이너 환경에서 동작하도록 합니다.

## 주요 특징

- 🛡️ **루트 권한 불필요**: sudo나 root 없이 Devbox 설치 및 사용 가능
- 🔄 **격리된 환경**: 시스템에 영향을 주지 않고 패키지를 격리된 환경에서 실행
- 🚀 **간편 설치**: 하나의 스크립트로 모든 설치 자동화
- 💻 **다양한 리눅스 지원**: 여러 리눅스 배포판 및 아키텍처 지원
- 🔒 **안전성**: 시스템 파일이 아닌 사용자 환경만 변경

## 빠른 시작

> **참고:**  
> 설치 스크립트는 일부 단계에서 여러 번 사용자 입력을 요구하는 **대화형** 방식입니다.  
> 이는 설치 과정에서 선택권을 제공하고, 각 단계를 이해하며, 다양한 환경에 맞게 유연하게 설치할 수 있도록 설계된 것입니다.  
> 프롬프트가 많더라도 복잡하게 느끼지 마세요. 이는 호환성과 사용자 제어권을 극대화하기 위한 의도입니다.

터미널에서 아래 명령어를 실행하세요:

```bash
# 설치 스크립트 다운로드
curl -o rootless-devbox-installer.sh https://raw.githubusercontent.com/nebstudio/Rootless-DevBox/main/install.sh

# 실행 권한 부여
chmod +x rootless-devbox-installer.sh

# 설치 스크립트 실행
./rootless-devbox-installer.sh
```

## 동작 원리

Rootless-DevBox는 3단계로 환경을 구성합니다:

1. **nix-user-chroot 설치**: 사용자 공간 chroot 환경을 만드는 도구 다운로드 및 설정
2. **Nix 환경 생성**: 사용자 디렉토리에 컨테이너화된 Nix 환경 구축
3. **Devbox 설치**: 이 환경 내에 Devbox 설치

설치 후에는 `nix-chroot` 명령어로 격리된 개발 환경에 진입할 수 있습니다.

## 사용법

### Nix 환경 진입

설치 후 아래 명령어로 Nix 환경에 진입하세요:

```bash
nix-chroot
```

프롬프트가 아래와 같이 바뀝니다:

```
(nix-chroot) user@hostname:~$
```

### Devbox 사용

nix-chroot 환경 내에서 Devbox를 사용할 수 있습니다:

```bash
# 도움말 보기
devbox help

# 새 프로젝트 초기화
devbox init

# 패키지 추가
devbox add nodejs python

# 개발 환경 shell 시작
devbox shell
```

### 환경 종료

```bash
exit
```

## 요구 사항

- 리눅스 기반 운영체제
- Bash shell
- 인터넷 연결
- 루트 권한 불필요

## 지원 아키텍처

- x86_64
- aarch64/arm64
- armv7
- i686/i386

## 문제 해결

**Q: nix-chroot 명령어를 찾을 수 없다고 나옵니다.**  
A: `~/.local/bin`이 PATH에 포함되어 있는지 확인하세요. `source ~/.bashrc`를 실행하거나 터미널을 재시작하세요.

**Q: nix-user-chroot 다운로드에 실패합니다.**  
A: 인터넷 연결을 확인하세요. 계속 문제가 발생하면 [릴리즈 페이지](https://github.com/nix-community/nix-user-chroot/releases)에서 직접 바이너리를 다운로드하세요.

**Q: Nix 환경에서 패키지 설치가 안 됩니다.**  
A: 시스템에 할당량 제한이나 디스크 공간 부족이 있을 수 있습니다. `df -h ~`로 공간을 확인하세요.

더 많은 도움이 필요하면 [이슈 등록](https://github.com/nebstudio/Rootless-DevBox/issues)을 이용하세요.

## 제거(언인스톨)

Rootless-DevBox를 제거하려면 두 가지 방법이 있습니다:

### 방법 1: 언인스톨 스크립트 사용

제공된 언인스톨 스크립트를 사용하세요:

```bash
# 언인스톨러 다운로드
curl -o rootless-devbox-uninstaller.sh https://raw.githubusercontent.com/nebstudio/Rootless-DevBox/main/uninstall.sh

# 실행 권한 부여
chmod +x rootless-devbox-uninstaller.sh

# 언인스톨러 실행
./rootless-devbox-uninstaller.sh
```

### 방법 2: 수동 제거(권장)

1. **설치된 바이너리 삭제**:
   ```bash
   rm -f ~/.local/bin/devbox
   rm -f ~/.local/bin/nix-chroot
   rm -f ~/.local/bin/nix-user-chroot
   ```

2. **Nix 디렉토리 정리** (선택, 모든 Nix 패키지 삭제):
   ```bash
   rm -rf ~/.nix
   ```

3. **⚠️ 중요: 쉘 설정 파일 수정** (`~/.bashrc`, `~/.zshrc` 등):

   - PATH 추가 라인 삭제:
     ```bash
     export PATH="$HOME/.local/bin:$PATH" # Added by Rootless-DevBox
     ```
   - PS1 프롬프트 블록 삭제:
     ```bash
     # Rootless-DevBox nix-chroot environment indicator
     if [ "$NIX_CHROOT" = "1" ]; then
       PS1="(nix-chroot) \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
     fi
     ```

   수정 후 적용:
   ```bash
   source ~/.bashrc
   ```

> **참고:** 언인스톨 스크립트가 자동으로 설정 파일을 수정하려고 하지만, **직접 확인하고 삭제하는 것이 가장 안전합니다.**

제거 후에는 터미널을 재시작하는 것이 좋습니다.

## 기여

기여를 환영합니다! Pull Request를 제출해 주세요.

1. 저장소를 포크하세요
2. 브랜치 생성: `git checkout -b feature/your-feature`
3. 변경사항 커밋: `git commit -m 'Add your feature'`
4. 브랜치 푸시: `git push origin feature/your-feature`
5. Pull Request 생성

## 감사의 말

이 프로젝트는 다음과 같은 훌륭한 프로젝트 덕분에 가능했습니다:

- [nix-user-chroot](https://github.com/nix-community/nix-user-chroot)
- [Devbox](https://github.com/jetify-com/devbox)
- [Nix](https://nixos.org/)

## 라이선스

MIT 라이선스 - 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

## 보안 안내

Rootless-DevBox는 사용자의 홈 디렉토리 내 파일만 수정하며, 루트 권한을 요구하거나 사용하지 않습니다. 제한된 환경에서도 안전하게 사용할 수 있습니다.

---

⭐ 이 프로젝트가 도움이 되었다면 GitHub에서 Star를 눌러주세요! ⭐

[nebstudio](https://github.com/nebstudio) 제작 ❤️