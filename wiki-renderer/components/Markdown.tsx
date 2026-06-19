"use client";

import ReactMarkdown, { type Components } from "react-markdown";
import remarkGfm from "remark-gfm";
import rehypeSlug from "rehype-slug";
import rehypeAutolinkHeadings from "rehype-autolink-headings";
import ShikiHighlighter, { isInlineCode } from "react-shiki";
import Mermaid from "./Mermaid";

const components: Components = {
  code({ className, children, node, ...props }) {
    const code = String(children ?? "").replace(/\n$/, "");
    const language = /language-(\w+)/.exec(className ?? "")?.[1];

    // Inline `code` spans render as plain <code>.
    if (node ? isInlineCode(node as Parameters<typeof isInlineCode>[0]) : false) {
      return (
        <code className={className} {...props}>
          {children}
        </code>
      );
    }

    // ```mermaid blocks render as diagrams instead of highlighted source.
    if (language === "mermaid") {
      return <Mermaid chart={code} />;
    }

    // factory-dark ≈ One Dark Pro; the wiki forces dark, so a single theme.
    return (
      <ShikiHighlighter language={language ?? "text"} theme="one-dark-pro">
        {code}
      </ShikiHighlighter>
    );
  },
};

export default function Markdown({ content }: { content: string }) {
  return (
    <div className="wiki-prose" id="wiki-article">
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        rehypePlugins={[
          rehypeSlug,
          [
            rehypeAutolinkHeadings,
            { behavior: "wrap", properties: { className: "wiki-heading-anchor" } },
          ],
        ]}
        components={components}
      >
        {content}
      </ReactMarkdown>
    </div>
  );
}
