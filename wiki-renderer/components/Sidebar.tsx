"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import type { NavNode } from "@/lib/content";
import { WIKI_NAME } from "@/lib/config";

function Chevron() {
  return (
    <svg
      className="chevron"
      width="12"
      height="12"
      viewBox="0 0 16 16"
      fill="none"
      aria-hidden="true"
    >
      <path
        d="M6 4l4 4-4 4"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function Leaf({ node, active }: { node: NavNode; active: string }) {
  return (
    <Link
      href={node.href}
      className={`nav-link${node.href === active ? " active" : ""}`}
    >
      {node.title}
    </Link>
  );
}

function Section({ node, active }: { node: NavNode; active: string }) {
  // Open the section that contains the current page by default.
  const containsActive =
    node.href === active || node.children.some((c) => c.href === active);
  const [open, setOpen] = useState(containsActive);

  return (
    <div className="nav-section">
      <button
        type="button"
        aria-expanded={open}
        onClick={() => setOpen((o) => !o)}
      >
        <Chevron />
        <span className="section-label">{node.title}</span>
      </button>
      {open && (
        <div className="nav-children">
          {node.hasPage && (
            <Link
              href={node.href}
              className={`nav-link nav-section-link${
                node.href === active ? " active" : ""
              }`}
            >
              Overview
            </Link>
          )}
          {node.children.map((child) =>
            child.children.length > 0 ? (
              <Section key={child.href} node={child} active={active} />
            ) : (
              <Leaf key={child.href} node={child} active={active} />
            ),
          )}
        </div>
      )}
    </div>
  );
}

export default function Sidebar({ nav }: { nav: NavNode[] }) {
  const pathname = usePathname();

  return (
    <aside className="reader-sidebar">
      <Link href="/wiki" className="sidebar-head">
        <span className="mono-label eyebrow">Wiki</span>
        <span className="title">{WIKI_NAME}</span>
      </Link>
      <nav className="sidebar-nav wiki-scroll">
        {nav.map((node) =>
          node.children.length > 0 ? (
            <Section key={node.href} node={node} active={pathname} />
          ) : (
            <Leaf key={node.href} node={node} active={pathname} />
          ),
        )}
      </nav>
    </aside>
  );
}
