{ Test mousing in VP21; all I want is position of button click on text screen. 
As always when using supplied proc's, turns out more complex and clumsy than
desired. End purpose is to write a .DLL for use with REXX. }

USES Dos, Crt, OS2Base, Strings;

var mei: moueventinfo;
    smx, smy, bst, timst: string;
    n, rc, wf, mh: smallword;

{ INFO extracted from VP21 Help ... are other proc's in OPRO, but WORSE
MouEventInfo = record
  fs:         SmallWord;      // Event bits
  Time:       ULong;          // Event timestamp (unique number of milliseconds)
  Row:        SmallWord;      // Pointer current row position
  Col:        SmallWord;      // Pointer current column position
end;

function MouReadEventQue(var Event: MouEventInfo;
  var WaitFlag: SmallWord; MouHandle: SmallWord): ApiRet16;

function MouOpen(DriverName: PChar; var MouHandle: SmallWord): ApiRet16;

function MouClose(MouHandle: SmallWord): ApiRet16;

Major problem is RETURNS NOISE OF MERE MOUSE MOTIONS with "event queue". GRRR.
Using the event mask DOES NOT dodge it returning all "events". Since purpose is
.DLL for (relatively slow) REXX, that'd impose a HIGH overhead from NON-events.
Therefore, VP code must check buttons down, and toss the rest.
}

begin
  write ('Test mousing to report only clicks. - Exit with ctrl-c. ');
  rc := MouOpen(nil, mh); { NECESSARY! Nil means use default driver. }
  wf := 0;
  for n:= 1 to 10000 do begin
    rc := MouReadEventQue(mei, wf, mh); { var wf = 0 means no wait }
    if (mei.fs and 84) > 0 then begin
      str(mei.row, smx);
      str(mei.col, smy);
      if (mei.fs and 4) = 4 then bst := '1'
        else if (mei.fs and 16) = 16 then bst := '2'
          else if (mei.fs and 64) = 64 then bst := '3';
      str(mei.time, timst);
      write ('[', smx, ' ', smy, ' ', bst, ' ', timst, ']');
    end
    else begin
      while mei.fs > 0 do begin  { read and ignore the many NON-events }
        rc := MouReadEventQue(mei, wf, mh);
        write ('.');  { JUST to show SOMETHING is happening in here }
      end;
    end;
    delay(100);
  end;
  rc := MouClose(mh); { doesn't get here if exit with ctrl-c; no obvious drawback }
  write('Normal exit. Number of loops ran out.');
end.
