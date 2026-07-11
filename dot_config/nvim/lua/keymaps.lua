-- lua/keymaps.lua
local map = vim.keymap.set

-------------------------------------------------------------------------------
-- Déplacement visuel (wrap)

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down (visual line)" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up (visual line)" })

-------------------------------------------------------------------------------
-- Fenêtres

-- Navigation (normal + terminal)
map("n", "<A-h>", "<C-w>h", { desc = "Go to Left Window",  remap = true })
map("n", "<A-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<A-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<A-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })
map("t", "<A-h>", "<C-\\><C-n><C-w>h", { desc = "Go to Left Window" })
map("t", "<A-j>", "<C-\\><C-n><C-w>j", { desc = "Go to Lower Window" })
map("t", "<A-k>", "<C-\\><C-n><C-w>k", { desc = "Go to Upper Window" })
map("t", "<A-l>", "<C-\\><C-n><C-w>l", { desc = "Go to Right Window" })

-- Redimensionnement
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase Window Height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease Window Height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Splits
map("n", "<leader>ws", "<C-W>s", { desc = "Split Window Below",              remap = true })
map("n", "<leader>wv", "<C-W>v", { desc = "Split Window Right",              remap = true })
map("n", "<leader>wo", "<C-W>o", { desc = "Only Window (fermer les autres)", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window",                   remap = true })

-- Focus
map("n", "<leader>wh", "<C-w>h", { desc = "Focus Left Window",  remap = true })
map("n", "<leader>wj", "<C-w>j", { desc = "Focus Lower Window", remap = true })
map("n", "<leader>wk", "<C-w>k", { desc = "Focus Upper Window", remap = true })
map("n", "<leader>wl", "<C-w>l", { desc = "Focus Right Window", remap = true })

-------------------------------------------------------------------------------
-- Lignes — déplacer en normal, visuel et insertion (J/K et <A-j>/<A-k>)

map("n", "J",     "<cmd>execute 'move .+' . v:count1<cr>==",                     { desc = "Move Down" })
map("n", "K",     "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==",               { desc = "Move Up" })
map("v", "J",     ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",        { desc = "Move Down" })
map("v", "K",     ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-------------------------------------------------------------------------------
-- Buffers

map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>",     { desc = "Next Buffer" })
map("n", "[b",         "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b",         "<cmd>bnext<cr>",     { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>",       { desc = "Switch to Other Buffer" })
map("n", "<leader>`",  "<cmd>e #<cr>",       { desc = "Switch to Other Buffer" })
map("n", "<leader>bD", "<cmd>bd<cr>",        { desc = "Delete Buffer and Window" })

map("n", "<leader>bd", function()
  vim.api.nvim_buf_delete(0, { force = false })
end, { desc = "Delete Buffer" })

map("n", "<leader>bo", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and vim.bo[buf].buflisted then
      pcall(vim.api.nvim_buf_delete, buf, { force = false })
    end
  end
end, { desc = "Delete Other Buffers" })

map("n", "<leader>bi", function()
  local visible = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    visible[vim.api.nvim_win_get_buf(win)] = true
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if not visible[buf] and vim.bo[buf].buflisted then
      pcall(vim.api.nvim_buf_delete, buf, { force = false })
    end
  end
end, { desc = "Delete Invisible Buffers" })

-------------------------------------------------------------------------------
-- Onglets

map("n", "<leader><tab>l",     "<cmd>tablast<cr>",   { desc = "Last Tab" })
map("n", "<leader><tab>o",     "<cmd>tabonly<cr>",   { desc = "Close Other Tabs" })
map("n", "<leader><tab>f",     "<cmd>tabfirst<cr>",  { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>",    { desc = "New Tab" })
map("n", "<leader><tab>]",     "<cmd>tabnext<cr>",   { desc = "Next Tab" })
map("n", "<leader><tab>d",     "<cmd>tabclose<cr>",  { desc = "Close Tab" })
map("n", "<leader><tab>[",     "<cmd>tabprevious<cr>",{ desc = "Previous Tab" })
map("n", "<leader><tab>n",     "<cmd>tabnext<cr>",     { desc = "Next Tab" })
map("n", "<leader><tab>p",     "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-------------------------------------------------------------------------------
-- Recherche

-- Esc : efface le surlignage et revient au mode normal (i, n, s)
map({ "i", "n", "s" }, "<Esc>", function()
  vim.cmd("noh")
  return "<Esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Redessine + efface hlsearch + met à jour diff
map("n", "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear hlsearch / Diff Update" })

-- n/N : toujours dans la direction de la recherche, curseur centré
map("n",          "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map({ "x", "o" }, "n", "'Nn'[v:searchforward]",      { expr = true, desc = "Next Search Result" })
map("n",          "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map({ "x", "o" }, "N", "'nN'[v:searchforward]",      { expr = true, desc = "Prev Search Result" })

-- Scroll centré
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-------------------------------------------------------------------------------
-- Sauvegarde / Quitter
map("n", "<leader>qq",           "<cmd>qa<cr>",        { desc = "Quit All" })
map({ "n", "i", "v" }, "<C-q>",  "<cmd>qa<cr>",        { desc = "Quit All" })
map({ "n", "i", "v" }, "<C-s>",  "<cmd>w<cr><esc>",    { desc = "Save File" })

-------------------------------------------------------------------------------
-- Édition

map("x", "<leader>p",        [["_dP]],        { desc = "Coller sans écraser le registre" })
map({ "n", "v" }, "<leader>y", [["+y]],        { desc = "Copier vers clipboard système" })
map("n", "<leader>Y",        [["+Y]],          { desc = "Copier la ligne vers clipboard" })
map("x", "<",                "<gv",            { desc = "Indent Left" })
map("x", ">",                ">gv",            { desc = "Indent Right" })
map("n", "<leader>K",        "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- Commentaires natifs nvim 0.10+ : gcc (ligne), gc{motion}, gc (visuel)
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-------------------------------------------------------------------------------
-- Fichiers

map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-------------------------------------------------------------------------------
-- Quickfix / Location list

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

map("n", "<leader>xl", function()
  local ok, err = pcall(
    vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen
  )
  if not ok and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Location List" })

map("n", "<leader>xq", function()
  local ok, err = pcall(
    vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen
  )
  if not ok and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Quickfix List" })

-------------------------------------------------------------------------------
-- Inspection

map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-------------------------------------------------------------------------------
-- Yazi — terminal flottant

local function open_yazi()
  local tmp    = vim.fn.tempname()
  local dir    = vim.fn.expand("%:p:h")
  if dir == "" or dir == "." then dir = vim.fn.getcwd() end
  local width  = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines   * 0.9)
  local row    = math.floor((vim.o.lines   - height) / 2)
  local col    = math.floor((vim.o.columns - width)  / 2)
  local buf    = vim.api.nvim_create_buf(false, true)
  local win    = vim.api.nvim_open_win(buf, true, {
    relative = "editor", width = width, height = height,
    row = row, col = col, style = "minimal", border = "rounded",
  })
  vim.fn.termopen({ "yazi", "--chooser-file", tmp, dir }, {
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
        local ok, lines = pcall(vim.fn.readfile, tmp)
        vim.fn.delete(tmp)
        if ok and #lines > 0 and lines[1] ~= "" then
          vim.cmd("edit " .. vim.fn.fnameescape(lines[1]))
        end
      end)
    end,
  })
  vim.cmd("startinsert")
end

map("n", "<leader>e", open_yazi, { desc = "Yazi (explorateur flottant)" })

-------------------------------------------------------------------------------
-- Terminal — splits (toggle, persistant) inspiré du panneau oil.nvim

local _term_bottom = { buf = nil, win = nil }
local _term_left   = { buf = nil, win = nil }
local _term_right  = { buf = nil, win = nil }

local function git_root()
  local r = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("%s+$", "")
  return r ~= "" and r or vim.fn.getcwd()
end

-- Factory : ouvre/ferme un split terminal persistant.
-- split_cmd  : commande vim (ex. "botright split")
-- get_resize : fonction → commande resize (calculée à l'ouverture)
local function make_term_split(state, split_cmd, get_resize)
  return function(cwd)
    if state.win and vim.api.nvim_win_is_valid(state.win) then
      vim.api.nvim_win_close(state.win, false)
      state.win = nil
      return
    end
    vim.cmd(split_cmd)
    vim.cmd(get_resize())
    state.win = vim.api.nvim_get_current_win()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
      vim.api.nvim_win_set_buf(state.win, state.buf)
    else
      state.buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(state.win, state.buf)
      vim.fn.termopen(vim.o.shell, { cwd = cwd or vim.fn.getcwd() })
    end
    vim.cmd("startinsert")
  end
end

local term_bottom = make_term_split(_term_bottom, "botright split",
  function() return "resize " .. math.floor(vim.o.lines * 0.23) end)
local term_left = make_term_split(_term_left, "topleft vsplit",
  function() return "vertical resize " .. math.floor(vim.o.columns * 0.23) end)
local term_right = make_term_split(_term_right, "botright vsplit",
  function() return "vertical resize " .. math.floor(vim.o.columns * 0.23) end)

map("n",          "<leader>tt", function() term_bottom(vim.fn.getcwd()) end, { desc = "Terminal bas (cwd)" })
map("n",          "<leader>tr", function() term_bottom(git_root()) end,      { desc = "Terminal bas (racine git)" })
map({ "n", "t" }, "<c-/>",      function() term_bottom(git_root()) end,      { desc = "Terminal bas (racine git)" })
map({ "n", "t" }, "<c-_>",      function() term_bottom(git_root()) end,      { desc = "which_key_ignore" })
map("n",          "<leader>th", function() term_left(vim.fn.getcwd()) end,   { desc = "Terminal gauche 33 % (cwd)" })
map("n",          "<leader>tl", function() term_right(vim.fn.getcwd()) end,  { desc = "Terminal droite 33 % (cwd)" })

-------------------------------------------------------------------------------
-- Git (fzf-lua + git natif)

local fzf = require("fzf-lua")

map("n", "<leader>gl", fzf.git_commits,  { desc = "Git Log" })
map("n", "<leader>gL", fzf.git_commits,  { desc = "Git Log (cwd)" })
map("n", "<leader>gf", fzf.git_files,    { desc = "Fichiers Git (fzf)" })
map("n", "<leader>gh", fzf.git_bcommits, { desc = "Historique du fichier courant (fzf)" })

map("n", "<leader>gb", fzf.git_branches, { desc = "Branches Git (fzf)" })
map("n", "<leader>gs", fzf.git_status,   { desc = "Fichiers modifiés Git (fzf)" })

map("n", "<leader>gB", function()
  local line = vim.fn.line(".")
  local file = vim.fn.expand("%")
  local out  = vim.fn.system(("git blame -L %d,%d -- %s"):format(line, line, file))
  vim.notify(out, vim.log.levels.INFO, { title = "Git Blame" })
end, { desc = "Git Blame Line" })

local function git_url(copy)
  local remote = vim.fn.system("git remote get-url origin 2>/dev/null"):gsub("%s+$", "")
  if remote == "" then
    vim.notify("Pas de remote git trouvé.", vim.log.levels.WARN)
    return
  end
  remote = remote:gsub("git@github%.com:", "https://github.com/"):gsub("%.git$", "")
  local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("%s+$", "")
  local url    = ("%s/blob/%s/%s"):format(remote, branch, vim.fn.expand("%:~:."))
  if copy then
    vim.fn.setreg("+", url)
    vim.notify("Copié : " .. url)
  else
    vim.fn.jobstart({ "xdg-open", url }, { detach = true })
  end
end

map({ "n", "x" }, "<leader>go", function() git_url(false) end, { desc = "Git Browse (open)" })
map({ "n", "x" }, "<leader>gY", function() git_url(true)  end, { desc = "Git Browse (copy)" })

-------------------------------------------------------------------------------
-- FZF

map("n", "<leader>ff", fzf.files,      { desc = "Trouver un fichier (fzf)" })
map("n", "<leader>fg", fzf.live_grep,  { desc = "Grep dans le projet (fzf)" })
map("n", "<leader>fb", fzf.buffers,    { desc = "Lister les buffers (fzf)" })
map("n", "<leader>fh", fzf.help_tags,  { desc = "Aide Neovim (fzf)" })
map("n", "<leader>fo", fzf.oldfiles,   { desc = "Fichiers récents (fzf)" })
map("n", "<leader>fr", fzf.resume,     { desc = "Reprendre la dernière recherche fzf" })

-- Mot sous le curseur
map("n", "<leader>fw", fzf.grep_cword,  { desc = "Chercher le mot sous le curseur (fzf)" })
map("n", "<leader>fW", fzf.grep_cWORD, { desc = "Chercher le WORD sous le curseur (fzf)" })

-- Lignes
map("n", "<leader>fl", fzf.lines,       { desc = "Chercher dans les buffers ouverts (fzf)" })
map("n", "<leader>fL", fzf.blines,      { desc = "Chercher dans le buffer actuel (fzf)" })

-- Neovim
map("n", "<leader>fc", fzf.commands,    { desc = "Commandes Neovim (fzf)" })
map("n", "<leader>fk", fzf.keymaps,     { desc = "Raccourcis clavier (fzf)" })
map("n", "<leader>fm", fzf.marks,       { desc = "Marks Vim (fzf)" })
map("n", "<leader>fj", fzf.jumps,       { desc = "Liste des sauts (fzf)" })
map("n", "<leader>fq", fzf.quickfix,    { desc = "Liste quickfix (fzf)" })
map("n", "<leader>fd", fzf.diagnostics_document,  { desc = "Diagnostics du fichier (fzf)" })
map("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Diagnostics du projet (fzf)" })

-- LSP (global)
map("n", "<leader>lS", fzf.lsp_workspace_symbols, { desc = "Symboles du projet (fzf)" })

-------------------------------------------------------------------------------
-- oil.nvim — toggle panneau droit 25 %

local function oil_toggle_right()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "oil" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  local width = math.floor(vim.o.columns * 0.23)
  vim.cmd("botright vsplit")
  vim.cmd("vertical resize " .. width)
  require("oil").open(vim.fn.getcwd())
end

map("n", "<leader>o", oil_toggle_right,                           { desc = "Toggle oil (droite 25 %)" })
map("n", "-",         "<cmd>Oil<cr>",                             { desc = "Oil (répertoire courant)" })
map("n", "<leader>O", function() require("oil").open_float() end, { desc = "Oil (flottant)" })

-------------------------------------------------------------------------------
-- LSP

-- Navigation de références LSP avec wrapping
local function ref_nav(forward)
  return function()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, "textDocument/references",
      vim.tbl_extend("force", params, { context = { includeDeclaration = true } }),
      function(_, refs)
        if not refs or #refs == 0 then return end
        table.sort(refs, function(a, b)
          if a.range.start.line ~= b.range.start.line then
            return a.range.start.line < b.range.start.line
          end
          return a.range.start.character < b.range.start.character
        end)
        local cur     = vim.api.nvim_win_get_cursor(0)
        local cl, cc  = cur[1] - 1, cur[2]
        local target
        if forward then
          for _, r in ipairs(refs) do
            local l, c = r.range.start.line, r.range.start.character
            if l > cl or (l == cl and c > cc) then target = r; break end
          end
          target = target or refs[1]
        else
          for i = #refs, 1, -1 do
            local r = refs[i]
            local l, c = r.range.start.line, r.range.start.character
            if l < cl or (l == cl and c < cc) then target = r; break end
          end
          target = target or refs[#refs]
        end
        vim.lsp.util.jump_to_location(target, "utf-8")
      end)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local b = ev.buf

    -- Navigation
    map("n", "<leader>cl", "<cmd>LspInfo<cr>",          { buffer = b, desc = "Lsp Info" })
    map("n", "gd",  fzf.lsp_definitions,                { buffer = b, desc = "Goto Definition" })
    map("n", "gD",  vim.lsp.buf.declaration,            { buffer = b, desc = "Goto Declaration" })
    map("n", "gr",  fzf.lsp_references,                 { buffer = b, desc = "References" })
    map("n", "gI",  fzf.lsp_implementations,            { buffer = b, desc = "Goto Implementation" })
    map("n", "gy",  fzf.lsp_typedefs,                   { buffer = b, desc = "Goto T[y]pe Definition" })
    map("n", "K",   vim.lsp.buf.hover,                  { buffer = b, desc = "Hover" })
    map("n", "gK",  vim.lsp.buf.signature_help,         { buffer = b, desc = "Signature Help" })
    map("i", "<c-k>", vim.lsp.buf.signature_help,       { buffer = b, desc = "Signature Help" })

    -- Références (navigation wrapping dans le fichier courant)
    map("n", "]]",    ref_nav(true),  { buffer = b, desc = "Next Reference" })
    map("n", "[[",    ref_nav(false), { buffer = b, desc = "Prev Reference" })
    map("n", "<a-n>", ref_nav(true),  { buffer = b, desc = "Next Reference" })
    map("n", "<a-p>", ref_nav(false), { buffer = b, desc = "Prev Reference" })

    -- Actions
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = b, desc = "Code Action" })
    map({ "n", "x" }, "<leader>cf", function()
      local clients = vim.lsp.get_clients({ bufnr = b, method = "textDocument/formatting" })
      if #clients > 0 then
        vim.lsp.buf.format({ async = true })
        return
      end
      -- Aucun LSP formatter : fallback prettier
      local path = vim.api.nvim_buf_get_name(b)
      if path == "" then
        vim.notify("Format: buffer sans chemin de fichier", vim.log.levels.WARN)
        return
      end
      local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
      local result = vim.fn.system(
        { "prettier", "--stdin-filepath", path },
        table.concat(lines, "\n")
      )
      if vim.v.shell_error ~= 0 then
        vim.notify("prettier: " .. result, vim.log.levels.ERROR)
        return
      end
      local formatted = vim.split(result, "\n", { plain = true })
      if formatted[#formatted] == "" then table.remove(formatted) end
      vim.api.nvim_buf_set_lines(b, 0, -1, false, formatted)
    end, { buffer = b, desc = "Format" })
    map({ "n", "x" }, "<leader>cA", function()
      vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
    end, { buffer = b, desc = "Source Action" })
    map("n", "<leader>co", function()
      vim.lsp.buf.code_action({
        apply   = true,
        context = { only = { "source.organizeImports" }, diagnostics = {} },
      })
    end, { buffer = b, desc = "Organize Imports" })
    map("n", "<leader>cr", vim.lsp.buf.rename, { buffer = b, desc = "Rename" })
    map("n", "<leader>cR", function()
      local old = vim.api.nvim_buf_get_name(b)
      vim.ui.input({ prompt = "Rename file: ", default = vim.fn.fnamemodify(old, ":t") },
        function(new_name)
          if not new_name or new_name == "" then return end
          local new = vim.fn.fnamemodify(old, ":h") .. "/" .. new_name
          vim.cmd("saveas " .. vim.fn.fnameescape(new))
          vim.fn.delete(old)
          vim.cmd("bdelete #")
        end)
    end, { buffer = b, desc = "Rename File" })

    -- Codelens
    map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run,    { buffer = b, desc = "Run Codelens" })
    map("n", "<leader>cC",          vim.lsp.codelens.refresh, { buffer = b, desc = "Refresh & Display Codelens" })

    -- Diagnostics
    map("n", "<leader>cd", vim.diagnostic.open_float, { buffer = b, desc = "Line Diagnostics" })
    map("n", "]d", vim.diagnostic.goto_next,          { buffer = b, desc = "Next Diagnostic" })
    map("n", "[d", vim.diagnostic.goto_prev,          { buffer = b, desc = "Prev Diagnostic" })
    map("n", "]e", function()
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, { buffer = b, desc = "Next Error" })
    map("n", "[e", function()
      vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, { buffer = b, desc = "Prev Error" })
    map("n", "]w", function()
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
    end, { buffer = b, desc = "Next Warning" })
    map("n", "[w", function()
      vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
    end, { buffer = b, desc = "Prev Warning" })

    -- Appels entrants / sortants
    map("n", "gai", fzf.lsp_incoming_calls, { buffer = b, desc = "C[a]lls Incoming" })
    map("n", "gao", fzf.lsp_outgoing_calls, { buffer = b, desc = "C[a]lls Outgoing" })

    -- Symboles
    map("n", "<leader>ss", fzf.lsp_document_symbols,       { buffer = b, desc = "LSP Symbols" })
    map("n", "<leader>sS", fzf.lsp_live_workspace_symbols, { buffer = b, desc = "LSP Workspace Symbols" })
  end,
})

-------------------------------------------------------------------------------
-- Flash

map({ "n", "x", "o" }, "s", function() require("flash").jump() end,             { desc = "Flash" })
map({ "n", "x", "o" }, "S", function() require("flash").treesitter() end,       { desc = "Flash Treesitter" })
map("o",               "r", function() require("flash").remote() end,            { desc = "Flash Remote" })
map({ "o", "x" },      "R", function() require("flash").treesitter_search() end, { desc = "Flash Treesitter Search" })
map("c",               "<c-s>", function() require("flash").toggle() end,        { desc = "Flash Toggle Search" })

-------------------------------------------------------------------------------
-- Markdown

-- Configuration Markdown (TOC, Styles et Navigation)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    local opts = { buffer = ev.buf }

    -- Génération de la Table des Matières
    opts.desc = "Générer TOC GitHub (markdown-toc)"
    map("n", "<leader>atg", "<cmd>GenTocGFM<cr>", opts)

    -- Formatage de texte (Visual Mode)
    opts.desc = "Encadrer en italique (*)"
    map("x", "<leader>ai", [["zygv<esc>`>a*<esc>`<i*<esc>]], opts)

    opts.desc = "Encadrer en gras (**)"
    map("x", "<leader>ab", [["zygv<esc>`>a**<esc>`<i**<esc>]], opts)

    opts.desc = "Encadrer en surbrillance (`)"
    map("x", "<leader>aq", [["zygv<esc>`>a`<esc>`<i`<esc>]], opts)

    opts.desc = "Créer un bloc de code (```)"
    map("x", "<leader>ac", [["zygv<esc>`>a<cr>```<esc>`<i```<cr><esc>kA]], opts)

    -- Yank contenu d'un bloc de code (Normal Mode)
    opts.desc = "Copier le contenu du bloc de code courant"
    map("n", "<leader>yc", function()
      local start = vim.fn.search("^```", "bnW")
      local stop  = vim.fn.search("^```", "nW")
      if start == 0 or stop == 0 or stop <= start + 1 then
        vim.notify("Pas de bloc de code trouvé", vim.log.levels.WARN)
        return
      end
      -- lignes entre les deux délimiteurs (exclus)
      local lines = vim.api.nvim_buf_get_lines(0, start, stop - 1, false)
      vim.fn.setreg("+", table.concat(lines, "\n"))
      vim.notify(string.format("%d ligne(s) copiées", #lines))
    end, opts)

    -- Navigation : Permet à 'gf' de chercher les ancres locales (#titre)
    opts.desc = "Jump to markdown anchor"
    map("n", "gf", function()
      local target = vim.fn.expand("<cfile>")
      if target:sub(1, 1) == "#" then
        -- Nettoie les tirets de la TOC pour correspondre au texte du titre réel
        local search_term = target:sub(2):gsub("-", " ")
        vim.fn.search("^#\\+ " .. search_term)
      else
        pcall(vim.cmd, "normal! gf")
      end
    end, opts)
  end,
})
