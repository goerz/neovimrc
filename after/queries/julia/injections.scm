;; extends

; Inject markdown in `@doc raw"""..."""` docstrings. Markdown injection in
; plain `"""..."""` docstrings (as well as `md"..."` strings) is already
; provided by the upstream query from nvim-treesitter.
((macrocall_expression
   (macro_identifier
     (identifier) @_macro)
   (macro_argument_list
     (prefixed_string_literal
       prefix: (identifier) @_prefix
       (content) @injection.content)))
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
  (#eq? @_macro "doc")
  (#eq? @_prefix "raw")
  (#set! injection.language "markdown"))
