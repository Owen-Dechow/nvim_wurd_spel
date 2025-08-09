# nvim_wurd_spel

Those of us who use Neovim but cannot spell spend entirely too much time fighting with
ourselves and not enough time fighting our code. Neovim's built in spelling system is ok,
but it lacks some features that I would like to see. This becomes more evident when you
are using Treesitter. Most of the time only strings and comments get checked for spelling,
and spelling issues show up as a little line instead of a real warning or info bar.
WurdSpel works to fix this by running spell check on everything, not just comments. This
means that for the few of us that can even spell our variable names right, we are saved!
In addition it adds the ability to easily have workspace settings for specific
projects. WurdSpel also makes spelling errors warnings (this can be changed if
you aren't as bad as spelling as me). To the spelling failures amongst us, I
present `WurdSpel`.

https://github.com/user-attachments/assets/f1d1930d-0fd4-49ee-9b48-6177d29c7382

## User Commands

WurdSpel Adds the `WurdSpel [subcommand]` user command. The possible subcommands are
defined as follows:

`suggest`

    Gives spelling suggestions and the option to add the misspelled word to user settings.

`good`

    Adds the misspelled word to user settings.

`goodlocal`

    Adds the misspelled word to workspace settings.


`bad`

    Marks the word under the cursor as misspelled.

`badlocal`

    Marks the word under the cursor as misspelled in workspace.

`buf`

    Runs a spell check over entire buffer.

`toggle`

    Enables or disables WurdSpel.

`openspellfile`

    Opens the spell add file.

## Installation

[lazy.nvim](https://github.com/folke/lazy.nvim) - Default config is commented out.
```lua
return {
    "Owen-Dechow/nvim_wurd_spel",
    opts = {
        -- severity = vim.diagnostic.severity.INFO,
        -- -- Set the severity level of spelling errors:
        --     INFO, WARN, or ERROR.

        -- min_length = 5,
        -- -- Set the minimum length of word to be checked.

        -- ignore = { "Dechow", "Neovim" }
        -- -- Add words to be ignored.
        -- -- IMPORTENT: words added to Neovim's built in
        --     spelling ignore dictionary are still ignored.`
        --     It is suggested to add words to that dictionary
        --     using `zg` or the
        --     `:WurdSpel suggest` options instead of adding
        --     words here.

        -- enabled = true
        -- -- Enable WurdSpel on start.

        -- workspace_spell = ".spell/en.utf8.add",
        -- -- Set the path of workspace spell file

        -- global_spell = nil,
        -- -- Set the path of your user spell file
        -- -- If `nil` it will take on the default
        --     spellfile of your neovim config.
        --    It is highly suggested to leave as `nil`.

        -- remap = true
        -- -- Remap the builtin z=, zg, & zw commands to the
        --     WurdSpel command equivalents:
        --     z= -> WurdSpel suggest
        --     zg -> WurdSpel good
        --     zw -> WurdSpel bad

        -- remap_special = false
        -- -- Add special remaps:
        --     <leader>zz -> WurdSpel suggest
        --     <leader>zg -> WurdSpel good
        --     <leader>zw -> WurdSpel bad

        -- buf_option_guards = {
        --    modifiable = true,
        --    buftype = "",
        -- }
        -- -- These checks determine if the spellchecker will be
        --     attached to the buffer. The value will be gotten
        --     using `nvim_buf_get_option(0, ...)`.
        -- -- If the result of
        --     `nvim_buf_get_option` is not equal to the specified
        --     value in the table then the spellchecker will not
        --     attach.

        -- pattern = { "*" },
        -- -- Pattern for auto commands.

        -- allow_one_letter_prefix = true
        -- -- Allow one letter prefix on words:
        --     `ilocal` -> correct because local is correct.
        -- -- If this setting is false:
        --     `ilocal` -> incorrect because ilocal is not a word.

        -- num_options = 5,
        -- -- Set the maximum number of options in the spell
        --     suggest menu.

        -- add_to_settings_in_suggest = true,
        -- -- Add the `[Add to user settings]` option in the
        --     spell suggest menu.

        -- add_to_settings_at_end = true,
        -- -- Control the location of the `[Add to user settings]`
        --     option in the spell suggest menu.
        -- -- If this setting is true `[Add to user settings]` will
        --     be at the end.
        -- -- If this setting is false `[Add to user settings]` will
        --     be at the start.

        -- message_prefix = "(zz) "
        -- -- Adds a prefix to the "Possible misspelling ..." error
        --     message.
        -- -- You may use any string value for this option.
        -- -- Examples:
        --     "(zz) " ->  "(zz) Possible misspelling..."
        --     ""      ->  "Possible misspelling..."
    }
}
```

> [!NOTE]
> This plugin will not set anything up unless you run the `setup` function.
> In lazy.nvim this is done automatically if you have the opts option. If
> you are using a different plugin manager you must ensure that `setup` is
> run.

