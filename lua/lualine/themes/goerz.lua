-- Copyright (c) 2024 Michael Goerz
-- stylua: ignore
local colors = {
  blue        = "#005fd7",
  orange      = "#ffaf00",
  lightorange = "#ff5f00",
  black       = "#000000",
  lightgray   = "#d0d0d0",
  darkgray    = "#444444",
  white       = "#ffffff",
}
-- TODO: dark theme

return {
  normal = {
    a = { bg = colors.blue,     fg = colors.white, gui = 'bold' },
    b = { bg = colors.darkgray, fg = colors.white, gui = 'bold' },
    c = { bg = colors.black,    fg = colors.white, gui = 'bold' },
  },
  insert = {
    a = { bg = colors.orange,      fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightorange, fg = colors.black, gui='bold' },
    c = { bg = colors.black,       fg = colors.white, gui='bold'},
  },
  visual = {
    a = { bg = colors.lightgray, fg = colors.black, gui = 'bold'},
    b = { bg = colors.darkgray,  fg = colors.white, gui= 'bold'},
    c = { bg = colors.black,     fg = colors.white, gui = 'bold'},
  },
  replace = {
    a = { bg = colors.orange,      fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightorange, fg = colors.black, gui='bold' },
    c = { bg = colors.black,       fg = colors.white, gui='bold'},
  },
  command = {
    a = { bg = colors.blue,     fg = colors.white, gui = 'bold' },
    b = { bg = colors.darkgray, fg = colors.white, gui = 'bold' },
    c = { bg = colors.black,    fg = colors.white, gui = 'bold' },
  },
  inactive = {
    a = { bg = colors.black, fg = colors.white, gui = 'bold' },
    b = { bg = colors.black, fg = colors.white, gui = 'bold' },
    c = { bg = colors.black, fg = colors.white, gui = 'bold' },
  },
}
