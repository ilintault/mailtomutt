# mailtomutt

Version 0.5
-----------

Updated mailtomutt that  handles to,cc,bcc,subject,attachments, immediate sending and is applescript capable

Original MailToMutt is:

http://mailtomutt.sourceforge.net

# Caveats

This only works with Iterm2 at the moment.  It's possible to use Terminal, but the script that launches mutt must be changed in Mutt.m

# BusyCal Support

This supports sending mail with BusyCal.

You must create the following two directories:

~/Library/Application\ Scripts/com.busymac.busycal2
~/Library/Application\ Scripts/N4RA379GBW.com.busymac.busycal2.alarm

and add the script from the BusyCal directory into both of them.  Also, MailToMutt must be set as the default mail program for this to work.
