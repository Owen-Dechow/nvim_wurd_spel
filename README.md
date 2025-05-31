# nvim_wurd_spel

Those of us who use Neovim but cannot spell spend entirely too much time fighting with
ourselves and not enough time fighting our code. Neovim's built in spelling system is ok,
but it lacks some features that I would like to see. This becomes more evident when you
are using Treesitter. Most of the time only strings and comments get checked for spelling,
and spelling issues show up as a little line instead of a real warning or info bar.
WurdSpel works to fix this by running spell check on everything, not just comments. This
means that for the few of us that can even spell our variable names right, we are saved!
WurdSpel also makes spelling errors warnings (this can be changed if you aren't as bad as
spelling as me). To the spelling failures amongst us, I present `nvim_wurd_spel`.


https://github.com/user-attachments/assets/f1d1930d-0fd4-49ee-9b48-6177d29c7382


## User Commands

WurdSpel Adds the following user commands

`WurdSpelSuggest`

    Gives spelling suggestions and the option to add the misspelled word to user settings.

`WurdSpelGood`

    Adds the misspelled word to user settings.

`WurdSpelBad`

    Marks the word under the cursor as misspelled.

`WurdSpelBuf`

    Runs a spell check over entire buffer.

`WurdSpelToggle`

    Enables or disables WurdSpel.

## Installation

[lazy.nvim](https://github.com/folke/lazy.nvim) - Default config is commented out.
```lua
return {
    "Owen-Dechow/nvim_wurd_spel",
    config = function()
        require("wurd_spel").setup({
            -- severity = vim.diagnostic.severity.INFO,
            -- -- Set the severity level of spelling errors
            -- -- INFO, WARN, ERROR

            -- min_length = 5,
            -- -- Set the minimum length of word to be checked

            -- ignore = { "Dechow", "Neovim" }
            -- -- Add words to be ignored
            -- -- IMPORTENT: words added to Neovim's built in
            --    spelling ignore dictionary are still ignored.`
            --    It is suggested to add words to that dictionary
            --    using `zg`, `:spellgood`, or from the WurdSpelSuggest
            --    options instead of adding words here.

            -- enabled = true
            -- -- Enable WurdSpel on start

            -- remap = true
            -- -- Remap the builtin z=, zg, & zw commands to the
            -- -- WurdSpel command equivalents.
            -- -- z= -> WurdSpelSuggest
            -- -- zg -> WurdSpelGood
            -- -- zw -> WurdSpelBad

            -- remap_special = false
            -- -- Add special remaps
            -- -- <leader>zz -> WurdSpelSuggest
            -- -- <leader>zg -> WurdSpelGood
            -- -- <leader>zw -> WurdSpelBad
        })
    end
}
```
