return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  opts = {
    indent = { char = '│' }, -- You can change to "┆" or "┊"
    scope = { enabled = true },
  },
  config = function(_, opts)
    require('ibl').setup(opts)
  end,
}
