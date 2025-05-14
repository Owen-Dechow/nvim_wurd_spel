# nvim_wurd_spel

Those of us who use Neovim but cannot spell spend entirely too much time fighting with
ourselves and not enough time fighting our code. Neovim's built in spelling system is ok,
but it lacks some features that I would like to see. This becomes more evident when you
are using Treesitter. Most of the time only strings and comments get checked for
spelling, and spelling issues show up as a little line instead of a real warning or info
bar. WurdSpel works to fix this by running spell check on everything, not just comments.
This means that for the few of us that can even spell our variable names right, we are
saved. WurdSpel also makes spelling errors warnings (this can be changed if you aren't
as bad as spelling as me). To the spelling failures amongst us, I present
`nvim_wurd_spel`

## Installation

[lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
return {
    "Owen-Dechow/nvim_wurd_spel",
    config = function()
        require("wurd_spel").setup({
            -- severity = vim.diagnostic.severity.WARN,
            -- -- Set the severity level of spelling errors
            -- -- INFO, WARN, ERROR

            -- min_length = 5,
            -- -- Set the minimum length of word to be checked

            -- ignore = { "Dechow", "Neovim" }
            -- -- Add words to be ignored
            -- -- IMPORTENT: words added to Neovim's built in
            --    spelling ignore dictionary are still ignored.`
            --    It is suggested to add words to that dictionary
            --    using `zg` or `:spellgood` instead of adding
            --    words here.
        })
    end
}
```
