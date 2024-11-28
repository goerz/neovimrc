;; extends

; Disable spell-checking if there is no space after '#' in a comment.
; This includes Literate.jl line comments (#md, #nb, #src, etc)
((line_comment) @nospell
 (#match? @nospell "^#[^ ]"))
