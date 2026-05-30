-- Rust 개발 환경 (LSP / 자동완성 / 디버깅 / Cargo.toml)
-- alice.nix 의 extraLuaConfig 에서 require("rust") 로 로드됨
-- codelldb 등 nix store 경로는 nix 가 생성하는 nix_paths.lua 에서 가져옴

local nix = require("nix_paths")
local map = vim.keymap.set

--------------------------------------------------------------------------------
-- 자동완성 (nvim-cmp + LuaSnip)  ── VSCode 식 완성 팝업
--------------------------------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load() -- friendly-snippets

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(), -- IntelliJ: 수동 완성 호출
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- crates.nvim 의 in-process LSP 완성도 여기로 들어옴
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

--------------------------------------------------------------------------------
-- 진단 표시 (인라인 가상 텍스트 + 거터 사인)
--------------------------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

--------------------------------------------------------------------------------
-- LSP 키맵 (rust 버퍼에 attach 될 때 적용)  ── IntelliJ 단축키 대응
--------------------------------------------------------------------------------
local function on_attach(_, bufnr)
  -- 인레이 타입 힌트 ON (neovim 버전별 시그니처 차이 → pcall 로 보호)
  if vim.lsp.inlay_hint then
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
  end

  local function bmap(lhs, rhs, desc)
    map("n", lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
  end
  local builtin = require("telescope.builtin")

  bmap("gd", vim.lsp.buf.definition, "정의로 이동 (Cmd+B)")
  bmap("gD", vim.lsp.buf.declaration, "선언으로 이동")
  bmap("gi", builtin.lsp_implementations, "구현으로 이동")
  bmap("gr", builtin.lsp_references, "사용처 찾기 (Alt+F7)")
  bmap("K", function() vim.lsp.buf.hover() end, "빠른 문서 (Ctrl+Q)")
  bmap("<leader>rn", vim.lsp.buf.rename, "이름 변경 (Shift+F6)")
  bmap("<leader>F", function() vim.lsp.buf.format({ async = false }) end, "포맷 (Cmd+Alt+L)")
  bmap("<leader>e", vim.diagnostic.open_float, "현재 줄 진단 보기")
  bmap("<leader>fs", builtin.lsp_document_symbols, "문서 심볼 (Cmd+F12)")
  bmap("<leader>fw", builtin.lsp_dynamic_workspace_symbols, "워크스페이스 심볼")

  -- 진단 이동 (neovim 0.11+ 는 jump, 이전은 goto_*)
  local function diag_jump(count)
    if vim.diagnostic.jump then
      vim.diagnostic.jump({ count = count, float = true })
    elseif count > 0 then
      vim.diagnostic.goto_next()
    else
      vim.diagnostic.goto_prev()
    end
  end
  bmap("]d", function() diag_jump(1) end, "다음 진단")
  bmap("[d", function() diag_jump(-1) end, "이전 진단")

  -- rustaceanvim 전용 기능 (RustLsp 커맨드)
  bmap("<leader>a", function() vim.cmd.RustLsp("codeAction") end, "코드 액션/퀵픽스 (Alt+Enter)")
  bmap("<leader>rr", function() vim.cmd.RustLsp("runnables") end, "실행 대상 (Ctrl+Shift+R)")
  bmap("<leader>rm", function() vim.cmd.RustLsp({ "expandMacro" }) end, "매크로 펼치기")
  bmap("<leader>rd", function() vim.cmd.RustLsp("openDocs") end, "docs.rs 열기")
  bmap("<leader>rc", function() vim.cmd.RustLsp("openCargo") end, "Cargo.toml 열기")
end

--------------------------------------------------------------------------------
-- 디버깅 (nvim-dap + dap-ui + codelldb)
--------------------------------------------------------------------------------
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()

-- 디버그 세션 시작/종료에 맞춰 dap-ui 자동 토글
dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

-- 중단점 아이콘
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual", numhl = "" })

map("n", "<F5>", function() dap.continue() end, { desc = "디버그 계속/시작 (Shift+F9)" })
map("n", "<F10>", function() dap.step_over() end, { desc = "스텝 오버" })
map("n", "<F11>", function() dap.step_into() end, { desc = "스텝 인투" })
map("n", "<F12>", function() dap.step_out() end, { desc = "스텝 아웃" })
map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "중단점 토글 (Ctrl+F8)" })
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("조건부 중단점 조건: "))
end, { desc = "조건부 중단점" })
map("n", "<leader>du", function() dapui.toggle() end, { desc = "디버그 UI 토글" })
-- rust 실행 파일/테스트를 골라서 디버그 시작
map("n", "<leader>dd", function() vim.cmd.RustLsp("debuggables") end, { desc = "디버그 대상 선택 (Rust)" })

--------------------------------------------------------------------------------
-- rustaceanvim 설정 (rust-analyzer 통합) ── 반드시 .rs 파일 열기 전에 설정
--------------------------------------------------------------------------------
vim.g.rustaceanvim = {
  server = {
    capabilities = capabilities,
    on_attach = on_attach,
    default_settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true, loadOutDirsFromCheck = true },
        check = { command = "clippy" }, -- 저장 시 clippy 진단
        procMacro = { enable = true },
        inlayHints = {
          bindingModeHints = { enable = true },
          closureReturnTypeHints = { enable = "always" },
          parameterHints = { enable = true },
          typeHints = { enable = true },
        },
      },
    },
  },
  dap = {
    adapter = require("rustaceanvim.config").get_codelldb_adapter(nix.codelldb, nix.liblldb),
  },
}

--------------------------------------------------------------------------------
-- 저장 시 rustfmt 자동 포맷
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function()
    pcall(vim.lsp.buf.format, { async = false, timeout_ms = 2000 })
  end,
})

--------------------------------------------------------------------------------
-- Cargo.toml: crates.nvim (dependi 대응 — 버전 표시/업데이트)
--------------------------------------------------------------------------------
require("crates").setup({
  lsp = {
    enabled = true, -- in-process LSP 로 완성/hover/코드액션 제공
    actions = true,
    completion = true,
    hover = true,
  },
})

vim.api.nvim_create_autocmd("BufRead", {
  pattern = "Cargo.toml",
  callback = function()
    local crates = require("crates")
    local opts = { buffer = true, silent = true }
    map("n", "<leader>cu", crates.update_crate, vim.tbl_extend("force", opts, { desc = "crate 업데이트" }))
    map("n", "<leader>cU", crates.upgrade_all_crates, vim.tbl_extend("force", opts, { desc = "모든 crate 업그레이드" }))
    map("n", "<leader>cv", crates.show_versions_popup, vim.tbl_extend("force", opts, { desc = "버전 목록 보기" }))
    map("n", "<leader>cf", crates.show_features_popup, vim.tbl_extend("force", opts, { desc = "features 보기" }))
  end,
})
