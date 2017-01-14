function! terminalogy#util#getSetting(name, default) abort
    let l:fullName = 'terminalogy_'.a:name
    if has_key(b:, l:fullName)
        return b:[l:fullName]
    elseif has_key(g:, l:fullName)
        return g:[l:fullName]
    else
        return a:default
    endif
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
            let l:result = call(function('call'), l:command)
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
