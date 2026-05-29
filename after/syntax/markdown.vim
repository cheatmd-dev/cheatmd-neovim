" Neovim/Vim syntax extension for CheatMD
" This file is automatically sourced after standard markdown syntax loading.

syn region cheatmdBlock start="<!--\s*cheat" end="-->" keepend contains=cheatmdKeyword,cheatmdComment,cheatmdVar,cheatmdOperator,cheatmdOption,cheatmdString
syn keyword cheatmdKeyword var import export chain if fi contained
syn match cheatmdComment "#.*$" contained
syn match cheatmdVar "\$[a-zA-Z_][a-zA-Z0-9_]*" contained
syn match cheatmdOperator "=\|:=\|==\|!=" contained
syn match cheatmdOption "--[a-zA-Z0-9_-]\+" contained

" Scopes double and single quoted strings inside options and highlight variables within them
syn region cheatmdString start='"' end='"' contained contains=cheatmdVar
syn region cheatmdString start="'" end="'" contained contains=cheatmdVar

" Highlight variable references ($name and <name>) inside markdown code blocks/prose
syn match cheatmdCodeVar "\$[a-zA-Z_][a-zA-Z0-9_]*"
syn match cheatmdCodeVar "<[a-zA-Z_][a-zA-Z0-9_]*>"

" Hook into Neovim's standard syntax groups
hi def link cheatmdBlock Comment
hi def link cheatmdKeyword Keyword
hi def link cheatmdComment Comment
hi def link cheatmdVar Identifier
hi def link cheatmdCodeVar Identifier
hi def link cheatmdOperator Operator
hi def link cheatmdOption Special
hi def link cheatmdString String
