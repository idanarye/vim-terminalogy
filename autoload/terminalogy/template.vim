function! terminalogy#template#createTemplate(config) abort
    return extend(extend({}, s:base), a:config)
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
    return self.command
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
