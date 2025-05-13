local ns_id = vim.api.nvim_create_namespace("SPELL CHECKER")
local M = {}

M.config = {
    severity = vim.diagnostic.severity.INFO,
    min_length = 5,
}

function M.spell_check_buffer()
    local diags = {}
    local bufn = vim.api.nvim_get_current_buf()
    local content = vim.api.nvim_buf_get_lines(bufn, 0, vim.api.nvim_buf_line_count(0), false)
    for idx, line in pairs(content) do
        local word_map = {}
        for w in string.gmatch(line, "[A-Z]?[a-z]+") do
            if string.len(w) < M.config.min_length then
                goto continue
            end

            local errors = vim.spell.check(w)
            for _, e in pairs(errors) do
                if e[2] == "bad" then
                    local i = word_map[w] or 0
                    word_map[w] = string.find(line, w, i)

                    diags[#diags + 1] = {
                        lnum = idx - 1,
                        col = word_map[w] - 1,
                        end_col = word_map[w] + string.len(w) - 1,
                        severity = M.config.severity,
                        message = "Possible misspelling: \""
                            .. e[1]
                            .. "\" (Maybe: "
                            .. table.concat(vim.fn.spellsuggest(w), ", ", 1, 3)
                            .. ")"
                    }
                end
            end
        end

        ::continue::
    end

    vim.diagnostic.set(ns_id, bufn, diags)
end

function M.setup(user_config)
    M.config = vim.tbl_extend("force", M.config, user_config or {})


    vim.api.nvim_create_autocmd({ "TextChanged", "BufEnter" }, {
        pattern = "*",
        callback = M.spell_check_buffer()
    })
end

return M
