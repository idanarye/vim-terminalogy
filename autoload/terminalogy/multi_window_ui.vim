function! terminalogy#multi_window_ui#invoke(template, args) abort
    let l:terminalogy = copy(s:terminalogy)
    let l:terminalogy.template = a:template
    let l:terminalogy.origBuf = bufnr('')
    let l:terminalogy.origCursor = getcurpos()

    let l:command = a:template.formatInitialCommand(a:args)

    tabnew
    let l:uniqueId = bufnr('')
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal winfixheight
    execute 'silent file terminalogy:'.l:uniqueId.':command'
    let b:terminalogy = l:terminalogy
    let l:terminalogy.commandBuffer = bufnr('')
    autocmd BufDelete <buffer> call b:terminalogy.bufferExit()

    rightbelow new
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    execute 'silent file terminalogy:'.l:uniqueId.':result'
    let b:terminalogy = l:terminalogy
    let l:terminalogy.resultBuffer = bufnr('')
    autocmd BufDelete <buffer> call b:terminalogy.bufferExit()

    execute bufwinnr(l:terminalogy.commandBuffer).'wincmd w'
    resize 3

    nnoremap <buffer> <Cr> :call terminalogy#util#catchAndPrintErrors([b:terminalogy, 'run'])<Cr>
    inoremap <buffer> <Cr> <C-o>:call terminalogy#util#catchAndPrintErrors([b:terminalogy, 'run'])<Cr>

    call b:terminalogy.init(l:command)
endfunction

let s:terminalogy = {
            \ 'active': 1,
            \ }

function! s:terminalogy.init(command) dict abort
    if 1 == len(a:command)
        call setline(1, a:command[0])
    elseif 2 == len(a:command)
        call setline(1, a:command[0].a:command[1])
        call setpos('.', [0, line('.'), len(a:command[0]) + 1, 0])
        startinsert
    else
        throw 'command has '.len(a:command).' parts - only 1 or 2 are supported'
    endif

    call terminalogy#util#doInAnotherBuffer(self.resultBuffer,
                \ 'normal! "_ggdG',
                \ [function('setline'), [1, self.template.prompt]],
                \ )
endfunction

function! s:terminalogy.bufferExit() dict abort
    if !self.active
        " Function was already called, now it's automaticllay called on the other buffer
        return
    endif
    let self.active = 0
    let l:commandResult = getbufline(self.resultBuffer, 1, '$')
    call terminalogy#util#doInAnotherBuffer(self.origBuf,
                \ [function('cursor'), [self.origCursor[1:]]],
                \ [self.template, 'insertResultLines', l:commandResult],
                \ )
    for l:buf in [self.commandBuffer, self.resultBuffer]
        if l:buf != bufnr('')
            execute 'bd! '.l:buf
        endif
    endfor
endfunction

function! s:terminalogy.run() dict abort
    try
        let [l:command] = getbufline(self.commandBuffer, 1, '$')
    catch /E687/
        throw '[TMLG]Multiline commands are not supported'
    endtry
    call terminalogy#util#doInAnotherBuffer(self.resultBuffer,
                \ 'normal! "_ggdG',
                \ [function('setline'), [1, self.template.prompt.l:command]],
                \ 'normal! G',
                \ [function('append'), ['.', self.template.manipulateCommandBeforeSending(l:command)]],
                \ 'silent +1,$!'.&shell,
                \ )
endfunction
