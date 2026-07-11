/*
 * make-pdf.mjs — assemble the book into one print-ready HTML file and export a PDF.
 *
 *   node make-pdf.mjs
 *
 * Step 1 concatenates the cover, contents, introduction and all 16 chapters into
 *   book/print.html, each wrapped in a <section class="sheet"> that starts on a
 *   fresh page, with print CSS that keeps diagrams whole and repeats table headers.
 * Step 2 renders that file to book/The-Long-Way-Around.pdf with headless Chrome
 *   (DevTools "Page.printToPDF": background colours on, A4, page-number footer).
 *
 * Open book/print.html directly in Chrome and Ctrl-P → "Save as PDF" to get the
 * same result by hand.
 */

import { readFileSync, writeFileSync, mkdtempSync } from 'node:fs';
import { spawn } from 'node:child_process';
import { setTimeout as sleep } from 'node:timers/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const BOOK_DIR = resolve('.');
const OUT_HTML = join(BOOK_DIR, 'print.html');
const OUT_PDF = join(BOOK_DIR, 'The-Long-Way-Around.pdf');
const CHROME = 'C:/Program Files/Google/Chrome/Application/chrome.exe';

// ---------------------------------------------------------------- build HTML

const read = (f) => readFileSync(join(BOOK_DIR, f), 'utf8');
const inner = (html) => {
  const m = html.match(/<main class="book">([\s\S]*?)<\/main>/);
  if (!m) throw new Error('no <main class="book"> found');
  return m[1];
};
const stripNav = (s) => s.replace(/<nav class="chapter-nav">[\s\S]*?<\/nav>/g, '').trim();

// Cover + contents come out of index.html.
const idx = inner(read('index.html'));
const cover = idx.match(/<div class="cover">[\s\S]*?<\/div>/)[0];
let toc = idx.match(/<ol class="toc">[\s\S]*?<\/ol>/)[0];
const note = idx.match(/<p style="text-align:center[\s\S]*?<\/p>/)[0];

// Rewrite the contents links to internal anchors so they stay clickable in the PDF.
toc = toc
  .replace(/href="00-introduction\.html"/g, 'href="#sec-intro"')
  .replace(/href="chapter-(\d\d)\.html"/g, 'href="#sec-ch$1"');

const sections = [];
sections.push(`<section class="sheet cover-sheet" id="sec-cover">\n${cover}\n</section>`);
sections.push(
  `<section class="sheet toc-sheet" id="sec-contents">\n<h1 class="contents-title">Contents</h1>\n${toc}\n${note}\n</section>`
);
sections.push(`<section class="sheet" id="sec-intro">\n${stripNav(inner(read('00-introduction.html')))}\n</section>`);
for (let n = 1; n <= 16; n++) {
  const nn = String(n).padStart(2, '0');
  sections.push(`<section class="sheet" id="sec-ch${nn}">\n${stripNav(inner(read(`chapter-${nn}.html`)))}\n</section>`);
}

const PRINT_CSS = `
/* ===== Print / PDF layout for "The Long Way Around" ===== */
@page {
  size: A4;
  margin: 22mm 20mm 18mm;
}

/* Screen preview: give each sheet a little breathing room so print.html is
   readable in a browser too. Page breaks below only take effect when printing. */
@media screen {
  body { background: #eceae3; }
  .sheet {
    background: var(--paper);
    max-width: 46rem;
    margin: 1.5rem auto;
    padding: 3rem 3rem 3.5rem;
    box-shadow: 0 4px 24px rgba(0,0,0,0.08);
    border-radius: 6px;
  }
  main.book { max-width: none; padding: 1rem 0 3rem; }
}

@media print {
  /* Make callout backgrounds, table shading and diagram fills actually print. */
  *, *::before, *::after {
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }

  html { scroll-behavior: auto; }
  body { background: #fff; font-size: 10.6pt; }
  main.book { max-width: none; margin: 0; padding: 0; }

  /* Every section starts on a fresh page; the cover is page one. */
  .sheet { break-before: page; }
  .sheet:first-child { break-before: auto; }

  nav.chapter-nav { display: none !important; }

  /* --- Diagrams: never split across a page boundary. --- */
  figure.diagram { break-inside: avoid; page-break-inside: avoid; overflow: visible; }
  figure.diagram svg { max-width: 100%; height: auto; }

  /* --- Tables: may break across pages, but the <thead> repeats on each page. --- */
  .table-wrap { overflow: visible !important; }
  table { break-inside: auto; }
  thead { display: table-header-group; }
  tfoot { display: table-footer-group; }
  tr, th, td { break-inside: avoid; }
  caption { break-after: avoid; }

  /* --- Keep related blocks together where it reads better. --- */
  h1, h2, h3, h4 { break-after: avoid; }
  h2, h3, h4 { break-inside: avoid; }
  .pullquote, .story, .try-this, .callout, .short-version { break-inside: avoid; }
  figure, img, svg { break-inside: avoid; }
  p, li { orphans: 2; widows: 2; }
}

.contents-title { margin-top: 0; }
.cover-sheet { text-align: center; }
`;

const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light">
<title>The Long Way Around · Building a Business, Phase by Phase</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="assets/style.css">
<style>${PRINT_CSS}</style>
</head>
<body>
<main class="book">
${sections.join('\n\n')}
</main>
</body>
</html>
`;

writeFileSync(OUT_HTML, html, 'utf8');
console.log(`Wrote ${OUT_HTML} (${sections.length} sections, ${(html.length / 1024).toFixed(0)} KB)`);

// ---------------------------------------------------------------- render PDF

const fileUrl = pathToFileURL(OUT_HTML).href;
const PORT = 9333 + Math.floor((Date.now ? 0 : 0)); // fixed port; isolated profile below
const userDir = mkdtempSync(join(tmpdir(), 'lwa-chrome-'));

const chrome = spawn(
  CHROME,
  [
    '--headless=new',
    '--disable-gpu',
    '--no-first-run',
    '--no-default-browser-check',
    '--hide-scrollbars',
    `--user-data-dir=${userDir}`,
    `--remote-debugging-port=${PORT}`,
    'about:blank',
  ],
  { stdio: 'ignore' }
);

async function browserWsUrl() {
  for (let i = 0; i < 100; i++) {
    try {
      const r = await fetch(`http://127.0.0.1:${PORT}/json/version`);
      const j = await r.json();
      if (j.webSocketDebuggerUrl) return j.webSocketDebuggerUrl;
    } catch {
      /* not up yet */
    }
    await sleep(100);
  }
  throw new Error('Chrome DevTools endpoint never came up');
}

