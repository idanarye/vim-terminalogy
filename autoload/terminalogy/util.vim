function! terminalogy#util#getSetting(name, default) abort
    let l:fullName = 'terminalogy_'.a:name
    for l:dict in [b:, g:]
        if has_key(l:dict, l:fullName)
            return l:dict[l:fullName]
        endif
    endfor
    return a:default
endfunction

function! terminalogy#util#startsWith(str, prefix) abort
    if empty(a:prefix)
        return 1
    endif
    return a:str[:len(a:prefix) - 1] == a:prefix
endfunction

function! terminalogy#util#doCommands(commands) abort
    for l:command in a:commands
        unlet! l:result
        if type(l:command) == type('')
            execute l:command
        elseif type(l:command) == type([])
            if type(l:command[0]) == type({})
                " First argument is object, second argument is method name,
                " other arguments are args
                let l:result = call(l:command[0][l:command[1]], l:command[2:], l:command[0])
            else
                let l:result = call(function('call'), l:command)
            endif
        else
            throw 'can not handle command '.string(l:command)
        endif
    endfor
    return get(l:, 'result')
endfunction

function! terminalogy#util#doInAnotherBuffer(bufnr, ...) abort
    let l:oldLazyredraw = &lazyredraw
    try
        let l:bufwin = bufwinnr(a:bufnr)
        if -1 < l:bufwin " Open in this tab
            let l:curwin = winnr()
            try
                wincmd p
                execute l:bufwin.'wincmd w'
                return terminalogy#util#doCommands(a:000)
            finally
                wincmd p
                execute l:curwin.'wincmd w'
            endtry
        else " not open in this tab - do in a temp tab
            let l:curTab = tabpagenr()
            let &lazyredraw = 1
            tabnew
            try
                execute 'buffer '.a:bufnr
                return terminalogy#util#doCommands(a:000)
            finally
                tabclose!
                execute 'tabnext '.l:curTab
            endtry
        endif
    finally
        let &lazyredraw = l:oldLazyredraw
    endtry
endfunction

function! terminalogy#util#catchAndPrintErrors(...) abort
    try
        return terminalogy#util#doCommands(a:000)
    catch /\v^\[TMLG].*/
        echohl Error
        echo v:exception[6:]
        echohl None
    endtry
endfunction

function! terminalogy#util#bufTabNr(bufnr)
    for l:tab in range(1, tabpagenr('$'))
        if -1 != index(tabpagebuflist(l:tab), a:bufnr)
            return l:tab
        endif
    endfor
    return -1
endfunction
