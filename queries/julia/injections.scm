; Inject markdown in plain docstrings
((string_literal) @injection.content
  .
  [
    (module_definition)
    (abstract_definition)
    (struct_definition)
    (function_definition)
    (macro_definition)
    (assignment)
    (const_statement)
  ]
  (#lua-match? @injection.content "^\"\"\"")
  (#set! injection.language "markdown")
  (#offset! @injection.content 0 3 0 -3))

; Inject markdown in raw docstrings
((macrocall_expression
   (macro_identifier
     (identifier) @macro-identifier
     (#eq? @macro-identifier "doc"))
   (macro_argument_list
     (prefixed_string_literal))) @injection.content
 .
 [
  (module_definition)
  (abstract_definition)
  (struct_definition)
  (function_definition)
  (macro_definition)
  (assignment)
  (const_statement)
  ]
 (#lua-match? @injection.content "^@doc raw\"\"\"")
 (#set! injection.language "markdown")
 (#set! injection.include-children true)
 (#offset! @injection.content 0 11 0 -3))

; Inject comments
([
  (line_comment)
  (block_comment)
] @injection.content
  (#set! injection.language "comment"))
