local ls = require("luasnip")
local t = ls.text_node

return {
  -- A snippet that expands the trigger "hi" into the string "Hello, world!".
  ls.snippet(
    { trig = "hi" },
    { t("Hello, world!") }
  ),

}
