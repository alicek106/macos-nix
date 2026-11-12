require("tokyonight").setup({
  style = "night",
  on_highlights = function(hl, c)
    hl.LspInlayHint = { fg = c.comment, bg = "NONE" }
  end,
})
vim.cmd.colorscheme("tokyonight-night")

require("nvim-web-devicons").setup({})

require("lualine").setup({
  options = {
    theme = "tokyonight",
    icons_enabled = true,
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
    globalstatus = true,
  },
  sections = {
    lualine_c = { { "filename", path = 1 } },
    lualine_x = { "diagnostics", "encoding", "filetype" },
  },
})

local ts_filetypes = { "toml", "lua", "json", "yaml", "bash", "sh", "markdown", "help" }
vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_filetypes,
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

require("gitsigns").setup()

require("nvim-autopairs").setup({})

require("ibl").setup()

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.opt.fillchars:append({ foldopen = "-", foldclose = "+", foldsep = " " })

require("ufo").setup({
  provider_selector = function(_, _, _)
    return { "treesitter", "indent" }
  end,
})

local ufo = require("ufo")
local fmap = vim.keymap.set
fmap("n", "zR", ufo.openAllFolds, { desc = "모든 폴드 펼치기" })
fmap("n", "zM", ufo.closeAllFolds, { desc = "모든 폴드 접기" })
fmap("n", "zr", ufo.openFoldsExceptKinds, { desc = "한 단계 펼치기" })
fmap("n", "zm", ufo.closeFoldsWith, { desc = "한 단계 접기" })
fmap("n", "zp", function()
  if not ufo.peekFoldedLinesUnderCursor() then
    vim.lsp.buf.hover()
  end
end, { desc = "접힌 내용 미리보기" })

local telescope = require("telescope")
telescope.setup({
  defaults = {
    layout_strategy = "horizontal",
    layout_config = { prompt_position = "top" },
    sorting_strategy = "ascending",
  },
})

local builtin = require("telescope.builtin")
local map = vim.keymap.set
map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep (프로젝트 전체 검색)" })
map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics 목록" })
