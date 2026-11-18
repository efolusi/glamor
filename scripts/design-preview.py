#!/usr/bin/env python3
"""Builds a local preview of the Glamor design system and opens it.

    scripts/design-preview.py [--no-open]

Writes build/design-preview/index.html: every component and screen card in
components/, grouped as in the design system, in light or dark. The cards load
React 18.3.1 from the jsDelivr CDN, so they need the network."""
import html, json, os, re, shutil, subprocess, sys

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
comp = os.path.join(root, 'components')
out = os.path.join(root, 'build', 'design-preview')
shutil.rmtree(out, ignore_errors=True)
os.makedirs(out)

# The CSS variables the design system's runtime makes from tokens.json.
t = json.load(open(os.path.join(root, 'tokens.json')))
themes = [x['id'] for x in t['color']['themes']]
def val(tok, theme):
    v = tok['value']
    return v if isinstance(v, str) else v.get(theme, v[themes[0]])
def colors(theme):
    return ''.join('--%s:%s;' % (k['name'], val(k, theme)) for fam in ('color', 'shadow') for k in t[fam]['tokens'])
rest = ''.join('--%s:%s;' % (k['name'], k['value']) for fam, b in t.items()
               if isinstance(b, dict) and 'tokens' in b and fam not in ('color', 'shadow', 'type') for k in b['tokens'])
rest += ''.join('--font-%s:%s;' % (k, v) for k, v in t['type']['families'].items())
css = ':root{%s%s}:root[data-theme=dark]{color-scheme:dark;%s}' % (colors('light'), rest, colors('dark'))
css = re.sub(r'\{([a-z0-9-]+)\}', lambda m: 'var(--%s)' % m.group(1), css)

head = ('<style>%s</style><link rel="stylesheet" href="bundle.css">'
        '<script>document.documentElement.dataset.theme = new URLSearchParams(location.search).get("theme") || "light"</script>'
        '<script src="https://cdn.jsdelivr.net/npm/react@18.3.1/umd/react.production.min.js"></script>'
        '<script src="https://cdn.jsdelivr.net/npm/react-dom@18.3.1/umd/react-dom.production.min.js"></script>'
        '<script src="bundle.js"></script>') % css
for f in ('bundle.css', 'bundle.js'):
    shutil.copy(os.path.join(comp, f), out)

# Uploaded assets are /_blob/<id> on claude.ai and assets/<group>/<name> here.
blobs = {}
for group in json.load(open(os.path.join(root, 'design-system.json'))).get('assetGroups', {}).values():
    for name, f in group['files'].items():
        shutil.copy(os.path.join(root, 'assets', group['name'], name), out)
        blobs['/_blob/' + f['blob']] = name

cards = []
for n in sorted(os.listdir(comp)):
    p = os.path.join(comp, n, 'preview.html')
    if not os.path.exists(p):
        continue
    src = open(p).read()
    first = src.split('\n', 1)[0]
    g = re.search(r'group="([^"]*)"', first)
    w = re.search(r'width=(\d+)', first)
    h = re.search(r'height=(\d+)', first)
    for blob, name in blobs.items():
        src = src.replace(blob, name)
    open(os.path.join(out, n + '.html'), 'w').write(src.replace('<head>', '<head>' + head, 1))
    cards.append((g.group(1) if g else 'Cover', n, int(w.group(1)) if w else None, int(h.group(1)) if h else 400))

order = ['Cover', 'Foundations', 'Actions', 'Inputs', 'Navigation', 'Content', 'Feedback', 'Agent', 'Account', 'Pages', 'Proposed', 'Retired']
groups = sorted({c[0] for c in cards}, key=lambda g: (order.index(g) if g in order else len(order), g))
body = ''
for g in groups:
    body += '<h2>%s</h2>' % html.escape(g)
    for group, n, w, h in cards:
        if group == g:
            size = 'width:%dpx' % w if w else 'width:100%;max-width:1000px'
            body += ('<figure><figcaption>%s</figcaption><iframe data-src="%s.html" style="%s;height:%dpx"></iframe></figure>'
                     % (html.escape(n), html.escape(n), size, h))

index = '''<!doctype html>
<html data-theme="light"><head><meta charset="utf-8"><title>Glamor</title>
<style>%s
body{margin:0;padding:24px 32px;background:var(--window);color:var(--text);font:13px/16px var(--font-sans)}
header{display:flex;align-items:center;gap:12px;margin-bottom:8px}
h1{font-size:20px;line-height:24px;margin:0;flex:1}
h2{font-size:15px;line-height:20px;margin:32px 0 12px}
button{font:inherit;padding:4px 12px;border-radius:6px;border:1px solid var(--border);background:var(--card);color:var(--text)}
button[aria-pressed=true]{border-color:var(--accent);color:var(--accent)}
figure{margin:0 0 16px;overflow-x:auto}
figcaption{color:var(--text2);font-size:12px;margin-bottom:4px}
iframe{display:block;border:1px solid var(--border);border-radius:12px;background:var(--panel)}
</style></head><body>
<header><h1>Glamor</h1><button data-theme="light">Light</button><button data-theme="dark">Dark</button></header>
%s
<script>
function show(theme) {
  document.documentElement.dataset.theme = theme;
  document.querySelectorAll('header button').forEach(b => b.setAttribute('aria-pressed', b.dataset.theme === theme));
  document.querySelectorAll('iframe').forEach(f => f.src = f.dataset.src + '?theme=' + theme);
}
document.querySelectorAll('header button').forEach(b => b.onclick = () => show(b.dataset.theme));
show(matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
</script></body></html>
''' % (css, body)
path = os.path.join(out, 'index.html')
open(path, 'w').write(index)
print('%d cards in %s' % (len(cards), os.path.relpath(path, root)))
if '--no-open' not in sys.argv:
    subprocess.run(['open', path])
