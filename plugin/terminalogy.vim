command! -complete=customlist,terminalogy#complete -nargs=* Terminalogy call terminalogy#util#catchAndPrintErrors([function('terminalogy#invoke'), [<f-args>]])
