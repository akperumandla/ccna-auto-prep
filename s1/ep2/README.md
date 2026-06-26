# CCNA Automation Prep — Season 1, Episode 2: Data Formats (JSON, YAML, XML)

This is **Episode 2 of Season 1** of a CCNA Automation prep series. Episode 1 made
API calls and got **JSON** back. This episode steps back and looks at the three
data-serialization formats the CCNA Automation exam expects you to recognize and
interpret: **JSON**, **YAML**, and **XML**.

The goal isn't to memorize syntax — it's to see that **the same data structure**
can be written three different ways, and to understand what each format does (and
doesn't) preserve. We use one network-device document and convert it freely
between all three formats with [`yq`](https://github.com/mikefarah/yq).

> **Maps to CCNA Automation exam topics 1.1 and 1.2.** See the official
> [200-901 CCNAAUTO exam topics (PDF)](https://learningcontent.cisco.com/documents/marketing/exam-topics/200-901-CCNAAUTO_v.1.1.pdf).

---

## The big idea: same data, three encodings

Every one of these formats is just a way to write down two basic building blocks:

| Building block | JSON | YAML | XML |
|----------------|------|------|-----|
| **Object** (key/value map) | `{ "k": "v" }` | `k: v` | `<k>v</k>` |
| **Array** (ordered list) | `[ "a", "b" ]` | `- a`<br>`- b` | `<item>a</item>`<br>`<item>b</item>` |

If you can spot objects and arrays, you can read any of the three. The files in
this folder are the **same document** in each format so you can hold them
side-by-side and see exactly how each structure maps over.

---

## Prerequisites

| Tool | Why | Install |
|------|-----|---------|
| `yq` | Converts between JSON / YAML / XML (and is a `jq`-style query tool) | See [github.com/mikefarah/yq](https://github.com/mikefarah/yq#install) |

`yq` runs on **Linux, macOS, and Windows** — follow the install instructions for
your platform on the [project page](https://github.com/mikefarah/yq#install)
(Homebrew, apt, snap, winget, a downloadable binary, Docker, and more are all
listed there).

> **`yq` is not an exam topic.** You do **not** need to know `yq` for the CCNA
> Automation exam. We're only using it here as a convenient way to *show* the same
> data transformed from one format to another — the exam cares about recognizing
> and interpreting JSON, YAML, and XML, not about any particular conversion tool.

> **Which `yq`?** This episode uses **mikefarah's `yq`** (the Go version installed
> by Homebrew), confirmed with `yq --version` → `v4.x`. There is an unrelated
> Python tool also called `yq` that wraps `jq` and uses different flags. If your
> `yq --version` doesn't say `https://github.com/mikefarah/yq`, the commands below
> won't match.

---

## Files in this directory

| File | Format | Notes |
|------|--------|-------|
| [`device.json`](./device.json) | JSON | **The source of truth.** Hand-written; the other two are generated from it. |
| [`device.yaml`](./device.yaml) | YAML | Generated from the JSON with `yq`. A perfect, lossless round-trip. |
| [`device.xml`](./device.xml) | XML | Generated from the JSON with `yq`. Lossy in one interesting way — see below. |

All three describe a single switch, `core-sw-01`. The document was built
specifically to exercise every structure you'll be asked about:

- **Nested objects** — `device`, `device.location`, `device.snmp`.
- **An array of objects** — `device.interfaces` (three interfaces, each an object).
- **Arrays of scalars** — `device.dns_servers`, `device.tags`,
  `device.snmp.trap_receivers`.
- **Every scalar type** — string (`hostname`), integer (`uptime_days`), float
  (`temperature_celsius`), boolean (`managed`), and **null** (`interfaces[1].ip_address`,
  a shut port with no IP).

---

## The three formats, side by side

A single field, `device.location`, in each format:

**JSON** — braces for objects, brackets for arrays, quotes on every string, commas between items:
```json
"location": {
  "site": "HQ-Campus",
  "building": "B1",
  "floor": 3
}
```

**YAML** — indentation instead of braces, no quotes needed, no commas. `#` starts a comment:
```yaml
location:
  site: HQ-Campus
  building: B1
  floor: 3
```

**XML** — everything is an open/close tag pair; structure comes from nesting:
```xml
<location>
  <site>HQ-Campus</site>
  <building>B1</building>
  <floor>3</floor>
</location>
```

### How arrays look in each format

This is the part people trip on. The `tags` array:

```json
"tags": ["core", "distribution", "production"]
```
```yaml
tags:
  - core
  - distribution
  - production
```
```xml
<tags>core</tags>
<tags>distribution</tags>
<tags>production</tags>
```

JSON and YAML have **explicit** array syntax (`[]` / the `-` sequence). XML does
**not** — an array is just **the same tag repeated**. That has a real consequence:
in XML you can't tell a one-element array from a single value, because both look
like one tag. (JSON and YAML never have that ambiguity.)

---

## Converting between formats with `yq`

`yq` reads one format (`-p`, parse) and writes another (`-o`, output). The format
names are `json`, `yaml`, and `xml`.

```bash
# JSON  ->  YAML
yq -p json -o yaml device.json

# JSON  ->  XML
yq -p json -o xml  device.json

# YAML  ->  JSON
yq -p yaml -o json device.yaml

# XML   ->  YAML
yq -p xml  -o yaml device.xml
```

By default `yq` prints to your terminal. Redirect to a file to save the result —
this is exactly how `device.yaml` and `device.xml` in this folder were created:

```bash
yq -p json -o yaml device.json > device.yaml
yq -p json -o xml  device.json > device.xml
```

> **Tip:** `yq` treats YAML as its native format, so `-p yaml` is the default and
> can be omitted when the input is YAML. Being explicit with `-p`/`-o` is clearer
> while you're learning, so we always spell both out here.

### Proving equivalence (round-tripping)

A *round-trip* converts a file to another format and back, then checks that you
got the original. It's the cleanest way to *prove* two files hold the same data.

**JSON ↔ YAML is lossless.** Convert the YAML back to JSON and `diff` it against
the original — there is no difference:

```bash
yq -p yaml -o json device.yaml | diff - device.json && echo "IDENTICAL"
```

You can also just query the same path in each file and confirm you get the same
answer, regardless of format:

```bash
yq -p json '.device.interfaces[0].name' device.json   # GigabitEthernet1/0/1
yq -p yaml '.device.interfaces[0].name' device.yaml   # GigabitEthernet1/0/1
yq -p xml  '.device.interfaces[0].name' device.xml    # GigabitEthernet1/0/1
```

### The one big difference: XML has no types

Look at `managed` (a boolean) and `uptime_days` (a number) after a trip through XML:

```bash
yq -p xml -o json device.xml | yq '.device.managed, .device.uptime_days'
```

You get back the **strings** `"true"` and `"412"`, not a boolean and an integer.
That's not a `yq` bug — **XML has no native data types.** Everything between tags
is text, so `<managed>true</managed>` is indistinguishable from the word "true".
JSON and YAML both encode types directly (`true` vs `"true"`, `412` vs `"412"`),
which is a big reason modern APIs and automation tools (Ansible, NETCONF payloads,
REST bodies) lean on them. To get types back out of XML you need an external
schema (XSD) — the format alone can't tell you.

The same flattening happens to **null**: JSON's `"ip_address": null` becomes the
literal text `<ip_address>null</ip_address>` in XML, which round-trips back as the
string `"null"`. Another reminder that XML carries text, not meaning.

> **Takeaway for the exam:** JSON and YAML are *type-aware* and interchangeable;
> XML is *text-only* and needs a schema to recover types and to distinguish a
> single value from a one-item list.

---

## Quick reference: format cheat sheet

| Question | JSON | YAML | XML |
|----------|------|------|-----|
| Where's it used in networking? | REST API bodies, most modern APIs | Ansible playbooks, config files, CI pipelines | NETCONF, older SOAP APIs, some IOS-XE/XR payloads |
| Comments allowed? | **No** | Yes (`#`) | Yes (`<!-- -->`) |
| Native data types? | Yes | Yes | No (text only) |
| How is structure shown? | `{}` and `[]` | Indentation + `-` | Nested tags |
| Human-friendliest to write? | Medium | Easiest | Hardest (verbose) |
| Array of one item is unambiguous? | Yes | Yes | **No** |

---

## VSCode extensions

These extensions make the JSON / YAML / XML files in this episode easier to read,
edit, and validate. JSON support is **built in** to VSCode (formatting, syntax
highlighting, and schema validation), so the add-ons below cover YAML and XML.

| Extension | Marketplace ID | What it gives you |
|-----------|----------------|-------------------|
| **YAML** (Red Hat) | [`redhat.vscode-yaml`](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) | YAML formatting, linting (catches indentation mistakes as you type), auto-completion, and schema validation. |
| **XML** (Red Hat) | [`redhat.vscode-xml`](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-xml) | XML formatting, syntax checking (well-formedness), auto-completion, and validation against DTD/XSD schemas. |
| **Cursor Ruler** | [`freakone.cursoruler`](https://marketplace.visualstudio.com/items?itemName=freakone.cursoruler) | Draws a vertical ruler aligned to your cursor's column — a general editing aid that makes lining up indented YAML and nested XML easier to eyeball. |

Install from the VSCode **Extensions** view (`Cmd`/`Ctrl`+`Shift`+`X`) by searching
the name, or from the command line:

```bash
code --install-extension redhat.vscode-yaml
code --install-extension redhat.vscode-xml
code --install-extension freakone.cursoruler
```

> Versions used while recording this episode: `redhat.vscode-xml@0.29.3`,
> `redhat.vscode-yaml@1.23.0`, `freakone.cursoruler@0.0.4`. Newer versions should
> work the same way.

---

## Online tools

Prefer not to install anything? These web-based tools format, validate, and
convert between JSON, YAML, and XML right in the browser — handy for a quick check
or a one-off conversion without `yq` or VSCode.

> **Heads-up:** Online tools mean **pasting your data into a third-party website**.
> Fine for the practice data in this episode, but never paste real device configs,
> credentials, or anything sensitive into a public web tool.

### JSON

| Tool | What it does |
|------|--------------|
| [jsonlint.com](https://jsonlint.com) | Validate JSON (reports errors), format/beautify, and minify. Also converts JSON to CSV/YAML/XML and offers a diff, tree viewer, and schema validator. |
| [jsonformatter.org](https://jsonformatter.org) | Validate (with line-numbered errors), beautify with configurable indentation, minify, tree/graph views, and convert JSON ↔ XML/CSV/YAML. |

### YAML

| Tool | What it does |
|------|--------------|
| [yamllint.com](https://www.yamllint.com) | Simple, focused YAML validator: paste YAML and it tells you if it's valid. Also reformats to clean UTF-8 (strips comments) and can resolve aliases. |
| [jsonformatter.org/yaml-validator](https://jsonformatter.org/yaml-validator) | Validate and beautify YAML, with conversion to JSON/XML/CSV. Loads from file or URL. |
| [codebeautify.org/yaml-validator](https://codebeautify.org/yaml-validator) | Validate/lint YAML and view it structured. Companion converters for YAML → JSON/XML/CSV. Accepts paste, file, or URL. |

### XML

| Tool | What it does |
|------|--------------|
| [xmlformatter.org](https://xmlformatter.org) | Format/beautify XML, validate against the W3C spec with color-coded errors, minify, tree view, and convert XML to JSON/CSV. |
| [codebeautify.org/xmlvalidator](https://codebeautify.org/xmlvalidator) | Validate XML for well-formedness and validity with clear error messages (handles SOAP/WSDL/RSS/SVG and more). Accepts paste, file, or URL. |

### All-in-one

| Tool | What it does |
|------|--------------|
| [codebeautify.org](https://codebeautify.org) | A large toolbox of formatters, validators, and converters covering JSON, YAML, XML, CSV and many others — a single site for round-tripping between all three formats in this episode. |
