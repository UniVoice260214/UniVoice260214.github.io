// UniVoice 홈페이지 동작
//  1) 상단 메뉴 (모바일 메뉴 · 스크롤 시 테두리 · 현재 구역 표시)
//  2) 탭        [data-tabs]      : role="tab" 버튼을 누르면 aria-controls 가 가리키는 패널만 보인다
//  3) 펼침 상자 [data-accordion] : 상자 하나를 고르면 그 상자만 펼쳐진다
//  4) 값 바꾸기 [data-switch]    : 버튼의 data-value / data-note 를 결과 칸에 넣는다
(() => {
  // ---------- 1) 상단 메뉴 ----------
  const nav = document.getElementById("nav");
  const toggle = nav.querySelector(".nav-toggle");
  const links = [...nav.querySelectorAll(".nav-links a")];

  const setOpen = (open) => {
    nav.classList.toggle("is-open", open);
    toggle.setAttribute("aria-expanded", String(open));
    toggle.setAttribute("aria-label", open ? "메뉴 닫기" : "메뉴 열기");
  };
  toggle.addEventListener("click", () => setOpen(!nav.classList.contains("is-open")));
  links.forEach((a) => a.addEventListener("click", () => setOpen(false)));
  document.addEventListener("keydown", (e) => { if (e.key === "Escape") setOpen(false); });

  const onScroll = () => nav.classList.toggle("is-stuck", window.scrollY > 8);
  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });

  const byId = new Map(links.map((a) => [a.getAttribute("href").slice(1), a]));
  const sections = [...byId.keys()].map((id) => document.getElementById(id)).filter(Boolean);
  if ("IntersectionObserver" in window && sections.length) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        links.forEach((a) => a.classList.remove("is-active"));
        byId.get(entry.target.id)?.classList.add("is-active");
      });
    }, { rootMargin: "-45% 0px -50% 0px" });
    sections.forEach((s) => io.observe(s));
  }

  // ---------- 2) 탭 ----------
  document.querySelectorAll("[data-tabs]").forEach((root) => {
    const tabs = [...root.querySelectorAll('[role="tab"]')];
    const select = (tab, focus) => {
      tabs.forEach((t) => {
        const on = t === tab;
        t.setAttribute("aria-selected", String(on));
        t.tabIndex = on ? 0 : -1;
        const panel = document.getElementById(t.getAttribute("aria-controls"));
        if (panel) panel.hidden = !on;
      });
      if (focus) tab.focus();
    };
    tabs.forEach((tab, i) => {
      tab.addEventListener("click", () => select(tab, false));
      tab.addEventListener("keydown", (e) => {
        const step = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 }[e.key];
        let next = null;
        if (step) next = tabs[(i + step + tabs.length) % tabs.length];
        else if (e.key === "Home") next = tabs[0];
        else if (e.key === "End") next = tabs[tabs.length - 1];
        if (next) { e.preventDefault(); select(next, true); }
      });
    });
  });

  // ---------- 3) 펼침 상자 ----------
  document.querySelectorAll("[data-accordion]").forEach((root) => {
    const items = [...root.querySelectorAll(".pick")];
    items.forEach((item) => item.addEventListener("click", () => {
      items.forEach((other) => other.setAttribute("aria-expanded", String(other === item)));
    }));
  });

  // ---------- 4) 값 바꾸기 ----------
  document.querySelectorAll("[data-switch]").forEach((root) => {
    const buttons = [...root.querySelectorAll("[data-value]")];
    const out = root.querySelector("[data-out]");
    const note = root.querySelector("[data-note-out]");
    const result = out.closest(".result");
    buttons.forEach((button) => button.addEventListener("click", () => {
      buttons.forEach((b) => b.setAttribute("aria-pressed", String(b === button)));
      out.textContent = button.dataset.value;
      if (note) note.textContent = button.dataset.note || "";
      // 같은 애니메이션을 다시 돌리기 위해 클래스를 뗐다 붙인다.
      result.classList.remove("swap");
      void result.offsetWidth;
      result.classList.add("swap");
    }));
  });
})();
