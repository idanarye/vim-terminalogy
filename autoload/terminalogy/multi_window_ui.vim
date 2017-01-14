function! terminalogy#multi_window_ui#invoke(template, args)
    let l:terminalogy = copy(s:terminalogy)
    let l:terminalogy.template = a:template
    let l:terminalogy.origBuf = bufnr('')
    let l:terminalogy.origCursor = getcurpos()

    tabnew
    let l:uniqueId = bufnr('')
    setlocal buftype=nofile
    setlocal bufhidden=wipe
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

    nnoremap <buffer> <Cr> :call b:terminalogy.run()<Cr>
    inoremap <buffer> <Cr> <C-o>:call b:terminalogy.run()<Cr>

    call b:terminalogy.init()
endfunction

let s:terminalogy = {
            \ 'active': 1,
            \ 'command': '',
            \ }

function! s:terminalogy.init() dict abort
    call setline(1, self.command)
    call terminalogy#util#doInAnotherBuffer(self.resultBuffer,
                \ 'normal! ggdG',
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
                \ [self.template.insertResultLines, [l:commandResult], self.template],
                \ )
    for l:buf in [self.commandBuffer, self.resultBuffer]
        if l:buf != bufnr('')
            execute 'bd! '.l:buf
        endif
    endfor
endfunction

function! s:terminalogy.run() dict abort
    let [l:command] = getbufline(self.commandBuffer, 1, '$')
    call terminalogy#util#doInAnotherBuffer(self.resultBuffer,
                \ 'normal! ggdG',
                \ [function('setline'), [1, self.template.prompt.l:command]],
                \ 'normal! G',
                \ 'silent read! '.l:command,
                \ )
endfunction
