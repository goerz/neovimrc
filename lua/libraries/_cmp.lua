local M = {}

function M.toggle_autocomplete()
    -- TODO: Do we need to protect against `cmp` not being available?
    local cmp = require('cmp')
    -- lua vim.print(require('cmp').get_config().completion.autocomplete)
    local current_setting = cmp.get_config().completion.autocomplete
    if current_setting and #current_setting > 0 then
        cmp.setup({ completion = { autocomplete = false } })
    else
        cmp.setup({ completion = { autocomplete = { cmp.TriggerEvent.TextChanged } } })
    end
end

return M
