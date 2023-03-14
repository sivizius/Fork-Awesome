#!/usr/bin/env python3

import json
import yaml
import operator

debug = False

def main():
  manifest = json.load(open("fontcustom-manifest-template.json", "r"))
  icons = yaml.safe_load(open("icons.yml", "r"))

  codepoints = {}
  for icon in sorted(icons.get("icons"), key=operator.itemgetter("id")):
    uid = icon.get("id")
    glyph = icon.get("glyph", uid)
    if glyph != uid and debug:
      print(f"{uid}: {glyph}")

    codepoint = int(icon.get("unicode"), base=16)
    prev_uid = codepoints.get(hex(codepoint), None)
    assert prev_uid == None, \
      f"Cannot assign {uid} to codepoint {hex(codepoint)}, because {prev_uid} was previously assigned"
    codepoints[hex(codepoint)] = uid

    source = f"svg/{glyph}.svg"
    if icon.get("created", None) == None:
      source = f"svg/placeholder.svg"
      if debug:
          print(f"Insert Placeholder for {uid} ({codepoint})")

    prev_glyph = manifest["glyphs"].get(uid, None)
    if prev_glyph == None:
      manifest["glyphs"][uid] = { "codepoint": codepoint, "source": source }
    else:
      prev_codepoint = prev_glyph["codepoint"]
      prev_source = prev_glyph["source"]
      assert prev_glyph == None, \
        f"Cannot assign glyph {hex(codepoint)} ({source}) to {uid}, because {hex(prev_codepoint)} ({prev_source}) was previously assigned"

  json.dump(manifest, open(".fontcustom-manifest.json","w"), indent=2)


if __name__ == "__main__":
  main()

