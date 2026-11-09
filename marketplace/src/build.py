#!/usr/bin/env python3
"""Generate listing screenshots (1600x1000) and logo (512x512) as HTML; render.sh turns them into PNG."""
import os
OUT = os.path.dirname(os.path.abspath(__file__))

CSS = """
*{box-sizing:border-box;margin:0;padding:0}
body{width:1600px;height:1000px;background:#0b0f14;color:#e6edf3;font-family:-apple-system,"SF Pro Display","Inter",Helvetica,sans-serif;overflow:hidden;position:relative}
body:before{content:"";position:absolute;inset:0;background:radial-gradient(900px 600px at 85% -10%,rgba(43,212,138,.18),transparent 60%),radial-gradient(700px 500px at -10% 110%,rgba(43,212,138,.10),transparent 60%)}
.wrap{position:relative;height:100%;padding:72px 88px;display:flex;flex-direction:column;gap:40px}
.kicker{font:600 22px/1 "SF Mono",Menlo,monospace;color:#2bd48a;letter-spacing:.08em;text-transform:uppercase}
h1{font-size:76px;line-height:1.02;font-weight:800;letter-spacing:-.03em}
h1 em{font-style:normal;color:#2bd48a}
.sub{font-size:28px;color:#9aa7b4;margin-top:14px;max-width:1200px}
.term{background:#11161d;border:1px solid #232b35;border-radius:18px;box-shadow:0 30px 80px rgba(0,0,0,.55);overflow:hidden;flex:1}
.bar{height:44px;background:#161c24;border-bottom:1px solid #232b35;display:flex;align-items:center;gap:9px;padding:0 18px}
.bar i{width:13px;height:13px;border-radius:50%;display:block}.bar i:nth-child(1){background:#ff5f57}.bar i:nth-child(2){background:#febc2e}.bar i:nth-child(3){background:#28c840}
.bar span{margin-left:14px;font:500 17px "SF Mono",Menlo,monospace;color:#6b7785}
pre{font:400 25px/1.55 "SF Mono",Menlo,monospace;padding:26px 32px;white-space:pre;color:#c9d4df}
.g{color:#2bd48a}.r{color:#ff6b6b}.y{color:#f5c451}.d{color:#6b7785}.b{color:#7cc4ff}.w{color:#fff;font-weight:700}
.strike{color:#ff6b6b;text-decoration:line-through;text-decoration-thickness:3px}
.row{display:flex;gap:36px;flex:1}.row>.term{flex:1}
.tag{display:inline-block;padding:6px 14px;border-radius:999px;font:700 18px "SF Mono",Menlo,monospace}
.tag.bad{background:rgba(255,107,107,.15);color:#ff6b6b}.tag.good{background:rgba(43,212,138,.15);color:#2bd48a}
.brand{position:absolute;right:88px;top:76px;font:700 22px "SF Mono",Menlo,monospace;color:#6b7785}
.brand b{color:#2bd48a}
"""

def page(name, kicker, title, sub, body):
    html = f"""<!doctype html><html><head><meta charset="utf-8"><style>{CSS}</style></head><body>
<div class="brand">clean<b>-</b>commit</div>
<div class="wrap"><div><div class="kicker">{kicker}</div><h1 style="margin-top:18px">{title}</h1><div class="sub">{sub}</div></div>{body}</div></body></html>"""
    open(os.path.join(OUT, name + ".html"), "w").write(html)

def term(title, content, extra=""):
    return f'<div class="term" {extra}><div class="bar"><i></i><i></i><i></i><span>{title}</span></div><pre>{content}</pre></div>'

# 1 — before / after
page("01-before-after", "Remove Claude Co-Author", "Your commits. <em>Your name.</em>",
 "Claude Code signs every commit. This skill doesn't.",
 '<div class="row">' +
 term("git log — without the skill", """<span class="tag bad">BEFORE</span>

<span class="y">commit 3f9a1c2</span>
Author: You

    feat: add refresh token

    <span class="strike">Co-Authored-By: Claude</span>
    <span class="strike">&lt;noreply@anthropic.com&gt;</span>
""") +
 term("git log — with clean-commit", """<span class="tag good">AFTER</span>

<span class="y">commit 8b2e563</span>
Author: You

    <span class="w">feat(auth): add refresh token rotation</span>

    Sessions expired mid-task. Rotate the
    token on every use, revoke the old one.
""") + '</div>')

# 2 — auto activation
phr = ["commit", "haz commit de los cambios", "commitea esto porfa", "guarda estos cambios en git", "create a commit for my changes",
       "can you commit what I did?", "haz un commit con buen mensaje", "listo, ya terminé, haz el commit", "git commit", "save my work in git please"]
lines = "\n".join(f'<span class="d">›</span> {p:<34}<span class="g">✓ clean-commit</span>  <span class="d">no AI trailer</span>' for p in phr)
page("02-auto-activation", "Activates on its own", "Just say <em>“commit”</em>.",
 "Tested in real Claude Code sessions: 10 different phrasings, English and Spanish.",
 term("claude — 10 headless sessions", lines + '\n\n<span class="w">10/10</span> <span class="g">auto-activated</span>   <span class="w">0</span> <span class="g">Co-Authored-By lines</span>'))

