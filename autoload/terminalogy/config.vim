function! terminalogy#config#getBasic() abort
    return terminalogy#util#getSetting('basic', {})
endfunction

function! terminalogy#config#getTemplate(name) abort
    if has_key(b:, 'terminalogy_templates')
        if has_key(b:terminalogy_templates, a:name)
            return b:terminalogy_templates[a:name]
        endif
    endif
    return g:terminalogy_templates[a:name]
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
