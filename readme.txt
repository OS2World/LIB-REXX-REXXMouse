Rexx Mouse DLL - Basic Text Window Mouse Interface - 11-18-2009 by DGD
Binaries and Virtual Pascal Source - Freeware for OS/2 and ECS systems only.

I've discovered several times that mouse support for plain text Rexx is so
near zero as to be zero. There's only one package on Hobbes that has any, and
it only returns which _line_ was clicked on. I suppose the notion falls into
the gulf between those who can use the command line and... the rest.

Anyway, _basic_ mousing is desperately needed for a (real, VIO, monospaced)
word processor that I'm working on, and so, in desperation, found instructions
on the web on building Rexx extension DLLs, and downloaded a shiny new copy of
Watcom 1.8 to compile the code. Unfortunately, the instructions were for the
Visual Age compiler, and I couldn't figure out the linking stage (though that
may change, intend to look at again), so went back to Virtual Pascal that DOES
have a working Rexx DLL example, I've just been ignoring it like everyone else
has. Looked like all I needed to do was the calls to get basic mouse data.

A few obstacles presented themselves. First, like all modern compilers, you
can't JUST access the mouse through the interrupt services. Well, you CAN, but
re-inventing that wheel, even with TP5 code handy, was about as difficult as
using a provided routine, once I had dug it out of the heap of units and
functions (there are at least THREE levels for getting mouse info). I chose
the mid-level because found it before the lowest, and the high level requires
more complications from a vast library. Soon had a working ordinary program to
test (included here), then learned what is meant by "MouReadEventQue": it
returns a STREAM of events reporting mere mouse motion, whether you want them
or not, and I didn't. After consideration, decided that would eventually be
polling and have to toss non-clicks anyway, so what was needed was to do most
of the tossing at compiled speed rather than in relatively slow Rexx code.
Came up with a simple way to discard all unwanted events. Fine. Arrange the
data into strings, ready to convert into DLL form. ... I omit MUCH trial and
error, most of it useless because Rexx DLLs are locked into memory and prevent
further testing unless extensive re-naming is done. -- Eventually got to a
version that at least ran, but shortly after, not only lost the exact
incantation but so confused the system that I couldn't use my ordinary Rexx
command line tools that rely on RexxUtil. It's not pleasant to re-boot this
system: have several torrents running that should be manually stopped, and a
balky but not flaky Seagate 250G drive adds nearly four minutes. Because of
the long painful re-boot cycle, spent more than usual time analyzing the
problem and looking for another option. Appears to be no way to get Rexx to
release a DLL except to re-boot (except maybe RexxUtil, but don't care, not
the problem). Then WASTED time because "prettied up" code toward final form,
unwittingly causing more trouble than all previous to even get back to working
at all. Rexx DLLs are a quite murky area, but I can now authoritatively state
two crucial points: DON'T use "SysLoadFuncs" for the name of initialization
function as the VP example code does (it works but inevitably conflicts with
RexxUtil), AND YOU CANNOT use a more than 8 character name for it, either,
interpreter just can't find it, despite that "SysLoadFuncs" has more than 8
chars, that's internal and highly misleading. -- But I do now have a real,
working, and even useful DLL that provides basic mouse function, all I need.

With the supplied rexxmous.dll in \os2\dll you can test in Rexx:
Run moustest.cmd from command line; should start making periods that show the
loop is running. A careful long click with the mouse dead still should give
position and button report, along with a large number for time stamp. Parse
the returned string in Rexx as four words. For button 2 (right), you may want
to turn off "Mouse Actions" from the VIO menu, but handily, it still passes
the info through, just pops up the distracting menu. Button 3 works normally,
but two at once isn't reliable, would require lengthy polling of status, so
I've skipped it.

You can build on the source code and add function. All you need is the Virtual
Pascal compiler and rudimentary programming ability. Pascal won't let you go
as far astray as C does, and operating the compiler itself is far less
confusing; its "Make" is quite streamlined.

Sadly, the Virtual Pascal site disappeared some time ago. But the last, Build
279 is still available for download from le g‚n‚reux Pascalophiles at:
http://pascal.developpez.com/compilateurs/vpascal/

Quick start for VP:
The VIO and PM versions operate alike. I now use the PM version, shows more
lines. Leave the compiler options alone unless QUITE expert; can easily get it
to an inoperable state. But I advise turning off syntax highlighting and other
unnecessarily colorful options of the editor. (Actually, I advise using any
other plain ASCII editor you're familiar with whenever possible. The TP/VP
editor has never pleased me and I avoid it until final stages of development.)
Now, its file selector is also horrible (imitated from at least TP5), but you
should be able to eventually find the files. Select "rexxmous.pas"; "Compile"
menu, "Make", or just hit F9. If we both haven't messed up environment from
the install, yours should report Success in the Message window. The new DLL
will be in \VP21\out.os2, and must be moved to \os2\dll before test.

That's about it. Turned out that I could do it, but had my doubts at times.
