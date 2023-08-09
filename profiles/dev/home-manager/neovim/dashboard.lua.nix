{ ... }: ''

vim.g.startify_use_env = 0
vim.g.startify_files_number = 10
vim.g.startify_session_autoload = 0
vim.g.startify_relative_path = 0
-- Disable changing to the file's directory
vim.g.startify_change_to_dir = 0

vim.g.startify_custom_header = {}
vim.g.startify_custom_footer = {}

vim.g.startify_lists = {
  { type = 'dir',       header = {'   MRU ' .. vim.fn.getcwd()} },
  { type = 'files',     header = {'   MRU'} },
  { type = 'sessions',  header = {'   Sessions'} },
  { type = 'bookmarks', header = {'   Bookmarks'} },
  { type = 'commands',  header = {'   Commands'} },
}

vim.g.startify_skiplist = { 'COMMIT_EDITMSG', '^/nix/store', '^/tmp', '^/private/var/tmp/', '^/run', '/.git/' }
vim.g.startify_bookmarks = {
  { D = '~/dotfiles' },
  { I = '~/dev/infra/infrastructure', },
}

autocmd({'User'}, {
  group = myCommandGroup,
  pattern = 'Startified',
  command = 'setlocal cursorline',
})

-- Open Startify when there's no other buffer in the current tab
if vim.g.vscode == nil then
  autocmd({'BufDelete'}, {
    group = myCommandGroup,
    callback = function()
      -- List of buffers in the windows of the current tab
      local buffer_list = vim.fn.tabpagebuflist()

      -- Find whether all buffers are listed
      -- A new list is created for debugging purposes
      local filtered_bl = {}
      for _, bufnr in ipairs(buffer_list) do
        -- Somehow, the diagnostics hover buffer prevents Startify from opening...
        if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
          table.insert(filtered_bl, bufnr)
        end
      end

      local bufnr = vim.api.nvim_get_current_buf()
      local is_nameless_buffer = vim.api.nvim_buf_get_name(bufnr) == '''
      local is_buftype_empty = vim.api.nvim_buf_get_option(bufnr, 'buftype') == '''

      if #filtered_bl > 0 and is_nameless_buffer and is_buftype_empty then
        vim.cmd.Startify()
      end
    end,
  })
end

-- Open nvim-tree automatically
autocmd('User', {
  group = myCommandGroup,
  nested = true,
  pattern = 'StartifyBufferOpened',
  callback = function(ev)
    local nvim_tree = require('nvim-tree.api')
    if not nvim_tree.tree.is_visible() then
      nvim_tree.tree.open()
      -- Unfocus
      vim.cmd('noautocmd wincmd p')
    end
  end,
})

-- Automatically close when its last buffer/window
autocmd('QuitPre', {
  group = myCommandGroup,
  callback = function()
    local tree_wins = {}
    local floating_wins = {}
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match('NvimTree_') ~= nil then
        table.insert(tree_wins, w)
      end
      if vim.api.nvim_win_get_config(w).relative ~= ''' then
        table.insert(floating_wins, w)
      end
    end
    -- If only one window with only nvim-tree then quit
    if 1 == #wins - #floating_wins - #tree_wins then
      for _, w in ipairs(tree_wins) do
        vim.api.nvim_win_close(w, true)
      end
    end
  end,
})

''
