local M = {}

function M.align_to_mark(markname)
    local mark_pos = vim.api.nvim_buf_get_mark(0, markname) -- (row, col)
    local cur_pos = vim.api.nvim_win_get_cursor(0) -- (row, col)
    local mark_col = mark_pos[2]
    local cur_col = cur_pos[2]
    local diff = mark_col - cur_col
    if diff > 0 then
        local line = vim.api.nvim_get_current_line()
        local new_line = line:sub(1, cur_col) .. string.rep(' ', diff) .. line:sub(cur_col + 1)
        vim.api.nvim_set_current_line(new_line)
    end
end

return M
