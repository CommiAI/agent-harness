import { notFound } from "next/navigation";
import Link from "next/link";
import Markdown from "@/components/Markdown";
import Sidebar from "@/components/Sidebar";
import Toc from "@/components/Toc";
import {
  WIKI_NAME,
  breadcrumbTrail,
  buildNav,
  prevNext,
  readMarkdown,
  splitTitle,
} from "@/lib/content";

export const dynamic = "force-dynamic"; // read the content tree on every request

export default async function WikiPage({
  params,
}: {
  params: Promise<{ slug?: string[] }>;
}) {
  const { slug = [] } = await params;
  const content = readMarkdown(slug);
  if (content === null) notFound();

  const nav = buildNav();
  const crumbs = breadcrumbTrail(nav, slug);
  const here = "/wiki" + (slug.length ? "/" + slug.join("/") : "");
  const { prev, next } = prevNext(nav, here);
  const fallbackTitle = crumbs.at(-1)?.title ?? WIKI_NAME;
  const { title, body } = splitTitle(content, fallbackTitle);

  return (
    <>
      <header className="reader-header">
        <Link href="/wiki" className="reader-wordmark">
          <span className="mark">✦</span>
          <span className="name">AutoWiki</span>
        </Link>
        <nav className="mono-label">
          <Link href="/wiki">Overview</Link>
          <Link href="/wiki/by-the-numbers">Numbers</Link>
          <Link href="/wiki/lore">Lore</Link>
        </nav>
      </header>

      <main className="reader-main">
        <div className="reader-frame">
          <Sidebar nav={nav} />

          <div className="reader-content">
            <div className="breadcrumb mono-label">
              <Link href="/wiki">{WIKI_NAME}</Link>
              {crumbs.map((c, i) => (
                <span key={c.href} className="contents">
                  <span className="sep">/</span>
                  {i === crumbs.length - 1 ? (
                    <span className="current">{c.title}</span>
                  ) : (
                    <Link href={c.href}>{c.title}</Link>
                  )}
                </span>
              ))}
            </div>

            <div className="reader-article-scroll wiki-scroll">
              <article className="article">
                <header className="article-head">
                  <span className="mono-label article-eyebrow">{WIKI_NAME}</span>
                  <h1 className="article-title">{title}</h1>
                </header>

                <Markdown content={body} />

                <footer className="wiki-footer">
                  <p className="wiki-attribution">
                    Modeled on Factory AutoWiki and generated from repository
                    content. A preview for codebase exploration, not
                    source-maintained documentation.
                  </p>
                  {(prev || next) && (
                    <nav className="wiki-nav">
                      {prev ? (
                        <Link href={prev.href} className="wiki-nav-card prev">
                          <span className="mono-label dir">Previous</span>
                          <span className="label">{prev.title}</span>
                        </Link>
                      ) : (
                        <span style={{ flex: "1 1 0" }} />
                      )}
                      {next ? (
                        <Link href={next.href} className="wiki-nav-card next">
                          <span className="mono-label dir">Next</span>
                          <span className="label">{next.title}</span>
                        </Link>
                      ) : (
                        <span style={{ flex: "1 1 0" }} />
                      )}
                    </nav>
                  )}
                </footer>
              </article>
            </div>
          </div>

          <Toc slug={here} />
        </div>
      </main>
    </>
  );
}
