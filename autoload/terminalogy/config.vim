function! terminalogy#config#getBasic() abort
    return terminalogy#util#getSetting('basic', {})
endfunction

function! terminalogy#config#getTemplate(name) abort
    for l:dict in [b:, g:]
        try
            " NOTE: Vimscript is a mess. If I'd just return it directly, it
            " wouldn't catch the exception...
            let l:result = l:dict.terminalogy_templates[a:name]
            return l:result
        catch /E716/
            " Key not present - just try the next one
        endtry
    endfor
    throw '[TMLG]Unknown template '.a:name
endfunction

function! terminalogy#config#getNamesForCompletion(prefix) abort
    let l:result = []
    for l:dict in [b:, g:]
        if has_key(l:dict, 'terminalogy_templates')
            for l:name in keys(l:dict.terminalogy_templates)
                if terminalogy#util#startsWith(l:name, a:prefix)
                    call add(l:result, l:name)
                endif
            endfor
        endif
    endfor
    return l:result
endfunction
