/* Test the REXX functions in REXXMOUS.DLL */

say 'Assuming you put rexxmous.dll somewhere in LIBPATH, should now load.'

call rxfuncadd 'MousInit', 'RexxMous', 'MousInit'
call MousInit /* may find it useful to comment out during testing, */
  /* for error when get dlls stuck in memory with same function name */

say 'The test function returns "'TestFunc()'"'

do forever
  p= ClickPos()
  if p <> '0 0 0 0' then call charout, ' Pos:"'||p||'" '
    else call charout, '.'
  call syssleep 0.2
end
exit

