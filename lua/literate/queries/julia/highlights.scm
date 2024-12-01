;; extends

([("\n") (line_comment)]
 .
 ((line_comment) @literate-md)
 (#match? @literate-md "^# ")
 (#has-parent? @literate-md source_file)
)

(
 ((line_comment) @literate-md)
 (#match? @literate-md "^# #")
 (#has-parent? @literate-md source_file)
)

([("\n") (line_comment)]
 .
 ((block_comment) @literate-md)
 (#has-parent? @literate-md source_file)
)
