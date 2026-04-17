# TGUI: instructions for translation editors (without programming)

This document is for those who edit interface texts, but do not write code.

## What you edit

Main file of the Russian interface:

- `tgui/packages/tgui/interfaces/locales/ui.*.ru.json`

English original (for meaning):

- `tgui/packages/tgui/interfaces/locales/ui.*.en.json`

Important:

- change only the text to the right of the key
- keys on the left (`"ui...."`) must not be renamed or deleted

## Basic line format

```json
"ui.example.key": "Translation text",
```

Where:

- `"ui.example.key"` — service key (do not touch)
- `"Translation text"` — your translation (can be changed)

## How to fix a bad translation

1. Find the problematic text in the game.
2. Find the corresponding key:

- if text of the form `ui.something.key` appears in the interface, that is the key
- if the key is not visible, ask a developer to provide the key

3. Open the matching `ui.*.ru.json` file and find the key with search (`Ctrl+F`).
4. Fix only the Russian value.
5. Save the file.

## What must not be done

- do not change the key name
- do not remove commas at the end of lines
- do not add comments (`// ...`) in JSON

## Translation quality: short checklist

Before saving, check:

1. The meaning matches the English line in the matching `ui.*.en.json`.
2. The text is natural for a Russian UI.
3. No translit and no encoding garbage.
4. No extra spaces at the beginning/end of the line.
5. Service placeholders are preserved, if present:

- `%s`, `{0}`, `{name}`, `{{value}}`, etc. (if they appear in the line)

## Frequent problems and how to fix them

1. You see `????` or `пїЅ...`:

- replace the line with normal Russian text by meaning from the matching `ui.*.en.json`

2. English is still left in Russian (`"Open"`, `"Status"`, ...):

- translate to Russian if this is not a brand/system name

3. Translation is too literal or awkward:

- rephrase naturally while preserving the original meaning. Make sure it currently looks inadequate before editing.

## How not to break the file

After edits:

1. Make sure the line is in the format:

- `"key": "value",`

2. Check error highlighting in the editor (VS Code shows JSON errors).
3. If there is a JSON error, most often the reason is:

- missing comma
- extra/missing quote
