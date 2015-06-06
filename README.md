# MailToMutt

A fork of MailToMutt from:

    http://mailtomutt.sourceforge.net

## Features

* Handles system wide mailto:
* Send mail using AppleScript with a single command 'mailto'
* Handles to,cc,bcc,subject, body and an attachment url
* Uses iTerm2 to display Mutt interactively
* Option for immediate sending without user interaction via send-now=yes in
  the mailto: url

## Caveats

This only works with Iterm2 at the moment.  It's possible to use Terminal, but the script that launches mutt must be changed in Mutt.m

## AppleScript

verb:
  `mailto`

parameter:
  `a valid mailto: url`

### Example

AppleScript Example:

    try
        tell application "/Applications/MailtoMutt.app"
            mailto "mailto:bogus@email.com?subject=test"
        end tell
    on error number -609
    end try

See the mailtomutt.scpt in the scripts folder.

## BusyCal Support

This supports sending mail with BusyCal.

You must create the following two directories:

    ~/Library/Application\ Scripts/com.busymac.busycal2
    ~/Library/Application\ Scripts/N4RA379GBW.com.busymac.busycal2.alarm

and add the script from the BusyCal directory into both of them.  Also, MailToMutt must be set as the default mail program for this to work.

## Known Issues

* MailToMutt will exit after call mutt and this gives a -609 error in the
case that it's called via AppleScript.  The workaround is to use a try,
end try block to quash the error. This error will not affect sending
mail.

