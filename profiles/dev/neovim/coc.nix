{ pkgs, lib, ... }:

{
  programs.neovim.coc.enable = true;
  programs.neovim.plugins = with pkgs.vimPlugins; [
    coc-clangd
    {
      plugin = coc-nvim;
      config = ''
        inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
        inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
        inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
        inoremap <silent><expr> <c-space> coc#refresh()

        set signcolumn=number

        autocmd CursorHold * silent call CocActionAsync('highlight')

        command! -nargs=0 Format :call CocAction('format')

        nnoremap <leader>gf :<C-u>Format<CR>
        xmap     <leader>=  <Plug>(coc-format-selected)

        nmap <silent> [g <Plug>(coc-diagnostic-prev)
        nmap <silent> ]g <Plug>(coc-diagnostic-next)
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)
      '';
    }
    coc-go
    coc-html
    coc-json
    coc-markdownlint
    coc-python
    coc-vimlsp
  ];
  programs.neovim.coc.settings = {
    diagnostic = {
      enable = true;
      errorSign = ">>";
      warningSign = "⚠";
    };
    languageserver = {
      bash = {
        command = "bash-language-server";
        args = [ "start" ];
        filetypes = [ "sh" "bash" ];
        ignoredRootPaths = [ "~" ];
      };
      nix = {
        command = "rnix-lsp";
        filetypes = [ "nix" ];
      };
    };

    "explorer.icon.enableNerdFont" = true;
    "explorer.buffer.tabOnly" = true;
    "explorer.file.reveal.whenOpen" = true;
    "explorer.file.hiddenRules" = {
      "extensions" = [
        "o" "a" "obj" "pyc"
      ];
      "filenames" = [ "node_modules" "result" "_build" ];
      "patternMatches" = [ "^\\." ];
    };
    "explorer.file.root.template" = "[icon] [title] [root] [fullpath]";
    "explorer.keyMappings.global" = {
      "u" = [ "wait" "indentPrev" ];
      "cf" = "addFile";
      "cd" = "addDirectory";
      "r" = "refresh";
      "a" = false;
      "A" = false;
      "R" = "rename";
      "/" = "search";
    };
  };
}
