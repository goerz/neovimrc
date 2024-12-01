;; extends

(
  (line_comment)
  @injection.content
  (#lua-match? @injection.content "^# ")
  (#has-parent? @injection.content source_file)
  (#set! injection.language "markdown")
  (#offset! @injection.content 0 2 0 0)
)

(
  (block_comment)
  @injection.content
  (#has-parent? @injection.content source_file)
  (#set! injection.language "markdown")
  (#offset! @injection.content 0 2 0 2)
)
