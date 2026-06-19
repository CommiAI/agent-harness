"use client";

import { useEffect, useId, useRef, useState } from "react";
import mermaid from "mermaid";

// Dark diagram theme tuned to the Factory AutoWiki palette.
mermaid.initialize({
  startOnLoad: false,
  securityLevel: "loose",
  theme: "base",
  themeVariables: {
    background: "transparent",
    primaryColor: "#1f1d1c",
    primaryBorderColor: "#3d3a39",
    primaryTextColor: "#d6d3d2",
    secondaryColor: "#101010",
    tertiaryColor: "#101010",
    lineColor: "#5c5855",
    textColor: "#b8b3b0",
    fontFamily: "var(--font-mono)",
    fontSize: "13px",
  },
});

export default function Mermaid({ chart }: { chart: string }) {
  const ref = useRef<HTMLDivElement>(null);
  const [error, setError] = useState<string | null>(null);
  // Mermaid needs a DOM-id-safe identifier for each diagram.
  const id = "mmd-" + useId().replace(/[^a-zA-Z0-9]/g, "");

  useEffect(() => {
    let cancelled = false;
    mermaid
      .render(id, chart.trim())
      .then(({ svg }) => {
        if (!cancelled && ref.current) ref.current.innerHTML = svg;
      })
      .catch((e) => {
        if (!cancelled) setError(String(e?.message ?? e));
      });
    return () => {
      cancelled = true;
    };
  }, [chart, id]);

  if (error) {
    return (
      <pre className="wiki-mermaid" style={{ color: "#e06c75", fontSize: "12px" }}>
        Mermaid error: {error}
        {"\n\n"}
        {chart}
      </pre>
    );
  }

  return <div ref={ref} className="wiki-mermaid" />;
}
