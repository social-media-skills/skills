#!/usr/bin/env bash
# Validate the whole repo: skill structure, frontmatter, evals, cross-references,
# pack manifest, and banned claim patterns. Run before every commit/PR; CI runs it too.
# Usage: ./scripts/validate-skills.sh
set -uo pipefail
cd "$(dirname "$0")/.."

FAIL=0
err() { echo "  ✗ $1"; FAIL=1; }

echo "1/8 Skill structure (SKILL.md + references/ + evals/evals.json per skill)"
for d in skills/*/; do
  n=$(basename "$d")
  [ -f "$d/SKILL.md" ] || err "$n: missing SKILL.md"
  [ -d "$d/references" ] || err "$n: missing references/"
  [ -f "$d/evals/evals.json" ] || err "$n: missing evals/evals.json"
done

echo "2/8 Frontmatter (name matches directory, description present)"
for d in skills/*/; do
  n=$(basename "$d")
  fm=$(awk '/^name:/{print $2; exit}' "$d/SKILL.md" 2>/dev/null)
  [ "$fm" = "$n" ] || err "$n: frontmatter name '$fm' != directory name"
  grep -q '^description:' "$d/SKILL.md" || err "$n: missing description"
done

echo "3/8 Evals are valid JSON"
for f in skills/*/evals/evals.json; do
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null \
    || err "$f: invalid JSON"
done

echo "4/8 Cross-references resolve (every \`skill-name\` mention is a real skill)"
python3 - <<'EOF' || FAIL=1
import os, re, sys
# Backticked kebab-case terms that are NOT skill names (API fields, model ids, regions, packages).
ALLOW = {"platform-inputs", "gemini-3-pro-image", "lumaai-python", "x-goog-api-key",
         "asia-northeast1", "europe-west4", "us-central1", "us-east4"}
skills = {d for d in os.listdir("skills") if os.path.isdir(f"skills/{d}")}
pat = re.compile(r"`([a-z0-9]+(?:-[a-z0-9]+)+)`")
bad = []
roots = ["skills", "tools"]
for root in roots:
    for dirpath, _, files in os.walk(root):
        for f in files:
            if not f.endswith(".md"): continue
            p = os.path.join(dirpath, f)
            for m in pat.findall(open(p, encoding="utf-8").read()):
                if m not in skills and m not in ALLOW and not m.endswith(".md"):
                    bad.append(f"  ✗ {p}: unresolved reference `{m}`")
if bad:
    print("\n".join(sorted(set(bad)))); sys.exit(1)
EOF

echo "5/8 Description length (Agent Skills spec: max 1024 chars — claude.ai uploads enforce this)"
python3 - <<'EOF' || FAIL=1
import os, re, sys
bad = []
for d in sorted(os.listdir("skills")):
    p = f"skills/{d}/SKILL.md"
    if not os.path.isfile(p): continue
    text = open(p, encoding="utf-8").read()
    m = re.search(r'^description:\s*>-?\n((?:  .+\n)+)', text, re.M)
    if m:
        desc = " ".join(l.strip() for l in m.group(1).splitlines())
    else:
        m2 = re.search(r'^description:\s*(.+)$', text, re.M)
        desc = m2.group(1) if m2 else ""
    if len(desc) > 1024:
        bad.append(f"  ✗ {d}: description is {len(desc)} chars (max 1024)")
if bad:
    print("\n".join(bad)); sys.exit(1)
EOF

echo "6/8 Plugin manifests (valid JSON, versions in sync)"
python3 - <<'EOF' || FAIL=1
import json, sys
try:
    p = json.load(open(".claude-plugin/plugin.json"))["version"]
    m = json.load(open(".claude-plugin/marketplace.json"))["plugins"][0]["version"]
    g = json.load(open("gemini-extension.json"))["version"]
except Exception as e:
    print(f"  ✗ plugin manifest invalid: {e}"); sys.exit(1)
if not (p == m == g):
    print(f"  ✗ version mismatch: plugin.json={p} marketplace.json={m} gemini-extension.json={g}"
          " — bump all three (VERSIONS.md) or plugin/extension users won't see updates"); sys.exit(1)
EOF

echo "7/8 Pack manifest (every pack skill exists; JSON valid)"
python3 - <<'EOF' || FAIL=1
import json, os, sys
m = json.load(open("scripts/packs.json"))
bad = [f"  ✗ pack '{p['name']}': missing skill '{s}'"
       for p in m["packs"] for s in p["skills"] if not os.path.isdir(f"skills/{s}")]
for p in m["packs"]:
    for key in ("name", "title", "description", "skills"):
        if key not in p: bad.append(f"  ✗ pack '{p.get('name','?')}': missing '{key}'")
if bad: print("\n".join(bad)); sys.exit(1)
EOF

echo "8/8 Banned patterns (claims the repo must never make)"
# WoopSocial stores lifetime post analytics for one fixed platform list.
# Skills may say that. They must not deny the surface, and they must not
# name a different coverage list.
python3 - <<'EOF' || FAIL=1
import os, re, sys
bad = []
COVERED = "TikTok, LinkedIn, Facebook, Instagram, Pinterest, YouTube, and Bluesky"
DENY = (
    "has no analytics surface",
    "has NO analytics surface",
    "WoopSocial has no analytics",
    "WoopSocial has NO analytics",
    "WoopSocial has none",
    "no analytics yet",
    "has none yet",
    "does not measure",
    "doesn't measure",
)
roots = ["skills", "tools"]
paths = ["AGENTS.md", "CONTRIBUTING.md"]
for root in roots:
    for dirpath, _, files in os.walk(root):
        for f in files:
            if f.endswith((".md", ".json")):
                paths.append(os.path.join(dirpath, f))
for p in paths:
    raw = open(p, encoding="utf-8").read()
    # "Sets, doesn't measure" is about the goals skill, not WoopSocial.
    raw = raw.replace("Sets, doesn't measure", "Sets targets")
    text = re.sub(r"\s+", " ", raw)
    for phrase in DENY:
        if phrase in raw or phrase in text:
            bad.append(f"  ✗ {p}: stale denial {phrase!r}")
    for m in re.finditer(r"WoopSocial post analytics covers [^.]{0,200}", text):
        if COVERED not in m.group(0):
            bad.append(f"  ✗ {p}: coverage list is not the supported platforms")
if bad:
    print("\n".join(sorted(set(bad)))); sys.exit(1)
EOF
# No stale "(forthcoming)" markers for skills that ship in this repo.
hits=$(grep -rn "(forthcoming)" skills/ tools/ --include='*.md' 2>/dev/null | grep -v suno || true)
[ -z "$hits" ] || { echo "$hits"; err "found a stale (forthcoming) marker"; }

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "OK — $(ls -d skills/*/ | wc -l | tr -d ' ') skills validated."
else
  echo "FAILED — fix the issues above."
  exit 1
fi
