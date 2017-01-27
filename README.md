INTRODUCTION
============

Terminalogy is a plugin for embedding examples of shell commands in text. This
is a task one needs to do so when:

* Creating documentation/tutorials - you may want to give an example of what
  you just explained.
* Answering questions on Stack Overflow - show the asker an example of what
  you got when you ran it and explain how it should solve their case.
* Investigating tickets in a bug tracker - run the program with certain input,
  or grep/awk/sed/whatever the logs, and write it in the comments so that
  you(and others who loot at that ticket) will know what has already been
  investigated and what was found out.
  (BTW: this one is the original usecase that prompt me to create this plugin)

The usual way to do this is to run the command in a console - but then you
have to copy-paste it with your mouse...

Alternatively, one could write the command in Vim, and use `:range!` to run it
through a shell - but that's manual work, and it makes it hard to tweak with
the command to get the results you want...

Terminalogy allows you to tweak with the command in a Vim buffer, and with a
single key press see the results. When you are satisfied, close the buffer and
the command and it's output will be embedded to your original text.

KEY FEATURES
============

* Edit a command in one buffer, and see the output in another buffer.
* Automatically copy the command and output to your original text when you are
  done.
* Configure templates with arguments for commands you commonly use.
* Easily configure custom autocompletion for template arguments.
* Format the command and it's output before embedding it in the text(so that
  it'll be displayed properly with the target's markup).
