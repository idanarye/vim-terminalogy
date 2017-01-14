function! terminalogy#template#createTemplate(config) abort
    return extend(extend({}, s:base), a:config)
endfunction

let s:base = {
            \ 'linesAbove': [],
            \ 'prompt': '$ ',
            \ 'linesBelow': [],
            \ }

function! s:base.manipulateResultLines(lines) dict abort
    return self.linesAbove + a:lines + self.linesBelow
endfunction

function! s:base.insertResultLines(lines) dict abort
    call append(line('.'), self.manipulateResultLines(a:lines))
endfunction
