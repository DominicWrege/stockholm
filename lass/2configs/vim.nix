{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let
  out = {
    environment.systemPackages = [
      (hiPrio vim)
      (pkgs.writeDashBin "govet" ''
        go vet "$@"
      '')
      (hiPrio (pkgs.python3.withPackages (ps: [
        ps.python-language-server
        ps.pyls-isort
        ps.pyflakes
        ps.flake8
        ps.yapf
      ])))
    ];

    environment.etc.vimrc.source = vimrc;

    environment.variables.EDITOR = mkForce "vim";
    environment.variables.VIMINIT = ":so /etc/vimrc";
  };

  vimrc = pkgs.writeText "vimrc" ''
    set nocompatible

    set autoindent
    set backspace=indent,eol,start
    set backup
    set backupdir=${dirs.backupdir}/
    set directory=${dirs.swapdir}//
    set hlsearch
    set incsearch
    set mouse=a
    set ruler
    set pastetoggle=<INS>
    set runtimepath=${extra-runtimepath},$VIMRUNTIME
    set shortmess+=I
    set showcmd
    set showmatch
    set ttimeoutlen=0
    set undodir=${dirs.undodir}
    set undofile
    set undolevels=1000000
    set undoreload=1000000
    set viminfo='20,<1000,s100,h,n${files.viminfo}
    set visualbell
    set wildignore+=*.o,*.class,*.hi,*.dyn_hi,*.dyn_o
    set wildmenu
    set wildmode=longest,full

    set title
    set titleold=
    set titlestring=(vim)\ %t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

    set et ts=2 sts=2 sw=2

    filetype plugin indent on

    set t_Co=256
    colorscheme hack
    syntax on

    au Syntax * syn match Garbage containedin=ALL /\s\+$/
            \ | syn match TabStop containedin=ALL /\t\+/
            \ | syn keyword Todo containedin=ALL TODO
            \ | syn match NBSP '\%xa0'
            \ | syn match NarrowNBSP '\%u202F'

    au BufRead,BufNewFile *.hs so ${hs.vim}

    au BufRead,BufNewFile *.nix so ${nix.vim}

    au BufRead,BufNewFile /dev/shm/* set nobackup nowritebackup noswapfile

    nnoremap <F5> :call LanguageClient_contextMenu()<CR>
    set hidden
    let g:LanguageClient_serverCommands = {
        \ 'python': ['pyls'],
        \ 'go': ['~/go/bin/go-langserver']
        \ }

    let g:LanguageClient_diagnosticsDisplay = { 2: { "signText": "W" } }

    nmap <esc>q :buffer 
    nmap <M-q> :buffer 

    cnoremap <C-A> <Home>

    noremap  <C-c> :q<cr>
    vnoremap < <gv
    vnoremap > >gv

    nnoremap <esc>[5^  :tabp<cr>
    nnoremap <esc>[6^  :tabn<cr>
    nnoremap <esc>[5@  :tabm -1<cr>
    nnoremap <esc>[6@  :tabm +1<cr>

    nnoremap <f1> :tabp<cr>
    nnoremap <f2> :tabn<cr>
    inoremap <f1> <esc>:tabp<cr>
    inoremap <f2> <esc>:tabn<cr>

    " <C-{Up,Down,Right,Left>
    noremap <esc>Oa <nop> | noremap! <esc>Oa <nop>
    noremap <esc>Ob <nop> | noremap! <esc>Ob <nop>
    noremap <esc>Oc <nop> | noremap! <esc>Oc <nop>
    noremap <esc>Od <nop> | noremap! <esc>Od <nop>
    " <[C]S-{Up,Down,Right,Left>
    noremap <esc>[a <nop> | noremap! <esc>[a <nop>
    noremap <esc>[b <nop> | noremap! <esc>[b <nop>
    noremap <esc>[c <nop> | noremap! <esc>[c <nop>
    noremap <esc>[d <nop> | noremap! <esc>[d <nop>

    " search with ack
    let g:ackprg = 'ag --vimgrep'
    cnoreabbrev Ack Ack!

    " copy/paste from/to xclipboard
    set clipboard=unnamedplus
  '';

  extra-runtimepath = concatMapStringsSep "," (pkg: "${pkg.rtp}") [
    pkgs.vimPlugins.ack-vim
    pkgs.vimPlugins.Gundo
    pkgs.vimPlugins.undotree
    pkgs.vimPlugins.vim-go
    pkgs.vimPlugins.fzf-vim
    pkgs.vimPlugins.LanguageClient-neovim
    (pkgs.vimUtils.buildVimPlugin {
      name = "file-line-1.0";
      src = pkgs.fetchFromGitHub {
        owner = "bogado";
        repo = "file-line";
        rev = "1.0";
        sha256 = "0z47zq9rqh06ny0q8lpcdsraf3lyzn9xvb59nywnarf3nxrk6hx0";
      };
    })
    ((rtp: rtp // { inherit rtp; }) (pkgs.writeTextFile (let
      name = "hack";
    in {
      name = "vim-color-${name}-1.0.2";
      destination = "/colors/${name}.vim";
      text = /* vim */ ''
        set background=dark
        hi clear
        if exists("syntax_on")
          syntax clear
        endif

        let colors_name = ${toJSON name}

        hi Normal       ctermbg=235
        hi Comment      ctermfg=242
        hi Constant     ctermfg=062
        hi Identifier   ctermfg=068
        hi Function     ctermfg=041
        hi Statement    ctermfg=167
        hi PreProc      ctermfg=167
        hi Type         ctermfg=041
        hi Delimiter    ctermfg=251
        hi Special      ctermfg=062

        hi Garbage      ctermbg=088
        hi TabStop      ctermbg=016
        hi NBSP         ctermbg=094
        hi NarrowNBSP   ctermbg=097
        hi Todo         ctermfg=174 ctermbg=NONE

        hi NixCode      ctermfg=148
        hi NixData      ctermfg=149
        hi NixQuote     ctermfg=150

        hi diffNewFile  ctermfg=207
        hi diffFile     ctermfg=207
        hi diffLine     ctermfg=207
        hi diffSubname  ctermfg=207
        hi diffAdded    ctermfg=010
        hi diffRemoved  ctermfg=009
      '';
    })))
    ((rtp: rtp // { inherit rtp; }) (pkgs.writeTextFile (let
      name = "vim";
    in {
      name = "vim-syntax-${name}-1.0.0";
      destination = "/syntax/${name}.vim";
      text = /* vim */ ''
        ${concatMapStringsSep "\n" (s: /* vim */ ''
          syn keyword vimColor${s} ${s}
            \ containedin=ALLBUT,vimComment,vimLineComment
          hi vimColor${s} ctermfg=${s}
        '') (map (i: lpad 3 "0" (toString i)) (range 0 255))}
      '';
    })))
    ((rtp: rtp // { inherit rtp; }) (pkgs.writeTextFile (let
      name = "showsyntax";
    in {
      name = "vim-plugin-${name}-1.0.0";
      destination = "/plugin/${name}.vim";
      text = /* vim */ ''
        if exists('g:loaded_showsyntax')
          finish
        endif
        let g:loaded_showsyntax = 0

        fu! ShowSyntax()
          let id = synID(line("."), col("."), 1)
          let name = synIDattr(id, "name")
          let transName = synIDattr(synIDtrans(id),"name")
          if name != transName
            let name .= " (" . transName . ")"
          endif
          echo "Syntax: " . name
        endfu

        command! -n=0 -bar ShowSyntax :call ShowSyntax()
      '';
    })))
  ];

  dirs = {
    backupdir = "$HOME/.cache/vim/backup";
    swapdir   = "$HOME/.cache/vim/swap";
    undodir   = "$HOME/.cache/vim/undo";
  };
  files = {
    viminfo   = "$HOME/.cache/vim/info";
  };

  mkdirs = let
    dirOf = s: let out = concatStringsSep "/" (init (splitString "/" s));
               in assert out != ""; out;
    alldirs = attrValues dirs ++ map dirOf (attrValues files);
  in unique (sort lessThan alldirs);

  vim = pkgs.symlinkJoin {
    name = "vim";
    paths = [
      (pkgs.writeDashBin "vim" ''
        set -efu
        (umask 0077; exec ${pkgs.coreutils}/bin/mkdir -p ${toString mkdirs})
        exec ${pkgs.vim}/bin/vim "$@"
      '')
      pkgs.vim
    ];
  };

  hs.vim = pkgs.writeText "hs.vim" ''
    syn region String start=+\[[[:alnum:]]*|+ end=+|]+

    hi link ConId Identifier
    hi link VarId Identifier
    hi link hsDelimiter Delimiter
  '';

  nix.vim = pkgs.writeText "nix.vim" ''
    setf nix

    " Ref <nix/src/libexpr/lexer.l>
    syn match NixID    /[a-zA-Z\_][a-zA-Z0-9\_\'\-]*/
    syn match NixINT   /\<[0-9]\+\>/
    syn match NixPATH  /[a-zA-Z0-9\.\_\-\+]*\(\/[a-zA-Z0-9\.\_\-\+]\+\)\+/
    syn match NixHPATH /\~\(\/[a-zA-Z0-9\.\_\-\+]\+\)\+/
    syn match NixSPATH /<[a-zA-Z0-9\.\_\-\+]\+\(\/[a-zA-Z0-9\.\_\-\+]\+\)*>/
    syn match NixURI   /[a-zA-Z][a-zA-Z0-9\+\-\.]*:[a-zA-Z0-9\%\/\?\:\@\&\=\+\$\,\-\_\.\!\~\*\']\+/
    syn region NixSTRING
      \ matchgroup=NixSTRING
      \ start='"'
      \ skip='\\"'
      \ end='"'
    syn region NixIND_STRING
      \ matchgroup=NixIND_STRING
      \ start="'''"
      \ skip="'''\('\|[$]\|\\[nrt]\)"
      \ end="'''"

    syn match NixOther /[():/;=.,?\[\]]/

    syn match NixCommentMatch /\(^\|\s\)#.*/
    syn region NixCommentRegion start="/\*" end="\*/"

    hi link NixCode Statement
    hi link NixData Constant
    hi link NixComment Comment

    hi link NixCommentMatch NixComment
    hi link NixCommentRegion NixComment
    hi link NixID NixCode
    hi link NixINT NixData
    hi link NixPATH NixData
    hi link NixHPATH NixData
    hi link NixSPATH NixData
    hi link NixURI NixData
    hi link NixSTRING NixData
    hi link NixIND_STRING NixData

    hi link NixEnter NixCode
    hi link NixOther NixCode
    hi link NixQuote NixData

    syn cluster nix_has_dollar_curly contains=@nix_ind_strings,@nix_strings
    syn cluster nix_ind_strings contains=NixIND_STRING
    syn cluster nix_strings contains=NixSTRING

    ${concatStringsSep "\n" (mapAttrsToList (lang: { extraStart ? null }: let
      startAlts = filter isString [
        ''/\* ${lang} \*/''
        extraStart
      ];
      sigil = ''\(${concatStringsSep ''\|'' startAlts}\)[ \t\r\n]*'';
    in /* vim */ ''
      syn include @nix_${lang}_syntax syntax/${lang}.vim
      unlet b:current_syntax

      syn match nix_${lang}_sigil
        \ X${replaceStrings ["X"] ["\\X"] sigil}\ze\('''\|"\)X
        \ nextgroup=nix_${lang}_region_IND_STRING,nix_${lang}_region_STRING
        \ transparent

      syn region nix_${lang}_region_STRING
        \ matchgroup=NixSTRING
        \ start='"'
        \ skip='\\"'
        \ end='"'
        \ contained
        \ contains=@nix_${lang}_syntax
        \ transparent

      syn region nix_${lang}_region_IND_STRING
        \ matchgroup=NixIND_STRING
        \ start="'''"
        \ skip="'''\('\|[$]\|\\[nrt]\)"
        \ end="'''"
        \ contained
        \ contains=@nix_${lang}_syntax
        \ transparent

      syn cluster nix_ind_strings
        \ add=nix_${lang}_region_IND_STRING

      syn cluster nix_strings
        \ add=nix_${lang}_region_STRING

      syn cluster nix_has_dollar_curly
        \ add=@nix_${lang}_syntax
    '') {
      c = {};
      cabal = {};
      haskell = {};
      sh.extraStart = ''write\(Ba\|Da\)sh[^ \t\r\n]*[ \t\r\n]*"[^"]*"'';
      vim.extraStart =
        ''write[^ \t\r\n]*[ \t\r\n]*"\(\([^"]*\.\)\?vimrc\|[^"]*\.vim\)"'';
    })}

    " Clear syntax that interferes with nixINSIDE_DOLLAR_CURLY.
    syn clear shVarAssign

    syn region nixINSIDE_DOLLAR_CURLY
      \ matchgroup=NixEnter
      \ start="[$]{"
      \ end="}"
      \ contains=TOP
      \ containedin=@nix_has_dollar_curly
      \ transparent

    syn region nix_inside_curly
      \ matchgroup=NixEnter
      \ start="{"
      \ end="}"
      \ contains=TOP
      \ containedin=nixINSIDE_DOLLAR_CURLY,nix_inside_curly
      \ transparent

    syn match NixQuote /'''\([''$']\|\\.\)/he=s+2
      \ containedin=@nix_ind_strings
      \ contained

    syn match NixQuote /\\./he=s+1
      \ containedin=@nix_strings
      \ contained

    syn sync fromstart

    let b:current_syntax = "nix"

    set isk=@,48-57,_,192-255,-,'
  '';
in
out
