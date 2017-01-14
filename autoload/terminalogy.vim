function! terminalogy#complete(argLead, cmdLine, cursorPos) abort
    let l:cmdLineBeforeCursor = a:cmdLine[:a:cursorPos - 1]
    let l:args = split(l:cmdLineBeforeCursor, '\v\\@<!(\\\\)*\zs\s+', 1)
    call remove(l:args, 0) " Remove the template's name
    if len(l:args) == 1
        return terminalogy#config#getNamesForCompletion(l:args[0])
    else
        let l:patternName = remove(l:args, 0)
        let l:template = terminalogy#config#getTemplate(l:patternName)
        if has_key(l:template, 'complete')
            return l:template.complete(l:args)
        else
            return []
        endif
    endif
endfunction

function! terminalogy#invoke(...) abort
    if 0 == a:0 " basic template
        let l:template = terminalogy#config#getBasic()
        let l:args = []
    else
        let l:template = terminalogy#config#getTemplate(a:000[0])
        let l:args = a:000[1:]
    endif
    let l:template = terminalogy#template#createTemplate(l:template)
    call terminalogy#multi_window_ui#invoke(l:template, l:args)
endfunction
