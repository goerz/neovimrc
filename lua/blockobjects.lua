local M = {}

-- In most files, the best definition of a "block" is lines separated by two or
-- more blank lines, or by a blank line and an unindented comment.
-- The `select_block` function defines a textobject
-- according to this specification. The "inner block" is the lines of the block
-- excluding blank lines. the "around block" includes the trailing empty lines,
-- but not leading empty lines. Assuming this file is saved as
-- `lua/blockobjects.lua` to set this up as text objects, use something like
--
--     vim.api.nvim_set_keymap('o', 'ib', [[:lua require('blockobjects').select_block(false)<CR>]], {noremap = true, silent = true})
--     vim.api.nvim_set_keymap('x', 'ib', [[:lua require('blockobjects').select_block(false)<CR>]], {noremap = true, silent = true})
--     vim.api.nvim_set_keymap('o', 'ab', [[:lua require('blockobjects').select_block(true)<CR>]], {noremap = true, silent = true})
--     vim.api.nvim_set_keymap('x', 'ab', [[:lua require('blockobjects').select_block(true)<CR>]], {noremap = true, silent = true})
--
-- This overrides the default definition of a "block" as something delimited by
-- parentheses.
--
-- For markdown files, the definition of a "block" is a fenced code block. If
-- there are no fenced code blocks below the current lines, it falls back to the
-- default block definition.
function M.select_block(include_end_block)
	local filetype = vim.bo.filetype
	local start_line, end_line
	if filetype == "markdown" then
		start_line, end_line = M.find_block_bounds_markdown(include_end_block)
	else
		start_line, end_line = M.find_block_bounds(include_end_block)
	end

	vim.fn.setpos(".", { 0, start_line, 1, 1, 1 }) -- Move to start of block
	vim.cmd("normal! V") -- Start line-wise visual mode
	vim.fn.setpos(".", { 0, end_line, 1, 1 }) -- Move to end of block
end

M.comment_marker = {
	markdown = nil,
	lua = "--",
	tex = "%",
}

function M._is_top_level_comment(line, linenr, filetype, comment_marker)
	if not comment_marker then
		comment_marker = "#"
		if M.comment_marker[filetype] then
			comment_marker = M.comment_marker[filetype]
		end
	end
	local is_comment = false
	if comment_marker then
		is_comment = line:sub(1, #comment_marker) == comment_marker
	end
	for _, group in ipairs(vim.treesitter.get_captures_at_pos(0, linenr, 1)) do
		-- Ignore comments inside strings. This happens, e.g., with section headers
		-- inside Julia docstrings
		if group.capture == "string" then
			is_comment = false
		end
	end
	return is_comment
end

function M.find_block_bounds(include_end_block)
	local start_line, end_line = nil, nil
	local current_line = vim.fn.line(".") -- Get the current cursor line
	local total_lines = vim.fn.line("$") -- Get total number of lines in buffer
	local current_line_content = vim.fn.getline(current_line)
	local filetype = vim.bo.filetype
	local is_block_delim = function(i1, i2, line1, line2)
		return line1 == "" and line2 == ""
	end
	if M._is_top_level_comment(current_line_content, current_line, filetype) then
		-- current line is a comment:
		-- delimit by single blank line
		is_block_delim = function(i1, i2, line1, line2)
			return line1 == "" and line2
		end
	else
		-- current line is a code line:
		-- delimit by two blank lines or blank line and comment line
		is_block_delim = function(i1, i2, line1, line2)
			local line2_is_comment = M._is_top_level_comment(line2, i2, filetype)
			local result = (line1 == "" and (line2 == "" or line2_is_comment))
			return result
		end
	end

	-- move up to find the start of the block
	for i = current_line - 1, 1, -1 do
		local line_content = vim.fn.getline(i)
		local prev_line_content = vim.fn.getline(i - 1)
		if is_block_delim(i, i - 1, line_content, prev_line_content) then
			start_line = i + 1
			break
		end
	end

	-- if not found, consider the start of the file as the start of the block
	start_line = start_line or 1

	-- move down to find end of block
	for i = current_line + 1, total_lines do
		local line_content = vim.fn.getline(i)
		local next_line_content = vim.fn.getline(i + 1)
		if is_block_delim(i, i + 1, line_content, next_line_content) then
			if include_end_block then
				-- Continue looping until a non-blank line or end of file
				while next_line_content == "" and i < total_lines do
					i = i + 1
					next_line_content = vim.fn.getline(i + 1)
				end
				end_line = i -- Include all blanks found
			else
				end_line = i - 1
			end
			break
		end
	end

	-- if not found, consider the end of the file as the end of the block
	end_line = end_line or total_lines

	return start_line, end_line
end

function M.find_block_bounds_markdown(include_end_block)
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	cursor_row = cursor_row - 1 -- Convert from 1-indexed to 0-indexed
	local query_string = [[
    ((code_fence_content) @block)
  ]]
	if include_end_block then
		query_string = [[
      ((fenced_code_block) @block)
    ]]
	end
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown")
	if not ok then
		vim.notify("Failed to get markdown parser", vim.log.levels.ERROR)
		return
	end
	local tree = parser:parse()[1]
	local root = tree:root()
	local ok_query, query = pcall(vim.treesitter.query.parse, "markdown", query_string)
	if not ok_query then
		vim.notify("Failed to parse query", vim.log.levels.ERROR)
		return
	end
	local first_line, last_line = nil, nil
	for _, node in query:iter_captures(root, bufnr, 0, -1) do
		local start_row, _, end_row, _ = node:range()
		if end_row >= cursor_row then
			first_line = start_row
			last_line = end_row
			break
		end
	end
	if first_line and last_line then
		-- Convert back to 1-indexed for Vim lines
		return first_line + 1, last_line
	else
		-- If not fenced code blocks, fall back to normal blocks
		return M.find_block_bounds(include_end_block)
	end
end

return M
