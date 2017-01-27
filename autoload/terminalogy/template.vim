function! terminalogy#template#createTemplate(config) abort
    let l:template = extend(extend({}, s:base), a:config)
    let l:template.parsedCommand = terminalogy#template#parseCommandTemplate(l:template.command)
    return l:template
endfunction

let s:base = {
            \ 'linesAbove': [],
            \ 'command': '\0',
            \ 'prompt': '$ ',
            \ 'linesBelow': [],
            \ 'indent': 0,
            \ 'runInDir': '',
            \ 'implicitFilters': [],
            \ }

function! s:base.manipulateResultLines(lines) dict abort
    let l:lines = a:lines
    if !empty(self.indent)
        if type(self.indent) == type(0)
            let l:indent = repeat(' ', self.indent)
        elseif type(self.indent) == type('')
            let l:indent = self.indent
        else
            throw 'Unsupported type for indent'
        endif
        let l:lines = map(copy(l:lines), 'l:indent.v:val')
    endif
    return self.linesAbove + l:lines + self.linesBelow
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
                throw 'Multiple \0 in the same command'
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
        if type(self.runInDir) == type('')
            let l:runInDir = self.runInDir
        elseif type(self.runInDir) == type(function('tr'))
            let l:runInDir = self.runInDir()
        else
            throw 'Unsupported type for runInDir'
        endif
        let l:command = printf('cd %s; %s', shellescape(l:runInDir), l:command)
    endif
    for l:filter in self.implicitFilters
        let l:command = l:command.' | '.l:filter
    endfor
    return l:command
endfunction

function! s:base.complete(args) dict abort
    let l:argNumber = len(a:args)
    if has_key(self, 'complete_'.l:argNumber)
        let l:Complete = get(self, 'complete_'.l:argNumber)
        if type(l:Complete) == type([])
            let l:result = l:Complete
        elseif type(l:Complete) == type(function('tr'))
            let l:result = call(l:Complete, [a:args], self)
        endif
    else
        let l:result = []
    endif
    return filter(copy(l:result), 'terminalogy#util#startsWith(v:val, a:args[-1])')
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
