"""홈페이지용 이미지 만들기 (원본 PNG → 가벼운 WebP).

  python tools/prepare_images.py

원본 PNG/SVG 는 tools/source/ 폴더에 둔다 (용량이 커서 저장소에는 올리지 않는다).
화면을 새로 캡처했으면 같은 이름으로 덮어쓴 뒤 이 스크립트만 다시 돌리면 된다.

  hero_transparent.png   머리 영역의 기울어진 목업 (배경 투명)
  hero_background.png    같은 목업, 배경 포함 (공유 미리보기용)
  ui_student_live.png    학생 수업 화면        ui_student_home.png   학생 홈
  ui_prof_setup.png      교수자 수업 준비      ui_prof_live.png      교수자 수업 진행
  demo-photo.png         실제 시연 사진
  architecture.svg       아키텍처 그림         logo.svg              로고
"""
import shutil
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "img"
OUT.mkdir(parents=True, exist_ok=True)
S = Path(__file__).resolve().parent / "source"

# 이름: (원본, 가로 폭(px), 품질)
SRC = {
    "hero": (S / "hero_transparent.png", 2200, 86),
    "ui-student-live": (S / "ui_student_live.png", 1800, 86),
    "ui-student-home": (S / "ui_student_home.png", 1800, 86),
    "ui-prof-setup": (S / "ui_prof_setup.png", 780, 88),
    "ui-prof-live": (S / "ui_prof_live.png", 780, 88),
    "demo-photo": (S / "demo-photo.png", 1800, 82),
}


def to_webp(name, src, width, quality):
    im = Image.open(src)
    if im.width > width:
        im = im.resize((width, round(im.height * width / im.width)), Image.LANCZOS)
    dst = OUT / f"{name}.webp"
    im.save(dst, "WEBP", quality=quality, method=6)
    print(f"{dst.name:26s} {im.width}x{im.height}  {dst.stat().st_size / 1024:.0f} KB")


for name, (src, width, quality) in SRC.items():
    to_webp(name, src, width, quality)

# 공유 미리보기(og:image): 배경이 있는 목업을 1200x630 으로
og = Image.open(S / "hero_background.png").convert("RGB")
og = og.resize((2400, round(og.height * 2400 / og.width)), Image.LANCZOS)
top = (og.height - 1260) // 2
og = og.crop((0, top, 2400, top + 1260)).resize((1200, 630), Image.LANCZOS)
og.save(OUT / "og.jpg", "JPEG", quality=86, optimize=True)
print(f"{'og.jpg':26s} 1200x630  {(OUT / 'og.jpg').stat().st_size / 1024:.0f} KB")

# 벡터 그림은 그대로 복사
for name in ("architecture.svg", "logo.svg"):
    shutil.copyfile(S / name, OUT / name)
print("architecture.svg, logo.svg copied")
