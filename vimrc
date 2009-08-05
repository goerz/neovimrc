" Main VIM Configuration File
" Author: Michael Goerz <goerz@physik.fu-berlin.de>

" * Interface Settings {{{1

" use the mouse in xterm (or other terminals that support it)
"set mouse=a
set ttymouse=xterm2

" switch ' and `
nnoremap ' `
nnoremap ` '

" pastetoggle
set pastetoggle=<F1>

" Up/down, j/k key behaviour
" -- Changes up/down arrow keys to behave screen-wise, rather than file-wise.
"    Behaviour is unchanged in operator-pending mode.
if version >= 700
    " Stop remapping from interfering with Omni-complete popup
    inoremap <silent><expr><Up> pumvisible() ? "<Up>" : "<C-O>gk"
    inoremap <silent><expr><Down> pumvisible() ? "<Down>" : "<C-O>gj"
else
    inoremap <silent><Up> <C-O>gk
    inoremap <silent><Down> <C-O>gj
endif

nnoremap <silent>j gj
nnoremap <silent>k gk
nnoremap <silent><Up> gk
nnoremap <silent><Down> gj
vnoremap <silent>j gj
vnoremap <silent>k gk
vnoremap <silent><Up> gk
vnoremap <silent><Down> gj


" enable syntax highlighting
syntax on

" enable incremental search, but disable search highlighting by default
set nohlsearch
set incsearch

" Reload the file if it changes outside of vim
set autoread

" select case-insenitiv search
set ignorecase
set smartcase

" set statusline"
if has("gui_running")
    " In gvim, we can do with a fairly simple status line
    set stl=%f\ [%{(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\")}%M%R%H%W]\ %y\ [%l/%L,%v]\ [%p%%]
else
    " In a regular console, I want to emulate a scroll bar
    func! STL()
        let stl_encodinginfo = '%{(&fenc==""?&enc:&fenc).((exists("+bomb") && &bomb)?",B":"")}'
        let stl = '%f ['.stl_encodinginfo.'%M%R%H%W] %y [%l/%L,%2.v]'
        let takenwidth = len(bufname(winbufnr(winnr()))) + len(&filetype) + 3 * &readonly
                    \ + len((&fenc==""?&enc:&fenc).((exists("+bomb") && &bomb)?",B":""))
                    \ + 2 * ((&modified) || (!&modifiable)) + 2*len(line('$')) + 20
                    \ + g:stl_extraspace
        let barWidth = &columns - takenwidth
        let barWidth = barWidth < 3 ? 3 : barWidth

        if line('$') > 1
            let progress = (line('.')-1) * (barWidth-1) / (line('$')-1)
        else
            let progress = barWidth/2
        endif

        if barWidth <=6
            let bar = '[%p%%]'
        else
            let bar = ' [%0*%'.barWidth.'.'.barWidth.'('.repeat('-',progress ).'%0*0%0*'.repeat('-',barWidth - progress - 1).'%0*%)%<]'
        endif

        return stl.bar
    endfun

    let stl_extraspace = 0 " You can set this global variable in order to limit the
    " space of the statusline. This is useful in case you
    " have several windows open with vertical splits

    set stl=%!STL()       " (when starting in console mode)
endif
" I also want special formatting of the scroll bar
set highlight+=sr
set highlight+=Sr
set laststatus=2

" set the terminal title
set title
set titleold=xterm

" show cursor line and column, if no statusline
set ruler

" shorten command-line text and other info tokens
set shortmess=atI

" don't jump between matching brackets while typing
set noshowmatch

" display mode INSERT/REPLACE/...
set showmode


" remember more commands and search patterns
set history=1000

" changes special characters in search patterns (default)
" set magic

" define some listchars, but keep 'list' disabled by default
set lcs=tab:>-,trail:-,nbsp:~
set nolist

" Required to be able to use keypad keys and map missed escape sequences
set esckeys

" get easier to use and more user friendly Vim defaults
" CAUTION: This option breaks some vi compatibility.
"          Switch it off if you prefer real vi compatibility
set nocompatible

" Enabled XSMP connection. This seems to enable the X clipboard when vim
" is called with the -X option
call serverlist()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Complete longest common string, then each full match
" (bash compatible behavior)
set wildmode=longest,full

" No bells
set noerrorbells
if has('autocmd')
  autocmd GUIEnter * set vb t_vb=
endif

" Show Buffer Tabs
set showtabline=1               "Display the tabbar if there are multiple tabs. Use :tab ball or invoke Vim with -p
set hidden                      "allows opening a new buffer in place of an existing one without first saving the existing one

" Search the first 5 lines for modelines
set modelines=5

" Folding settings
set nofoldenable " Don't show folds by default
autocmd BufWinLeave ?* mkview          " Store fold settings for all buffers ...
"autocmd BufWinEnter ?* silent loadview " ... and reload them


" Taglist plugin
let Tlist_Inc_Winwidth = 0 " Don't enlarge the terminal
if has("gui_running")
        " In gvim, we don't need any specials for the taglist.
        noremap <silent> <leader>t :TlistToggle<CR><C-W>h
    else
        " in the console version, however, I need to take into account my
        " personal STL
        let TlistIsOpen = 0 " personal variable: keep track if Taglist is open or not
        function MyTlistToggle()
            " This function is supposed to resize my personal status line in order to
            " make room for the Tag List
            let g:TlistIsOpen = !(g:TlistIsOpen)
            if g:TlistIsOpen
                let g:stl_extraspace = g:stl_extraspace + g:Tlist_WinWidth
            else
                let g:stl_extraspace = g:stl_extraspace - g:Tlist_WinWidth
            endif
            TlistToggle " This is the command provided by the plugin itself
        endfunction
        noremap <silent> <leader>t :call MyTlistToggle()<CR><C-W>h
endif


" Nerd_commenter plugin
let g:NERDShutUp = 1

" Activate 256 colors independently of terminal. Most of my terms are 256
" colors. For those cases where I'm running vim in a low-color terminal, this
" is only safe if I'm using screen (which I always am).
set t_Co=256

" Default Color Scheme
colorscheme goerz
autocmd FileType tex hi! texSectionTitle gui=bold term=bold cterm=bold
autocmd FileType tex hi! Statement gui=none term=none cterm=none

" Send plugin
nmap <leader>s :. python send()<cr>
vmap <leader>s : python send()<cr>gv<esc>

" abbreviations
if exists("*strftime")
    iab xxxtimestamp <c-r>=strftime("%a %D %H:%M:%S %Z")<cr>
endif

" * Text Formatting -- General {{{1

" don't make it look like there are line breaks where there aren't:
set nowrap

" tab stops should be at 4 spaces
set tabstop=4

" use indents of 4 spaces:
set shiftwidth=4
set shiftround
set expandtab
set noautoindent

" don't break text by default:
set formatoptions=tcql
set textwidth=0

" My default language is American English
set spelllang=en_us

" LaTeX: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*

" Use # without VIM moving it to the first column
inoremap # X<C-H>#

" Temporary files
set wildignore+=*.o,*.obj
set wildignore+=*.bak,*~,*.tmp,*.backup


" Printing settings
set printoptions=paper:a4,number:y,left:25pt,right:40pt


" * Text Formatting -- Specific File Formats {{{1

" enable filetype detection:
filetype plugin on
filetype plugin indent on

augroup filetype
  autocmd BufNewFile,BufRead */.Postponed/* set filetype=mail textwidth=71
  autocmd BufNewFile,BufRead *.txt set filetype=human
  autocmd BufNewFile,BufRead *.mail set filetype=mail
  autocmd BufNewFile,BufRead *mailplane* set filetype=mail
  autocmd BufNewFile,BufRead *.wordpress set filetype=html
  autocmd BufNewFile,BufRead *.fionacms set filetype=html
  autocmd BufNewFile,BufRead *.tikz set filetype=plaintex
  autocmd BufNewFile,BufRead README.* set filetype=human
  autocmd BufNewFile,BufRead INSTALL set filetype=human
  autocmd BufNewFile,BufRead *vimperatorrc*,*.vimp set filetype=vimperator
  autocmd BufNewFile,BufRead *.viki set filetype=viki
augroup END

" For some programming languages, delete trailing spaces on save
autocmd BufWritePre *.py normal m`:%s/\s\+$//e ``
autocmd BufWritePre *.pl normal m`:%s/\s\+$//e ``

" Viki bugfix
" Remove space from vikiMapKeys, which causes abbreviations not to work. Must
" be set befor the viki plugin is loaded, i.e. here.
let g:vikiMapKeys = "]).,;:!?\"'"


" * Set terminal specific key mappings {{{1

" Try to get the correct main terminal type
if &term =~ "xterm"
    let myterm = "xterm"
else
    let myterm =  &term
endif
let myterm = substitute(myterm, "cons[0-9][0-9].*$",  "linux", "")
let myterm = substitute(myterm, "vt1[0-9][0-9].*$",   "vt100", "")
let myterm = substitute(myterm, "vt2[0-9][0-9].*$",   "vt220", "")
let myterm = substitute(myterm, "\\([^-]*\\)[_-].*$", "\\1",   "")

" Here we define the keys of the NumLock in keyboard transmit mode of xterm
" which misses or hasn't activated Alt/NumLock Modifiers.  Often not defined
" within termcap/terminfo and we should map the character printed on the keys.
if myterm == "xterm" || myterm == "kvt" || myterm == "gnome"
    " keys in insert/command mode.
    map! <ESC>Oo  :
    map! <ESC>Oj  *
    map! <ESC>Om  -
    map! <ESC>Ok  +
    map! <ESC>Ol  ,
    map! <ESC>OM  
    map! <ESC>Ow  7
    map! <ESC>Ox  8
    map! <ESC>Oy  9
    map! <ESC>Ot  4
    map! <ESC>Ou  5
    map! <ESC>Ov  6
    map! <ESC>Oq  1
    map! <ESC>Or  2
    map! <ESC>Os  3
    map! <ESC>Op  0
    map! <ESC>On  .
    " keys in normal mode
    map <ESC>Oo  :
    map <ESC>Oj  *
    map <ESC>Om  -
    map <ESC>Ok  +
    map <ESC>Ol  ,
    map <ESC>OM  
    map <ESC>Ow  7
    map <ESC>Ox  8
    map <ESC>Oy  9
    map <ESC>Ot  4
    map <ESC>Ou  5
    map <ESC>Ov  6
    map <ESC>Oq  1
    map <ESC>Or  2
    map <ESC>Os  3
    map <ESC>Op  0
    map <ESC>On  .
endif

" xterm but without activated keyboard transmit mode
" and therefore not defined in termcap/terminfo.
if myterm == "xterm" || myterm == "kvt" || myterm == "gnome"
    " keys in insert/command mode.
    map! <Esc>[H  <Home>
    map! <Esc>[F  <End>
    " Home/End: older xterms do not fit termcap/terminfo.
    map! <Esc>[1~ <Home>
    map! <Esc>[4~ <End>
    " Up/Down/Right/Left
    map! <Esc>[A  <Up>
    map! <Esc>[B  <Down>
    map! <Esc>[C  <Right>
    map! <Esc>[D  <Left>
    " KP_5 (NumLock off)
    map! <Esc>[E  <Insert>
    " PageUp/PageDown
    map <ESC>[5~ <PageUp>
    map <ESC>[6~ <PageDown>
    map <ESC>[5;2~ <PageUp>
    map <ESC>[6;2~ <PageDown>
    map <ESC>[5;5~ <PageUp>
    map <ESC>[6;5~ <PageDown>
    " keys in normal mode
    map <ESC>[H  0
    map <ESC>[F  $
    " Home/End: older xterms do not fit termcap/terminfo.
    map <ESC>[1~ 0
    map <ESC>[4~ $
    " Up/Down/Right/Left
    map <ESC>[A  k
    map <ESC>[B  j
    map <ESC>[C  l
    map <ESC>[D  h
    " KP_5 (NumLock off)
    map <ESC>[E  i
    " PageUp/PageDown
    map <ESC>[5~ 
    map <ESC>[6~ 
    map <ESC>[5;2~ 
    map <ESC>[6;2~ 
    map <ESC>[5;5~ 
    map <ESC>[6;5~ 
endif

" xterm/kvt but with activated keyboard transmit mode.
" Sometimes not or wrong defined within termcap/terminfo.
if myterm == "xterm" || myterm == "kvt" || myterm == "gnome"
    " keys in insert/command mode.
    map! <Esc>OH <Home>
    map! <Esc>OF <End>
    map! <ESC>O2H <Home>
    map! <ESC>O2F <End>
    map! <ESC>O5H <Home>
    map! <ESC>O5F <End>
    " Cursor keys which works mostly
    " map! <Esc>OA <Up>
    " map! <Esc>OB <Down>
    " map! <Esc>OC <Right>
    " map! <Esc>OD <Left>
    map! <Esc>[2;2~ <Insert>
    map! <Esc>[3;2~ <Delete>
    map! <Esc>[2;5~ <Insert>
    map! <Esc>[3;5~ <Delete>
    map! <Esc>O2A <PageUp>
    map! <Esc>O2B <PageDown>
    map! <Esc>O2C <S-Right>
    map! <Esc>O2D <S-Left>
    map! <Esc>O5A <PageUp>
    map! <Esc>O5B <PageDown>
    map! <Esc>O5C <S-Right>
    map! <Esc>O5D <S-Left>
    " KP_5 (NumLock off)
    map! <Esc>OE <Insert>
    " keys in normal mode
    map <ESC>OH  0
    map <ESC>OF  $
    map <ESC>O2H  0
    map <ESC>O2F  $
    map <ESC>O5H  0
    map <ESC>O5F  $
    " Cursor keys which works mostly
    " map <ESC>OA  k
    " map <ESC>OB  j
    " map <ESC>OD  h
    " map <ESC>OC  l
    map <Esc>[2;2~ i
    map <Esc>[3;2~ x
    map <Esc>[2;5~ i
    map <Esc>[3;5~ x
    map <ESC>O2A  ^B
    map <ESC>O2B  ^F
    map <ESC>O2D  b
    map <ESC>O2C  w
    map <ESC>O5A  ^B
    map <ESC>O5B  ^F
    map <ESC>O5D  b
    map <ESC>O5C  w
    " KP_5 (NumLock off)
    map <ESC>OE  i
endif

if myterm == "linux"
    " keys in insert/command mode.
    map! <Esc>[G  <Insert>
    " KP_5 (NumLock off)
    " keys in normal mode
    " KP_5 (NumLock off)
    map <ESC>[G  i
endif

" This escape sequence is the well known ANSI sequence for
" Remove Character Under The Cursor (RCUTC[tm])
map! <Esc>[3~ <Delete>
map  <ESC>[3~    x

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

endif " has("autocmd")
