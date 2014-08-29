{ Mouse DLL for REXX. Re-written from Virtual Pascal example rexxext.pas,  }
{ but the useful new function retains only declarations and obvious code.  }
{ Also, original code has a name conflict w REXXUTIL that can disable it,  }
{ AND apparently initializing function name MUST BE AT MOST 8 characters . }
{ NOTE that testing inherently locks DLLs in memory and new runs require:  }
{ 1) renaming this file, 2) correspondingly changing name passed to        }
{ RexxRegisterFunctionDLL(), and 3) in REXX code, name of the DLL. Failing }
{ to change the three in exact correspondence produces false symptoms. And }
{ you're still nearly certain to reach a situation requiring a re-boot. -- }
{ BESIDES THAT, you must copy the new DLL to LIBPATH (though you can once  }
{ or twice get away with using current directory), and invoke REXX from    }
{ command line. Doesn't make for a fast test cycle. Might want to review   }
{ code with more than usual care.                           DGD 11-18-2009 }

Library mousdll;

{$CDecl+,OrgName+,H-,I-,S-,Delphi+,Use32+}
{NOTE: may be some^^tricky side effects if using huge strings.}

Uses Dos, OS2Base, Os2Def, Rexx, Strings;

{$LINKER
  DESCRIPTION      "REXXMOUS - DLL"
  DATA MULTIPLE NONSHARED

  EXPORTS
    CLICKPOS = ClickPos
    TESTFUNC = TestFunc
    MOUSINIT = MousInit
}

Const FunctionTable : Array[ 0..1 ] of pChar = ( 'ClickPos', 'TestFunc' );

var rc, mh: smallword;

{ VP's name of init function "SysLoadFuncs" like REXXUTIL is a BAD IDEA;    }
{ should have unique identifier. Effect was disabled all RexxUtil function. }
{ ALSO, appears that this MUST NOT EXCEED 8 characters, some quirk of REXX. }
{ (Yes, "SysLoadFuncs" is over that. Try to prove me wrong all you want.)   }

Function MousInit( FuncName: PChar; ArgC: ULong; Args: pRxString;
                   QueueName: pChar; Var Ret: RxString ): ULong; export;
Var j :Integer;

begin
Ret.strLength := 0;
If ArgC > 0 then MousInit := 40 { Do not allow parameters }
else begin
  For j := Low( FunctionTable ) to High( FunctionTable ) do
    RexxRegisterFunctionDLL( FunctionTable[j], 'REXXMOUS', FunctionTable[j] );
  MousInit := 0;
end;
rc := MouOpen(nil, mh); { NECESSARY! Nil means use default driver. }
end;

{ *************************************************************************** }
{ ClickPos, the new function. Returns to REXX a string to be parsed as four   }
{ words: "row col button timestamp". Coordinates are 0, 0 based text screen.  }
{ Button pressed is a single char: "1", "2", or "3" with standard numbering;  }
{ two at once seems entirely unreliable, and isn't necessary for my purposes, }
{ nor is button down status for dragging, but those are possible, see VP Help.}
{ Timestamp (milliseconds since start-up) is here only because VP call has it,}
{ but may be useful sometime.                                                 }
{ *************************************************************************** }

Function ClickPos( FuncName: PChar; ArgC: ULong; Args: pRxString;
                   QueueName: pChar; Var Ret: RxString ): ULong; export;

var mei: moueventinfo;
    row, col, bst, timst, res: string;  { NOTE: currently SHORT strings }
    n, wf: smallword;

begin
rc := MouReadEventQue(mei, wf, mh); { var wf = 0 means no wait }
if (mei.fs and 84) > 0 then begin
  str(mei.row, row);
  str(mei.col, col);
  if (mei.fs and 4) = 4 then bst := '1'
    else if (mei.fs and 16) = 16 then bst := '2'
      else if (mei.fs and 64) = 64 then bst := '3';
  str(mei.time, timst);
  res := row + ' ' + col + ' ' + bst + ' ' + timst;
  Ret.StrPtr := addr(res[1]);  { set pointer to past length byte }
  Ret.strLength := length( res ); { assumes short strings here }
end
else begin
  while mei.fs > 0 do begin  { read and ignore possibly many NON-events }
    rc := MouReadEventQue(mei, wf, mh);   {to clear the cursed queue }
  end;
  Ret.StrPtr := '0 0 0 0';  { fake up the zero result }
  Ret.strLength := strlen( Ret.StrPtr );
end;
ClickPos := 0;
end;

{ 2nd function is left only for example. }

Function TestFunc( Name: PChar; ArgC: ULong; Args: pRxString;
                   QueueName: pChar; Var Ret: RxString ): ULong; export;
begin
Ret.StrPtr := 'This is returned from test function.'; {NOTE a literal string }
Ret.strLength := strlen( Ret.StrPtr );   {doesn't require fiddling w address }
TestFunc := 0;
end;

initialization
end.
