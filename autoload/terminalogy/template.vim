function! terminalogy#template#createTemplate(config) abort
    let l:template = extend(extend({}, s:base), a:config)
    let l:template.parsedCommand = terminalogy#template#parseCommandTemplate(l:template.command)
    return l:template
endfunction

let s:base = {
            \ 'linesAbove': [],
            \ 'command': '',
            \ 'prompt': '$ ',
            \ 'linesBelow': [],
            \ 'runInDir': '',
            \ 'implicitFilters': [],
            \ }

function! s:base.manipulateResultLines(lines) dict abort
    return self.linesAbove + a:lines + self.linesBelow
endfunction

function! s:base.insertResultLines(lines) dict abort
    call append(line('.'), self.manipulateResultLines(a:lines))
endfunction

function! s:base.formatInitialCommand(args) dict abort
    let l:result = ['']
    let l:idx = 0
    let l:unusedArgs = range(1, len(a:args))
    for l:part in self.parsedCommand
        if type(l:part) == type('')
            let l:result[l:idx] .= l:part
        elseif part.arg == 0
            if 0 != l:idx
                throw '[TMLG]Multiple \0 in the same command'
            endif
            let l:idx = 1
            call add(l:result, '')
        else
            if len(a:args) < l:part.arg
                throw '[TMLG]Argument #'.l:part.arg.' is missing'
            endif
            let l:unusedArgs[l:part.arg - 1] = 0
            let l:result[l:idx] .= a:args[l:part.arg - 1]
        endif
    endfor
    let l:unusedArgs = filter(l:unusedArgs, 'v:val')
    if !empty(l:unusedArgs)
        throw '[TMLG]Unused arguments: '.join(l:unusedArgs, ', ')
    endif
    return l:result
endfunction

function! s:base.manipulateCommandBeforeSending(command) dict abort
    let l:command = a:command
    if !empty(self.runInDir)
        let l:command = printf('cd %s; %s', shellescape(self.runInDir), l:command)
    endif
    for l:filter in self.implicitFilters
        let l:command = l:command.' | '.l:filter
    endfor
    return l:command
endfunction

function! terminalogy#template#parseCommandTemplate(expr) abort
    let l:expr = a:expr
    let l:result = []
    while 1
        let l:parts = matchlist(l:expr, '\v^(.{-})\\(\\|\d+)(.*)$')
        if empty(l:parts)
            call add(l:result, l:expr)
            return l:result
        endif
        call add(l:result, l:parts[1])
        if l:parts[2] == '\'
            call add(l:result, '\')
        else
            call add(l:result, {'arg': str2nr(l:parts[2])})
        endif
        let l:expr = l:parts[3]
    endwhile
endfunction
