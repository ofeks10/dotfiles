-- The main branch compiles parsers with the tree-sitter CLI (from Nix) and
-- leaves turning highlighting/indent on to us.
local langs = {
  'bash', 'javascript', 'json', 'lua', 'markdown', 'markdown_inline',
  'nix', 'python', 'toml', 'tsx', 'typescript', 'vim', 'vimdoc', 'yaml',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,  -- the plugin doesn't support lazy-loading
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install(langs)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          -- no-op for filetypes without an installed parser
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
