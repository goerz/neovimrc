; TODO: inject docstrings, but with a custom markdown variant
; Inject comments
([
  (line_comment)
  (block_comment)
] @injection.content
  (#set! injection.language "comment"))
