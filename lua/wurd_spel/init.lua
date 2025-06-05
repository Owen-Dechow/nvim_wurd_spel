---@diagnostic disable: undefined-global

local M = {
    attached_bufs = {},
}

M.config = {
    severity = vim.diagnostic.severity.INFO,
    min_length = 5,
    ignore = { "Dechow", "Neovim" },
    enabled = true,
    remap = true,
    remap_special = false,
    allow_one_letter_prefix = true,
    buf_option_guards = {
        modifiable = true,
        buftype = "",
    },
    pattern = { "*" },
    ns_id = nil,
}

local function get_diagnostic_for_namespace(namespace_id)
    local pos = vim.api.nvim_win_get_cursor(0)
    local line = pos[1] - 1
    local col = pos[2]

    local diagnostics = vim.diagnostic.get(0, { namespace = namespace_id, lnum = line })
    for _, diag in ipairs(diagnostics) do
        if col >= diag.col and col <= diag.end_col then
            print(namespace_id, diag.namespace)
            return diag
        end
    end
end

local function get_word_under_cursor()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local bufn = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_buf_get_lines(bufn, cursor_pos[1] - 1, cursor_pos[1], false)[1]
    local word_map = {}

    for w in string.gmatch(line, "[A-Z]?[a-z]+") do
        local i = word_map[w] or 0
        word_map[w] = string.find(line, w, i)

        if word_map[w] - 1 <= cursor_pos[2] and word_map[w] - 1 + string.len(w) > cursor_pos[2] then
            return w
        end

        word_map[w] = word_map[w] + 1
    end
end

function M.check_string_content(bufn, content, offset, move)
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
                    if M.config.allow_one_letter_prefix then
                        local bad = false
                        for _, e2 in pairs(vim.spell.check(string.sub(w, 2))) do
                            if e2[2] == "bad" then
                                bad = true
                            end
                        end

                        if not bad then
                            goto continue
                        end
                    end

                    local i = word_map[w] or 0
                    word_map[w] = string.find(line, w, i)

                    diagnostics[#diagnostics + 1] = {
                        lnum = idx - 1 + offset,
                        col = word_map[w] - 1,
                        end_col = word_map[w] + string.len(w) - 1,
                        severity = M.config.severity,
                        message = "Possible misspelling: \"" .. w .. "\".",
                        word = w
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
        if diag.lnum < offset or diag.lnum > offset + move then
            if diag.lnum >= offset then
                diag.lnum = diag.lnum - move
                diag.end_lnum = diag.end_lnum - move
            end

            if diag.lnum < offset or diag.lnum > offset + #content - 1 then
                new_set[#new_set + 1] = diag
            end
        end
    end

    for _, diag in pairs(diagnostics) do
        new_set[#new_set + 1] = diag
    end

    vim.diagnostic.set(M.config.ns_id, bufn, new_set)
    vim.defer_fn(vim.diagnostic.show, 0)
end

function M.spell_check_buffer()
    local bufn = vim.api.nvim_get_current_buf()
    local content = vim.api.nvim_buf_get_lines(bufn, 0, vim.api.nvim_buf_line_count(0), false)
    M.check_string_content(bufn, content, 0, 0)
end

function M.spellbad()
    local w = get_word_under_cursor()
    if w then
        vim.cmd("spellwrong " .. w)
        M.spell_check_buffer()
    else
        vim.notify("No word under cursor.")
    end
end

function M.spellgood()
    local diag = get_diagnostic_for_namespace(M.config.ns_id)
    if diag and diag.word then
        vim.cmd("spellgood " .. diag.word)
    else
        local w = get_word_under_cursor()
        if w == nil then
            vim.notify("No WurdSpel diagnostic or word under cursor.")
            return
        end

        local answer = vim.fn.confirm(
            "No diagnostic existed under cursor. Do you want to add \""
            .. w
            .. "\" instead?",
            "&Yes\n&No",
            2
        )

        if answer ~= 1 then
            return
        end
        vim.cmd("spellgood " .. w)
    end

    M.spell_check_buffer()
end

function M.spellsuggest()
    local diag = get_diagnostic_for_namespace(M.config.ns_id)
    if diag then
        local suggestions = vim.fn.spellsuggest(diag.word);
        local add_to_list = "[Add to user settings]"
        table.insert(suggestions, 1, add_to_list)
        vim.print(diag)
        vim.ui.select(suggestions, { prompt = "WurdSpelSuggest for " .. diag.word }, function(selected)
            if selected then
                if selected == add_to_list then
                    vim.cmd("spellgood " .. diag.word)
                    M.spell_check_buffer()
                else
                    local bufn = vim.api.nvim_get_current_buf()
                    vim.api.nvim_buf_set_text(bufn, diag.lnum, diag.col, diag.lnum,
                        diag.end_col, { selected })
                end
            end
        end)
    else
        vim.notify("No WurdSpel diagnostic under cursor.")
    end
end

function M.toggle()
    M.config.enabled = not M.config.enabled
    if M.config.enabled then
        M.spell_check_buffer()
    else
        vim.diagnostic.reset(M.config.ns_id)
    end
end

function M.openspellfile()
    vim.cmd("edit " .. vim.fn.stdpath("config") .. "/spell/en.utf-8.add")
end

local function def_commands()
    local cmds = {
        buf = M.spell_check_buffer,
        toggle = M.toggle,
        good = M.spellgood,
        bad = M.spellbad,
        suggest = M.spellsuggest,
        openspellfile = M.openspellfile
    }

    local completions = {}
    for key, _ in pairs(cmds) do
        completions[#completions + 1] = key
    end

    vim.api.nvim_create_user_command(
        "WurdSpel",
        function(opts)
            local cmd = opts.args

            if cmds[cmd] == nil then
                vim.notify(cmd .. " is not a valid WurdSpel command", vim.log.levels.ERROR)
            else
                cmds[cmd]()
            end
        end,
        {
            nargs = 1,
            complete = function(_, _, _)
                return completions
            end
        }
    )

    if M.config.remap then
        vim.keymap.set("n", "z=", M.spellsuggest)
        vim.keymap.set("n", "zg", M.spellgood)
        vim.keymap.set("n", "zw", M.spellbad)
    end

    if M.config.remap_special then
        vim.keymap.set("n", "<leader>zz", M.spellsuggest)
        vim.keymap.set("n", "<leader>zw", M.spellbad)
        vim.keymap.set("n", "<leader>zg", M.spellgood)
    end
end

function M.setup(user_config)
    def_commands()

    local ns_id = vim.api.nvim_create_namespace("wurd_spel")
    M.config = vim.tbl_extend("force", M.config, user_config or {})
    M.config.ns_id = ns_id

    for _, val in pairs(M.config.ignore) do
        M.config.ignore[val] = true
    end

    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = M.config.pattern,
        callback = function()
            local bufn = vim.api.nvim_get_current_buf()

            for key, val in pairs(M.config.buf_option_guards) do
                if not (vim.api.nvim_buf_get_option(0, key) == val) then
                    return
                end
            end

            if M.attached_bufs[bufn] ~= nil then
                return
            end

            M.attached_bufs[bufn] = true
            vim.api.nvim_buf_attach(bufn, false, {
                on_lines = function(_, buf, _, first, last, new_last, _)
                    local move = last - new_last
                    if M.config.enabled then
                        local lines = vim.api.nvim_buf_get_lines(buf, first, new_last, false)
                        M.check_string_content(bufn, lines, first, move)
                    end
                end
            })

            if M.config.enabled then
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
