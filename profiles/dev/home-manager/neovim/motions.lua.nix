{ ... }:
''
local M = {}

function M.select_until_case_change()
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.')
  local c = line:sub(col + 11, col + 1)

  local pattern
  if c:match('%l') then
    pattern = '[A-Z]'
  elseif c:match('%u') then
    pattern = '[a-z]'
  else
    return
  end

  local rest = line:sub(col + 2)
  local rel_end = rest:find(pattern)
  if not rel_end then
    if mode == 'o' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
    end
    return
  end

  vim.cmd('normal! v' .. rel_end .. 'l')
end

function M.select_until_separator()
  local mode = vim.fn.mode()
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.')
  local c = line:sub(col + 1, col + 1)

  local rest = line:sub(col + 2)
  local rel_end = rest:find('[_%-]')
  if not rel_end then
    if mode == 'o' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
    end
    return
  end

  vim.cmd('normal! v' .. rel_end .. 'l')
end

return M
''
