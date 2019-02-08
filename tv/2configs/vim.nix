{ config, lib, pkgs, ... }:

with import <stockholm/lib>;
let {
  body = {
    environment.systemPackages = [
      vim-wrapper
    ];

    environment.etc.vimrc.source = vimrc;

    environment.variables.EDITOR = mkForce "vim";
    environment.variables.VIMINIT = ":so /etc/vimrc";
  };

  extra-runtimepath = concatMapStringsSep "," (pkg: "${pkg.rtp}") [
    # cannot use pkgs.vimPlugins.fzf-vim as it's missing :Rg
    (pkgs.vimUtils.buildVimPlugin {
      name = "fzf-2018-11-14";
      src = pkgs.fetchgit {
        url = https://github.com/junegunn/fzf.vim;
        rev = "ad1833ecbc9153b6e34a4292dc089a58c4bcb8dc";
        sha256 = "1z2q71q6l9hq9fqfqpj1svhyk4yk1bzw1ljhksx4bnpz8gkfbx2m";
      };
    })
    pkgs.vimPlugins.fzfWrapper
    pkgs.vimPlugins.undotree
    (pkgs.vimUtils.buildVimPlugin {
      name = "vim-elixir-2018-08-17";
      src = pkgs.fetchgit {
        url = https://github.com/elixir-editors/vim-elixir;
        rev = "0a847f0faed5ba2d94bb3d51f355c50f37ba025b";
        sha256 = "1jl85wpgywhcvhgw02y8zpvqf0glr4i8522kxpvhsiacb1v1xh04";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "vim-syntax-jq";
      src = pkgs.fetchgit {
        url = https://github.com/vito-c/jq.vim;
        rev = "99d55a300047946a82ecdd7617323a751199ad2d";
        sha256 = "09c94nah47wx0cr556w61h6pfznxld18pfblc3nv51ivbw7cjqyx";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "file-line-1.0";
      src = pkgs.fetchgit {
        url = git://github.com/bogado/file-line;
        rev = "refs/tags/1.0";
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
        hi Constant     ctermfg=255
        hi Identifier   ctermfg=253
        hi Function     ctermfg=253
        hi Statement    ctermfg=253
        hi PreProc      ctermfg=251
        hi Type         ctermfg=251
        hi Delimiter    ctermfg=251
        hi Special      ctermfg=255

        hi Garbage      ctermbg=088
        hi TabStop      ctermbg=016
        hi Todo         ctermfg=174 ctermbg=NONE

        hi NixCode      ctermfg=040
        hi NixData      ctermfg=046
        hi NixQuote     ctermfg=071

        hi diffNewFile  ctermfg=207
        hi diffFile     ctermfg=207
        hi diffLine     ctermfg=207
        hi diffSubname  ctermfg=207
        hi diffAdded    ctermfg=010
        hi diffRemoved  ctermfg=009

        hi Search       cterm=NONE ctermbg=216
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
    ((rtp: rtp // { inherit rtp; }) (pkgs.write "vim-syntax-nix-nested" {
      "/syntax/haskell.vim".text = /* vim */ ''
        syn region String start=+\[[[:alnum:]]*|+ end=+|]+

        hi link ConId Identifier
        hi link VarId Identifier
        hi link hsDelimiter Delimiter
      '';
      "/syntax/nix.vim".text = /* vim */ ''
        "" Quit when a (custom) syntax file was already loaded
        "if exists("b:current_syntax")
        "  finish
        "endif

        "setf nix

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

        syn match NixOther /[-!+&<>|():/;=.,?\[\]*@]/

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

        ${concatStringsSep "\n" (mapAttrsToList (name: {
          extraStart ? null,
          lang ? name
        }:
        let
          startAlts = filter isString [
            ''/\* ${name} \*/''
            extraStart
          ];
          sigil = ''\(${concatStringsSep ''\|'' startAlts}\)[ \t\r\n]*'';
        in /* vim */ ''
          syn include @nix_${lang}_syntax syntax/${lang}.vim
          if exists("b:current_syntax")
            unlet b:current_syntax
          endif

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

          " This is required because containedin isn't transitive.
          syn cluster nix_has_dollar_curly
            \ add=@nix_${lang}_syntax
        '') (let

          capitalize = s: let
            xs = stringToCharacters s;
          in
            toUpper (head xs) + concatStrings (tail xs);

          alts = xs: ''\(${concatStringsSep ''\|'' xs}\)'';
          def = k: ''${k}[ \t\r\n]*='';
          writer = k: ''write${k}[^ \t\r\n]*[ \t\r\n]*\("[^"]*"\|[a-z]\+\)'';

          writerExt = k: writerName ''[^"]*\.${k}'';
          writerName = k: ''write[^ \t\r\n]*[ \t\r\n]*"${k}"'';

        in {
          c = {};
          cabal = {};
          diff = {};
          haskell = {};
          jq.extraStart = alts [
            (writer "Jq")
            (writerExt "jq")
          ];
          javascript.extraStart = ''/\* js \*/'';
          lua = {};
          python.extraStart = ''/\* py \*/'';
          sed.extraStart = writer "Sed";
          sh.extraStart = let
            phases = [
              "unpack"
              "patch"
              "configure"
              "build"
              "check"
              "install"
              "fixup"
              "installCheck"
              "dist"
            ];
            shells = [
              "ash"
              "bash"
              "dash"
            ];
          in alts [
            (def "shellHook")
            (def "${alts phases}Phase")
            (def "${alts ["pre" "post"]}${alts (map capitalize phases)}")
            (writer (alts (map capitalize shells)))
          ];
          yaml = {};
          vim.extraStart = alts [
            (writerExt "vim")
            (writerName ''\([^"]*\.\)\?vimrc'')
          ];
          xdefaults = {};
        }))}

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

        syn match NixQuote /'''\(''$\|\\.\)/he=s+2
          \ containedin=@nix_ind_strings
          \ contained

        syn match NixQuote /'''\('\|\\.\)/he=s+1
          \ containedin=@nix_ind_strings
          \ contained

        syn match NixQuote /\\./he=s+1
          \ containedin=@nix_strings
          \ contained

        syn sync fromstart

        let b:current_syntax = "nix"

        set isk=@,48-57,_,192-255,-,'
      '';
      "/syntax/sed.vim".text = /* vim */ ''
        syn region sedBranch
          \ matchgroup=sedFunction start="T"
          \ matchgroup=sedSemicolon end=";\|$"
          \ contains=sedWhitespace
      '';
    }))
  ];

  dirs = {
    backupdir = "$HOME/.cache/vim/backup";
    swapdir   = "$HOME/.cache/vim/swap";
    undodir   = "$HOME/.cache/vim/undo";
  };
  files = {
    viminfo   = "$HOME/.cache/vim/info";
  };

  need-dirs = let
    dirOf = s: let out = concatStringsSep "/" (init (splitString "/" s));
               in assert out != ""; out;
    alldirs = attrValues dirs ++ map dirOf (attrValues files);
  in unique (sort lessThan alldirs);

  vim-wrapper = pkgs.symlinkJoin {
    name = "vim";
    paths = [
      (pkgs.writeDashBin "vim" ''
        set -efu
        export FZF_DEFAULT_COMMAND='${pkgs.ripgrep}/bin/rg --files'
        export PATH=$PATH:${makeBinPath [
          pkgs.fzf
          pkgs.ripgrep
        ]}
        (umask 0077; exec ${pkgs.coreutils}/bin/mkdir -p ${toString need-dirs})
        exec ${pkgs.vim}/bin/vim "$@"
      '')
      pkgs.vim
    ];
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
    set noruler
    set pastetoggle=<INS>
    set runtimepath=$VIMRUNTIME,${extra-runtimepath}
    set shortmess+=I
    set showcmd
    set showmatch
    set timeoutlen=0
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

    set et ts=2 sts=2 sw=2

    filetype plugin indent on

    set t_Co=256
    colorscheme hack
    syntax on

    au Syntax * syn match Garbage containedin=ALL /\s\+$/
            \ | syn match TabStop containedin=ALL /\t\+/
            \ | syn keyword Todo containedin=ALL TODO

    au BufRead,BufNewFile *.nix set ft=nix

    au BufRead,BufNewFile /dev/shm/* set nobackup nowritebackup noswapfile

    cnoremap <C-A> <Home>

    noremap  <C-c> :q<cr>

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
    vnoremap u <nop>

    " fzf
    nnoremap <esc>q :Files<cr>
    nnoremap <esc>w :Rg<cr>

    " edit alternate buffer
    " For some reason neither putting <ctrl>6 nor <ctrl>^ works here...
    nnoremap <esc>a 
  '';
}
