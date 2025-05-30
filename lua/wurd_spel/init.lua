---@diagnostic disable: undefined-global

local M = {
    attached_bufs = {}
}

M.config = {
    severity = vim.diagnostic.severity.WARN,
    min_length = 5,
    ignore = { "Dechow", "Neovim" }
}

function M.check_string_content(bufn, content, offset)
    local diagnostics = {}

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


                    diagnostics[#diagnostics + 1] = {
                        lnum = idx - 1 + offset,
                        col = word_map[w] - 1,
                        end_col = word_map[w] + string.len(w) - 1,
                        severity = M.config.severity,
                        message = "Possible misspelling: \""
                            .. e[1]
                            .. "\" (Maybe: "
                            .. suggest
                            .. ")"
                    }

                    word_map[w] = word_map[w] + 1
                end
            end

            ::continue::
        end
    end

    local old = vim.diagnostic.get(bufn, { namespace = M.config.ns_id });
    local new_set = {}
    for _, diag in pairs(old) do
        if diag.lnum < offset or diag.lnum > offset + #content - 1 then
            new_set[#new_set + 1] = diag
        end
    end

    for _, diag in pairs(diagnostics) do
        new_set[#new_set + 1] = diag
    end

    vim.diagnostic.set(M.config.ns_id, bufn, new_set)
end

function M.spell_check_buffer()
    local bufn = vim.api.nvim_get_current_buf()
    local content = vim.api.nvim_buf_get_lines(bufn, 0, vim.api.nvim_buf_line_count(0), false)
    M.check_string_content(bufn, content, 0)
end

function M.setup(user_config)
    local ns_id = vim.api.nvim_create_namespace("wurd_spel")
    M.config = vim.tbl_extend("force", M.config, user_config or {})
    M.config.ns_id = ns_id

    for _, val in pairs(M.config.ignore) do
        M.config.ignore[val] = true
    end

    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*" },
        callback = function()
            local bufn = vim.api.nvim_get_current_buf()
            if vim.api.nvim_buf_get_option(0, "modifiable") and vim.api.nvim_buf_get_name(0) ~= "" then
                if M.attached_bufs[bufn] == nil then
                    M.attached_bufs[bufn] = true

                    vim.api.nvim_buf_attach(0, false, {
                        on_lines = function(_, buf, _, first, last, new_last, _)
                            local lines = vim.api.nvim_buf_get_lines(buf, first, new_last, false)
                            M.check_string_content(bufn, lines, first)
                        end
                    })
                end

                M.spell_check_buffer()
            end
        end
    })

    vim.api.nvim_create_autocmd("BufUnload", {
        callback = function(args)
            M.attached_bufs[args.buf] = nil
        end
    })
end

return M