function cdp(ws) {
  let id = 0;
  const pending = new Map();
  const waiters = [];
  ws.addEventListener('message', (ev) => {
    const msg = JSON.parse(ev.data);
    if (msg.id && pending.has(msg.id)) {
      const { resolve: res, reject } = pending.get(msg.id);
      pending.delete(msg.id);
      msg.error ? reject(new Error(JSON.stringify(msg.error))) : res(msg.result);
    } else if (msg.method) {
      for (let i = waiters.length - 1; i >= 0; i--) {
        const w = waiters[i];
        if (w.method === msg.method && (!w.sessionId || w.sessionId === msg.sessionId)) {
          waiters.splice(i, 1);
          w.resolve(msg);
        }
      }
    }
  });
  const send = (method, params = {}, sessionId) =>
    new Promise((res, reject) => {
      const m = { id: ++id, method, params };
      if (sessionId) m.sessionId = sessionId;
      pending.set(m.id, { resolve: res, reject });
      ws.send(JSON.stringify(m));
    });
  const waitEvent = (method, sessionId) =>
    new Promise((res) => waiters.push({ method, sessionId, resolve: res }));
  return { send, waitEvent };
}

const wsUrl = await browserWsUrl();
const ws = new WebSocket(wsUrl);
await new Promise((res, reject) => {
  ws.addEventListener('open', res);
  ws.addEventListener('error', reject);
});
const { send, waitEvent } = cdp(ws);

const { targetId } = await send('Target.createTarget', { url: 'about:blank' });
const { sessionId } = await send('Target.attachToTarget', { targetId, flatten: true });
await send('Page.enable', {}, sessionId);
const loaded = waitEvent('Page.loadEventFired', sessionId);
await send('Page.navigate', { url: fileUrl }, sessionId);
await loaded;
// Give web fonts + layout a moment to settle.
await send(
  'Runtime.evaluate',
  { expression: 'document.fonts && document.fonts.ready ? document.fonts.ready.then(() => 1) : 1', awaitPromise: true },
  sessionId
);
await sleep(400);

const footer =
  '<div style="width:100%;font-size:8.5px;text-align:center;color:#9a968c;' +
  'font-family:Inter,Segoe UI,sans-serif;"><span class="pageNumber"></span></div>';

const { data } = await send(
  'Page.printToPDF',
  {
    printBackground: true,
    preferCSSPageSize: true,
    displayHeaderFooter: true,
    headerTemplate: '<span></span>',
    footerTemplate: footer,
  },
  sessionId
);

writeFileSync(OUT_PDF, Buffer.from(data, 'base64'));
console.log(`Wrote ${OUT_PDF} (${(Buffer.from(data, 'base64').length / 1024).toFixed(0)} KB)`);

try {
  await send('Browser.close');
} catch {
  /* ignore */
}
ws.close();
chrome.kill();
await sleep(200);
process.exit(0);
