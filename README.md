# UniVoice 홈페이지

유학생을 위한 전공 특화 실시간 강의 통역 서비스 **UniVoice**의 소개 페이지입니다.
배포 주소: https://univoice260214.github.io/

`main` 브랜치에 올리면 GitHub Actions(`.github/workflows/static.yml`)가 그대로 GitHub Pages에 배포합니다. 빌드 과정은 없습니다.

## 구성

| 경로 | 내용 |
|---|---|
| `index.html` | 본문. 글을 고치려면 이 파일만 수정합니다. |
| `assets/css/site.css` | 스타일. 색은 맨 위 `:root` 값에서 바꿉니다. |
| `assets/js/site.js` | 상단 메뉴 동작 |
| `assets/img/` | 화면 캡처, 목업, 아키텍처 그림, 로고 |
| `tools/` | 이미지 변환·미리보기 스크립트 (배포와 무관) |

## 로컬에서 보기

`index.html`을 브라우저로 열면 됩니다. 서버가 필요하면 저장소 폴더에서 아래를 실행합니다.

```bash
python -m http.server 8080
```

## 이미지 바꾸기

원본 PNG를 `tools/source/`에 같은 이름으로 넣고 아래를 실행하면 `assets/img/`의 WebP가 다시 만들어집니다.

```bash
python tools/prepare_images.py
```

## 내용의 기준

수치와 문구는 졸업프로젝트 심사 발표 자료를 우선으로 하고, 사업계획서 내용을 보탰습니다.
서비스 코드는 [UniVoice260214/prototype](https://github.com/UniVoice260214/prototype)에 있습니다.
