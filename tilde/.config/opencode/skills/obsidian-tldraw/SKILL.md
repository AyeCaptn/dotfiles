---
name: Obsidian tldraw
description: Create and update tldraw diagrams as native .tldr files in the user's Obsidian vault through the file-based tldraw MCP server
---

# Obsidian tldraw workflow

Use this skill when the user asks to draw, diagram, visualize, or update a tldraw canvas in Obsidian.

## Storage and safety

- The MCP server root is `/Users/sem/Projects/Repos/obsidian-vault/Drawings`.
- Pass only relative `.tldr` paths to MCP tools. Never pass an absolute path or `..` segment.
- Prefer native `.tldr` files for agent-authored diagrams.
- The Obsidian plugin also has Markdown-wrapped drawings containing JSON between special marker lines. Do not edit those wrappers unless the user explicitly asks for it; changing the embedded block incorrectly can corrupt the note.
- Before creating a file, call `tldraw_list` and avoid overwriting an existing drawing unless requested.
- Preserve unrelated vault and Git changes.

## MCP tools

Use the `tldraw` server through Code Mode under `tools.tldraw`.

- `tldraw_create`: create an empty canvas.
- `tldraw_add_shape`: append one shape. Make sequential calls because each call rewrites the file.
- `tldraw_get_shapes` / `tldraw_read`: inspect existing content before changing it.
- `tldraw_update_shape` / `tldraw_delete_shape`: modify known shapes.
- `tldraw_write`: write a complete native tldraw document; prefer this for large diagrams so the update is atomic.
- `tldraw_list` / `tldraw_search`: discover canvases and text.

## Shape conventions

For labeled boxes, use `type: "geo"` with these properties:

```json
{
  "w": 420,
  "h": 180,
  "geo": "rectangle",
  "color": "blue",
  "labelColor": "black",
  "fill": "semi",
  "dash": "draw",
  "size": "m",
  "font": "draw",
  "align": "middle",
  "verticalAlign": "middle",
  "growY": 0,
  "url": "",
  "scale": 1,
  "richText": {
    "type": "doc",
    "content": [
      {
        "type": "paragraph",
        "attrs": { "dir": "auto" },
        "content": [{ "type": "text", "text": "Label" }]
      }
    ]
  }
}
```

Lay out shapes with explicit coordinates and generous spacing. Use consistent colors by category, short labels, section headers, and a separate orange review area for uncertain source material. Do not silently invent unreadable source text.

For diagrams with relationships or flows, make the connections explicit with arrows or short link labels. Use overview and detail pages when a single canvas would become crowded. Match labels and ordering from the source material, and flag anything uncertain rather than inventing details.

When writing complete tldraw documents, every generated shape must conform to the installed tldraw schema. In particular, geo shapes require `flipX` and `flipY` boolean properties, and page/shape `index` values must be valid fractional index keys. Validate the finished file against the current tldraw schema before opening it in Obsidian.

## Validation and opening

1. Verify the file with `tldraw_list` and `tldraw_get_shapes`.
2. Confirm the expected shape count and text.
3. Open it in Obsidian with:

```sh
open 'obsidian://open?vault=obsidian-vault&file=Drawings%2F<URL-encoded-file>.tldr'
```

4. Report the vault-relative path and any source ambiguities. The diagram appears in Obsidian, not inline in OpenCode.
