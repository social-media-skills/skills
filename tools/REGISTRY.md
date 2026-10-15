# Tools Registry

Index of agent-usable integrations. Bridge skills read this to find the right tool, then follow
the linked integration guide. Add a row + an `integrations/<name>.md` to contribute a tool — the
fastest path to a useful PR.

The pattern across the whole stack: **a creative tool generates or edits the asset; a human
reviews it; the finished asset is uploaded to WoopSocial's Media domain and published or
scheduled via `scheduling-and-queue`.** No creative tool publishes directly, and WoopSocial
doesn't generate or edit media.

## Publishing / scheduling (the bridge)

| Tool | Domain | Auth | Capabilities | Guide |
|---|---|---|---|---|
| WoopSocial | Social publishing/scheduling + post analytics | OAuth + API key | Projects · Social Accounts · Posts (create/list/read/validate/delete, with lifetime post analytics) · Media · Webhooks · Health | `integrations/woopsocial.md` |

## Research & evidence

| Tool | Auth | Capabilities | Guide |
|---|---|---|---|
| Jev Social | Existing Chrome session + Jev decision provider | Instagram, TikTok, and LinkedIn search · selected profile/post/comment reads · source-linked reports · explicit partial/gate status | `integrations/jev-social.md` |

## Image generation & editing

| Tool | Skill | Capabilities | Guide |
|---|---|---|---|
| Nano Banana (Gemini Image) | `nano-banana` | Text-to-image · legible in-image text · multi-image composition & brand consistency · editing · up to 4K · **SynthID watermark** | `integrations/nano-banana.md` |
| Ideogram | `ideogram` | Best-in-class **legible in-image text** · bounding-box layout control · style references · editing | `integrations/ideogram.md` |
| FLUX (Black Forest Labs) | `flux` | Photoreal generation · **in-context editing** · reference consistency · open + API variants | `integrations/flux.md` |
| AI image editing (routing layer) | `ai-image-editing` | Task-first routing: inpainting · background removal · upscaling · expand · restoration | `integrations/ai-image-editing.md` |

## Video generation

| Tool | Skill | Capabilities | Guide |
|---|---|---|---|
| Veo (Google) | `veo-3` | 8s clips · **native audio** · 9:16 & 16:9 · up to 4K · extension · character consistency · **SynthID watermark** | `integrations/veo.md` |
| Kling | `kling` | 4K · **multi-shot** · motion transfer · image-to-video | `integrations/kling.md` |
| Luma Dream Machine | `luma` | Cinematic shots (Ray3) · image-to-video · footage restyling | `integrations/luma.md` |
| Runway | `runway` | **Control-grade** generation (Gen-4.5, 2–10s) · Aleph editing · references/consistency | `integrations/runway.md` |
| HeyGen | `heygen` | **Avatar / talking-head** video · voice clone · localization | `integrations/heygen.md` |
| Synthesia | `synthesia` | Enterprise avatar video (Express-2) · training/explainers · localization at scale | `integrations/synthesia.md` |

*Router: the `ai-video` skill picks the right video tool for the brief.*

## Audio: voice, music & sound

| Tool | Skill | Capabilities | Guide |
|---|---|---|---|
| ElevenLabs | `ai-voiceover` | AI voiceover · narration · dubbing · voice design | `integrations/elevenlabs.md` |
| Suno | `suno` | AI music (v5.5 + Studio) · brand themes, stings, jingles · **licensing is legally live — verify** | `integrations/suno.md` |
| AI music + sound (routing layer) | `ai-music-and-sound` | Tool + **license/litigation** layer across music tools | `integrations/ai-music-and-sound.md` |

## Editing, clipping & design

| Tool | Skill | Capabilities | Guide |
|---|---|---|---|
| CapCut | `capcut` | Short-form video editing · captions · pacing (TikTok/Reels/Shorts) | `integrations/capcut.md` |
| Descript | `descript` | **Text-based** editing for talk content (podcasts, interviews, talking-head) · public API + MCP (2026 open beta) | `integrations/descript.md` |
| OpusClip | `opus-clip` | AI clip-finding: long video → short-clip candidates | `integrations/opus-clip.md` |
| Clipping + captions (multi-tool) | `captions-and-clipping` | Connection layer across Opus Clip, CapCut, Submagic | `integrations/clipping.md` |
| Canva | `canva` | Brand-aware design at scale (editor · Sheets · Code · Video 2.0 · Affinity) | `integrations/canva.md` |

## Conventions every guide follows

- **Three layers:** `tools/integrations/<name>.md` (connection/API/plan facts) → the tool's
  mini-skill in `skills/<name>/` (the craft) → a router skill (`ai-video`, `image-prompt`,
  `ai-music-and-sound`, `ai-image-editing`) that picks the tool for the job.
- **verify-quarterly:** pricing, tiers, gates, and legal terms in these guides are volatile.
  Re-verify against the tool's live docs before relying on them.
- **Human in the loop:** the agent drafts/generates; a human judges the output; only then does
  it publish — via WoopSocial, with explicit confirmation.
- **Disclosure:** AI-generated media follows the brand's AI-disclosure rules (WoopSocial handles
  TikTok's automatic AI-disclosure; note it elsewhere per `brand-profile`).
