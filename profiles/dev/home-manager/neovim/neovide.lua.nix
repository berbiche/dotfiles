{ ... }: ''
if vim.g.neovide then
  vim.o.guifont = 'Source Code Pro:h14'
  vim.g.neovide_input_use_logo = false
  vim.g.neovide_input_macos_option_key_is_meta = true
  vim.g.neovide_cursor_animation_length = 0

  vim.g.neovide_scale_factor = 1.0

  -- Keybinds
  local opts = { silent = true, }

  bind('n', '<C-ScrollWheelUp>', function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.10
  end, opts, 'Increase font size')
  bind('n', '<C-ScrollWheelDown>', function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.10
  end, opts, 'Decrease font size')
end
''