# 3 — language
page("03-your-language", "Your language", "Commits in the language <em>you</em> set.",
 "Reads Claude Code’s <span style='font-family:SF Mono,Menlo,monospace;color:#e6edf3'>language</span> setting. Spec keywords stay in English so tools keep working.",
 '<div class="row">' +
 term("~/.claude/settings.json", """{
  <span class="b">"language"</span>: <span class="g">"Español"</span>
}

<span class="d"># project settings override user settings</span>
<span class="d"># unset → English</span>""") +
 term("git log --oneline", """<span class="y">a41c0de</span> <span class="w">feat(auth):</span> validar usuario
<span class="y">7d2f9b1</span> <span class="w">docs(readme):</span> agregar instalación
<span class="y">c09e4aa</span> <span class="w">fix(api):</span> devolver 404

<span class="d">language: "Deutsch"</span>
<span class="y">e18b3f2</span> <span class="w">feat(auth):</span> Token erneuern""") + '</div>')

# 4 — validation
page("04-validation", "Validated before it lands", "Bad commit messages <em>never</em> make it in.",
 "A bundled script strips AI trailers and checks the Conventional Commits header.",
 term("clean-msg.sh", """<span class="d">$</span> git commit -m <span class="y">"Added login."</span>
<span class="r">✗ header is not a Conventional Commit: "Added login."</span>
<span class="d">  expected: &lt;type&gt;(&lt;scope&gt;)?!?: &lt;description&gt;</span>

<span class="d">$</span> git commit -m <span class="y">"feat(auth): add login"</span> -m <span class="y">"Co-Authored-By: Claude"</span>
<span class="g">✓ AI trailer removed · header valid</span>

<span class="d">$</span> git commit -m <span class="y">"fix: x"</span> -m <span class="y">"Co-Authored-By: Ana &lt;ana@team.dev&gt;"</span>
<span class="g">✓ human co-author kept</span>"""))

# 5 — hook
page("05-permanent-hook", "Make it permanent", "One hook. <em>Every</em> commit clean.",
 "Cleans commits made by hand, from your IDE, or by any other AI tool. Keeps your existing hook.",
 term("~/demo", """<span class="d">$</span> bash scripts/install-hook.sh
<span class="d">•</span> existing hook moved to .git/hooks/commit-msg.local (it still runs)
<span class="g">✓ commit-msg hook installed in .git/hooks/commit-msg</span>

<span class="d"># later, a commit from Copilot in your IDE…</span>
<span class="d">$</span> git log -1 --format=%B
<span class="w">fix(ui): align modal buttons</span>
<span class="d"># Co-authored-by: Copilot — removed by the hook</span>"""))

# 6 — atomic
page("06-atomic-commits", "Atomic by default", "Mixed diff in. <em>Clean history</em> out.",
 "Unrelated changes are split into focused commits with a body that explains why.",
 '<div class="row">' +
 term("git status", """<span class="d">Changes not staged:</span>
  <span class="r">modified:</span>   src/auth.js
  <span class="r">modified:</span>   README.md

<span class="d">› commit my changes</span>""", 'style="flex:.8"') +
 term("result", """<span class="g">Made 2 commits · no push · no AI trailer</span>

<span class="w">feat(auth): validate user and add refresh</span>
  - login throws when no user is given
  - new refresh() renews the session token

<span class="w">docs(readme): add install instructions</span>""") + '</div>')

# logo
open(os.path.join(OUT, "logo.html"), "w").write("""<!doctype html><html><head><meta charset="utf-8"><style>
*{margin:0}body{width:512px;height:512px;background:#0b0f14;display:flex;align-items:center;justify-content:center}
</style></head><body><svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
<rect width="512" height="512" fill="#0b0f14"/>
<circle cx="256" cy="256" r="230" fill="#2bd48a" opacity=".07"/>
<line x1="176" y1="120" x2="176" y2="392" stroke="#2bd48a" stroke-width="18" stroke-linecap="round"/>
<circle cx="176" cy="130" r="36" fill="#0b0f14" stroke="#2bd48a" stroke-width="18"/>
<circle cx="176" cy="256" r="36" fill="#0b0f14" stroke="#2bd48a" stroke-width="18"/>
<circle cx="176" cy="382" r="36" fill="#2bd48a"/>
<text x="246" y="146" font-family="SF Mono,Menlo,monospace" font-weight="700" font-size="54" fill="#ffffff">feat:</text>
<text x="246" y="272" font-family="SF Mono,Menlo,monospace" font-weight="700" font-size="54" fill="#ffffff">fix:</text>
<g transform="translate(246,334)"><rect width="150" height="96" rx="20" fill="#ff6b6b" opacity=".14"/>
<text x="75" y="66" text-anchor="middle" font-family="-apple-system,Helvetica,sans-serif" font-weight="800" font-size="56" fill="#ff6b6b">AI</text>
<line x1="18" y1="82" x2="132" y2="14" stroke="#ff6b6b" stroke-width="12" stroke-linecap="round"/></g>
</svg></body></html>""")
print("ok")
