"use client";

import { useEffect, useState } from "react";

interface Heading {
  id: string;
  text: string;
  depth: number;
}

// Reads the rendered article headings (which already carry rehype-slug ids) and
// tracks the one currently in view — so the TOC always matches the anchors.
export default function Toc({ slug }: { slug: string }) {
  const [headings, setHeadings] = useState<Heading[]>([]);
  const [activeId, setActiveId] = useState<string>("");

  useEffect(() => {
    const article = document.getElementById("wiki-article");
    if (!article) return;

    const els = Array.from(
      article.querySelectorAll<HTMLElement>("h2, h3"),
    ).filter((el) => el.id);

    setHeadings(
      els.map((el) => ({
        id: el.id,
        text: el.textContent ?? "",
        depth: el.tagName === "H3" ? 3 : 2,
      })),
    );

    const observer = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((e) => e.isIntersecting)
          .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
        if (visible[0]) setActiveId(visible[0].target.id);
      },
      { rootMargin: "0px 0px -70% 0px", threshold: 0 },
    );
    els.forEach((el) => observer.observe(el));
    return () => observer.disconnect();
    // Re-scan whenever the page (slug) changes.
  }, [slug]);

  if (headings.length === 0) return <aside className="reader-toc" />;

  return (
    <aside className="reader-toc">
      <div className="toc-inner wiki-scroll">
        <span className="mono-label toc-label">On this page</span>
        <nav className="toc-list">
          {headings.map((h) => (
            <a
              key={h.id}
              href={`#${h.id}`}
              className={`${h.depth === 3 ? "depth-3" : ""}${
                h.id === activeId ? " active" : ""
              }`}
            >
              {h.text}
            </a>
          ))}
        </nav>
      </div>
    </aside>
  );
}
