-- save by pressing Escape
vim.keymap.set('n', '<Esc>', ':w<CR>', { desc = 'Save' })
-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
-- pasting over a selection no longer clobbers your clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

-- Hop keybindings
local hop = require('hop')
local directions = require('hop.hint').HintDirection
vim.keymap.set('', '<leader>w', function()
  hop.hint_words({ direction = directions.AFTER_CURSOR })
end, {remap=true})
vim.keymap.set('', '<leader>W', function()
  hop.hint_words({ direction = directions.BEFORE_CURSOR })
end, {remap=true})


