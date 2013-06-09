" reproducable window height

" from tlib:
fun! Now() "{{{3
    let rts = 
    let rtl = split(rts, '\.')
    return rtl
endf
function! OutputAsList(command)
    let s:redir_lines = ''
    redir =>> s:redir_lines
    silent! exec a:command
    redir END
    return  split(s:redir_lines, '\n')
endf

fun! SameSize()
  set fdm=manual
  set nomodeline
  " set guifont='Fixed Semi-Condensed 8'
  if !has('gui_running')
    " don't know how to set width/height in terminal
    throw "should be using gui vim"
  endif
  set columns=100
  60 wincmd _
endf

fun! TestSynOnOff(syntax_file)
  for x in range(1,10)
    syn off
    syn on
    exec 'source '.a:syntax_file
    redraw!
  endfor
  " keep syn on so that you can visually control that everything is fine
endf

fun! TestScrolling(syntax_file)
  syn on
  exec 'source '.a:syntax_file

  for i in range(1, 1000 / line('$'))
    normal gg
    " scroll down
    while line('.') < line('$')
      exec "normal \<c-d>"
      normal j
      redraw!
    endwhile
  endfor
endf

fun! SimpleSynBenchmark(syntax_file, ...)
  let report_file = a:0 > 0 ? a:1 : ""

  if report_file != ""
    :syntime on
  endif
  call SameSize()

  let s = reltimestr(reltime())
  " call TestSynOnOff(a:syntax_file)
  call TestScrolling(a:syntax_file)
  let e = reltimestr(reltime())

  exec 'let d = '.e.' - '.s
  if report_file != ""
    call writefile(OutputAsList('syntime report'), report_file)
  endif
  return d
endf

fun! AutomaticTest(engine, extra_setup, file, syntax_file, outfile, report_file)
  if a:engine == 1
    exec 'set regexpengine='.a:engine
  elseif a:engine == 2
    " Vim should do what it thinks is best
  endif
  " read filse this way, preventing modeline etc, no folding
  enew
  call append('$', readfile(expand(a:file)))
  syn on
  if a:extra_setup != ''
    exec 'source '.a:extra_setup
  endif
  let d = SimpleSynBenchmark(a:syntax_file, a:report_file)
  call writefile([string(d)], a:outfile)
endf
