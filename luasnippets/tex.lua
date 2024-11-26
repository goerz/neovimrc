local ls = require("luasnip")

local sn = ls.snippet_node
local c = ls.choice_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local rec_ls
rec_ls = function()
	return sn(
		nil,
		c(1, {
			-- Order is important, sn(...) first would cause infinite loop of expansion.
			t(""),
			sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
		})
	)
end

return {

  ls.snippet({trig="$", dscr="Inline math"},
    fmta("$<>$",
      { i(1) }
    )
  ),

  ls.snippet({trig="(", dscr="Parenthesis"},
    fmta("\\left(<>\\right)",
      { i(1) }
    )
  ),

  ls.snippet({trig="fr", dscr="Fraction"},
    fmta("\\frac{<>}{<>}",
      { i(1), i(2) }
    )
  ),

  ls.snippet({trig="ket", dscr="Ket"},
    fmta("\\ket{<>}",
      { i(1) }
    )
  ),

  ls.snippet({trig="it", dscr="Insert an itemize environment"},
    {
      t({ "\\begin{itemize}", "\t\\item " }),
      i(1),
      d(2, rec_ls, {}),
      t({ "", "\\end{itemize}" }),
    }),

  ls.snippet({trig="eq", dscr="Insert an equation"},
    fmta(
      [[
        \begin{equation}%
          \label{eq:<>}
          <>
        \end{equation}
      ]],
      { i(1), i(2) }
    )
  ),

  ls.snippet({trig="env", descr="Insert a custom environment"},
    fmta(
      [[
      \begin{<>}
        <>
      \end{<>}
      ]],
      { i(1), i(2), rep(1), }
    )
  ),

  ls.snippet({trig="fig", dscr="Insert an figure"},
    fmta(
      [[
        \begin{figure}[tb]
          \centering
          \includegraphics{<>}
          \caption{%
            <>
          }
          \label{fig:<>}
        \end{figure}
      ]],
      { i(1), i(2), i(3) }
    )
  ),

  ls.snippet({trig="table", dscr="Insert an table"},
    fmta(
      [[
        \begin{table}[tb]
          \centering
          \begin{tabular}{l|c|r}
            \toprule
            <>
            \midrule
            \bottomrule
          \end{tabular}
          \caption{%
            <>
          }
          \label{tab:<>}
        \end{table}
      ]],
      { i(1), i(2), i(3) }
    )
  ),

  ls.snippet({trig="c", descr="Insert a command"},
    fmta("\\<>{<>}",
      { i(1), i(2) }
    )
  ),

}
