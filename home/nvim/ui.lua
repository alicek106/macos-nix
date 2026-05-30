-- UI / 편집 경험 현대화 (filetype 무관 공통 설정)
-- alice.nix 의 programs.neovim.extraLuaConfig 에서 require("ui") 로 로드됨

-- 컬러스킴: tokyonight (IntelliJ Darcula 느낌의 다크 테마)
require("tokyonight").setup({
  style = "night",
  on_highlights = function(hl, c)
    -- 인레이 힌트가 배경에 묻히지 않게 약간 흐린 회색으로
    hl.LspInlayHint = { fg = c.comment, bg = "NONE" }
  end,
})
vim.cmd.colorscheme("tokyonight-night")

-- 아이콘
require("nvim-web-devicons").setup({})

-- 상태바 (vim-airline 대체)
require("lualine").setup({
  options = {
    theme = "tokyonight",
    icons_enabled = true,
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
    globalstatus = true,
  },
  sections = {
    lualine_c = { { "filename", path = 1 } }, -- 상대경로 표시
    lualine_x = { "diagnostics", "encoding", "filetype" },
  },
})

-- Treesitter: 시맨틱 하이라이팅 + 들여쓰기 (문법은 nix가 미리 빌드 → ensure_installed 불필요)
require("nvim-treesitter.configs").setup({
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true },
})

-- Git 변경사항 거터 표시
require("gitsigns").setup()

-- 괄호/따옴표 자동 짝맞춤
require("nvim-autopairs").setup({})

-- 들여쓰기 가이드 라인
require("ibl").setup()

-- Telescope: 퍼지 파인더 (Find Usages / Go to Symbol / Search Everywhere 대응)
local telescope = require("telescope")
telescope.setup({
  defaults = {
    layout_strategy = "horizontal",
    layout_config = { prompt_position = "top" },
    sorting_strategy = "ascending",
  },
})

-- 기존 fzf 키맵(<esc>b/f/h)은 그대로 두고, telescope 는 <leader>f* 네임스페이스 사용
local builtin = require("telescope.builtin")
local map = vim.keymap.set
map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep (프로젝트 전체 검색)" })
map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics 목록" })
