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
    autocmd BufDelete <buffer> if exists('b:terminalogy') | call b:terminalogy.bufferExit() | endif

    rightbelow new
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    execute 'silent file terminalogy:'.l:uniqueId.':result'
    let b:terminalogy = l:terminalogy
    let l:terminalogy.resultBuffer = bufnr('')
    autocmd BufDelete <buffer> if exists('b:terminalogy') | call b:terminalogy.bufferExit() | endif

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
    if self.active
        " First window - prepare the object
        let self.active = 0
        if bufnr('') == self.commandBuffer
            let l:otherBufferToKill = self.resultBuffer
        elseif bufnr('') == self.resultBuffer
            let l:otherBufferToKill = self.commandBuffer
        else
            throw 'bufferExit() from wrong buffer'
        endif

        let self.commandResult = getbufline(self.resultBuffer, 1, '$')
        execute bufwinnr(l:otherBufferToKill).'wincmd w'
        " So that they won't be killed together(this cause bugs)
        autocmd WinEnter <buffer> if exists('b:terminalogy') | call b:terminalogy.bufferExit() | endif
    else
        " Second window - close it and write to original location
        bdelete!
        let l:origBufwin = bufwinnr(self.origBuf)
        if -1 < l:origBufwin " Open in this tab
            execute l:origBufwin.'wincmd w'
        else " not open in this tab - go to orig tab
            let l:buftab = terminalogy#util#bufTabNr(self.origBuf)
            if -1 < l:buftab
                execute l:buftab.'tabnext'
                execute bufwinnr(self.origBuf).'wincmd w'
            else
                " orig tab closed - do nothing
            endif
        endif

        if bufnr('') == self.origBuf
            call cursor(self.origCursor[1:])
            call self.template.insertResultLines(self.commandResult)
        endif
    endif
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
