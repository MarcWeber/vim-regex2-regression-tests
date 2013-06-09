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
  " set guifont='Fixed Semi-Condensed 8'
  if !has('gui_running')
    " don't know how to set width/height in terminal
    throw "should be using gui vim"
  endif
  set columns=100
  60 wincmd _
endf

fun! SimpleSynBenchmark(...)
  let report_file = a:0 > 0 ? a:1 : ""

  if report_file != ""
    :syntime on
  endif
  call SameSize()
  normal gg

  let s = reltimestr(reltime())
  " scroll down
  while line('.') < line('$')
    normal j
    redraw
  endwhile
  let e = reltimestr(reltime())

  exec 'let d = '.e.' - '.s

  if report_file != ""
    call writefile(OutputAsList('syntime report'), report_file)
  endif
  return d
endf

fun! AutomaticTest(engine, extra_setup, file, syntax_file, outfile, report_file)
  exec 'set regexpengine='.a:engine
  " read filse this way, preventing modeline etc, no folding
  enew
  call append('$', readfile(expand(a:file)))
  syn on
  exec 'source '.a:syntax_file
  if a:extra_setup != ''
    exec 'source '.a:extra_setup
  endif
  let d = SimpleSynBenchmark(a:report_file)
  call writefile([string(d)], a:outfile)
endf
