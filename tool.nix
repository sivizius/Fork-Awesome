 let
  inherit(builtins) concatMap elemAt filter foldl' head isString match readFile split genList;

  fileName = "/home/sivizius/Projects/Foreign/Fork-Awesome/src/icons/icons.yml";

  split' = regex: text: filter isString (split regex text);

  splitLines = split' "\n";
  lines = splitLines (readFile fileName);

  hexChars = filter (x: x!="") (split' "" "0123456789abcdef");
  getHex = elemAt hexChars;

  hexPairs = concatMap (x: genList (y: "${x}${getHex y}") 16) hexChars;
  codePoints = concatMap (xy: genList (z: "f${xy}${getHex z}") 16) hexPairs;

  hexPairs' = concatMap (x: genList (y: "${x}${getHex y}") 16) [ "0" "1" "2" "3" "4" "5" "6" "7" "8" ];
  codePoints' = concatMap (xy: genList (z: "${xy}${getHex z}") 16) hexPairs';

  nextCounter
  =   current:
      unicode:
        let
          expected = elemAt codePoints current;
        in
          if unicode == expected
          then
            current + 1
          else if unicode > expected
          then
            __trace "Skipped ${expected}"
            nextCounter (current + 1) unicode
          else
            __trace "Missing ${expected}"
            nextCounter (current - 1) unicode;

  state = foldl' (
      {
        aliases,
        categories,
        counter,
        created,
        filter,
        glyph,
        icons,
        id,
        unicode,
      } @ state:
      line:
        let
          aliasesLine     = match "^    aliases:$"                line;
          categoriesLine  = match "^    categories:$"             line;
          createdLine     = match "^    created: +(.*)$"          line;
          filterLine      = match "^    filter:$"                 line;
          glyphLine       = match "^    glyph: +(.*)$"            line;
          idLine          = match "^    id: +(.*)$"               line;
          itemLine        = match "^      - (.*)$"
          nameLine        = match "^  - name: +(.*)$"             line;
          unicodeLine     = match "^    unicode: +\"?(.{4})\"?$"  line;
          urlLine         = match "^    url: +(.*)$"              line;
        in
          if nameLine != null
          then
            if id != null
            then
              if !(__hasAttr unicode icons)
              then
              {
                icons
                =   icons
                //  {
                      ${unicode} = id;
                    };
                id = null;
                unicode = null;
                counter = nextCounter counter unicode;
              }
              else
                throw "\\u${unicode} duplicate: ›${id}‹ and ›${icons.${unicode}}‹"
            else
              state
          else if idLine != null then state // { id = head idLine; }
          else if unicodeLine != null then state // { unicode = head unicodeLine; }
          else state
    )
    {
      aliases     = [];
      categories  = [];
      counter     = 0;
      created     = null;
      filter      = [];
      glyph       = null;
      icons       = {};
      id          = null;
      unicode     = null;
      url         = null;
    }
    lines;
  icons = state.icons // { ${state.unicode} = state.id; };

  fontAwesomeOTF = "/nix/store/pjdmmaj5vx4vicmc6baafwx4pw3q27xi-font-awesome-6.1.1/share/fonts/opentype/";
  toHTMLpage
  = __trace (__concatStringsSep "\n" (
  [
    ""
    "<!DOCTYPE html>"
    "<html>"
    "  <head>"
    "    <title>Comparison between FontAwesome and ForkAwesome</title>"
    "    <style>"
    "      @font-face {"
    "        font-family: \"FontAwesomeBrands\";"
    "        src: url(${fontAwesomeOTF}Font%20Awesome%206%20Brands-Regular-400.otf) format(\"opentype\");"
    "      }"
    "      @font-face {"
    "        font-family: \"FontAwesomeRegular\";"
    "        src: url(${fontAwesomeOTF}Font%20Awesome%206%20Free-Regular-400.otf) format(\"opentype\");"
    "      }"
    "      @font-face {"
    "        font-family: \"FontAwesomeSolid\";"
    "        src: url(${fontAwesomeOTF}Font%20Awesome%206%20Free-Solid-900.otf) format(\"opentype\");"
    "      }"
    "      @font-face {"
    "        font-family: \"ForkAwesome\";"
    "        src: url(file:///home/sivizius/Projects/Foreign/Fork-Awesome/fonts/forkawesome-webfont.ttf) format(\"truetype\");"
    "      }"
    "      .font {"
    "        font-family: \"FontAwesomeRegular\", \"FontAwesomeBrands\", \"FontAwesomeSolid\";"
    "      }"
    "      .fork {"
    "        font-family: \"ForkAwesome\", \"Roboto\";"
    "      }"
    "    </style>"
    "  </head>"
    "  <body>"
    "    <table>"
    "     <tr>"
    "       <th>codepoint</th><th>id</th><th>fork</th><th>font</th>"
    "       <th>codepoint</th><th>id</th><th>fork</th><th>font</th>"
    "     </tr>"
  ]
  ++  (
        __concatMap
          (
            codePoint:
            [
              "     <tr>"
              "       <td>e${codePoint}</td>"
              "       <td>${icons."e${codePoint}" or "unknown-e${codePoint}"}</td>"
              "       <td class=\"fork\">${if icons ? "e${codePoint}" then "&#xe${codePoint};" else "?"}</td>"
              "       <td class=\"font\">&#xe${codePoint};</td>"

              "       <td>f${codePoint}</td>"
              "       <td>${icons."f${codePoint}" or "unknown-f${codePoint}"}</td>"
              "       <td class=\"fork\">${if icons ? "f${codePoint}" then "&#xf${codePoint};" else "?"}</td>"
              "       <td class=\"font\">&#xf${codePoint};</td>"
              "     </tr>"
            ]
          )
          codePoints'
      )
  ++  [
        "    </table>"
        "  </body>"
        "</html>"
      ]
  )) null;
in
  __mapAttrs (

    icon:
  )
  icons

  #__trace (__deepSeq codePoints codePoints) null
  # filter (unicode: !(__hasAttr unicode icons)) codePoints'
  /*__trace (__concatStringsSep "\n" (concatMap (codePoint: [
    "  - name:       FREE ${codePoint}"
    "    id:         ${codePoint}"
    "    unicode:    ${codePoint}"
    ""
  ]) codePoints')) null*/
#  __concatStringsSep "\n" (__attrValues (__mapAttrs (unicode: id: "\\u${unicode}: ${id}") icons))
