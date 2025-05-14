local M = {}

M.config = {
    severity = vim.diagnostic.severity.WARN,
    min_length = 5,
    ignore = { "Dechow", "Neovim" }
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

            if M.config.ignore[w] ~= nil then
                goto continue
            end

            local errors = vim.spell.check(w)
            for _, e in pairs(errors) do
                if e[2] == "bad" then
                    local i = word_map[w] or 0
                    word_map[w] = string.find(line, w, i)
                    local suggestions = vim.fn.spellsuggest(w);
                    local suggest = ""
                    if #suggestions >= 3 then
                        suggest = table.concat(suggestions, ", ", 1, 3)
                    else
                        if #suggestions > 0 then
                            suggest = table.concat(suggestions, ", ", 1, #suggestions)
                        end
                    end


                    diags[#diags + 1] = {
                        lnum = idx - 1,
                        col = word_map[w] - 1,
                        end_col = word_map[w] + string.len(w) - 1,
                        severity = M.config.severity,
                        message = "Possible misspelling: \""
                            .. e[1]
                            .. "\" (Maybe: "
                            .. suggest
                            .. ")"
                    }
                end
            end

            ::continue::
        end
    end

    vim.diagnostic.set(M.config.ns_id, bufn, diags)
end

function M.setup(user_config)
    local ns_id = vim.api.nvim_create_namespace("wurd_spel")
    M.config = vim.tbl_extend("force", M.config, user_config or {})
    M.config.ns_id = ns_id

    for _, val in pairs(M.config.ignore) do
        M.config.ignore[val] = true
    end

    vim.api.nvim_create_autocmd({ "TextChanged", "BufEnter", "BufWritePost" }, {
        pattern = { "*" },
        callback = function()
            if vim.api.nvim_buf_get_option(0, "modifiable") and vim.api.nvim_buf_get_name(0) ~= "" then
                M.spell_check_buffer()
            end
        end
    })
end

return M
