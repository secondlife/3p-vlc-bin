Important: This file is not part of the VLC distribution.
It only serves to outline what is here and remind users
who want to update to different versions of VLC that the 
vendor branch strategy in use and should be followed.

------------------------------------------------------------
http://www.videolan.org/vlc/libvlc.html

VLC is a popular libre and open source media player and multimedia engine,
used by a large number of individuals, professionals, companies and
institutions. Using open source technologies and libraries, VLC has been
ported to most computing platforms, including GNU/Linux, Windows, Mac OS X,
BSD, iOS and Android.
VLC can play most multimedia files, discs, streams, allows playback from
devices, and is able to convert to or stream in various formats.
The VideoLAN project was started at the university École Centrale Paris who
relicensed VLC under the GPLv2 license in February 2001. Since then, VLC has
been downloaded close to one billion times.
------------------------------------------------------------

To update the version of VLC for a platform or bit-width:

* Visit http://download.videolan.org/pub/videolan/vlc/ and 
  find the version you want to import.

* Download it and decompress the resulting .7z file.
  Software available here: http://www.7-zip.org/

* Add the new code to the repository in the VENDOR branch as per the 
  Linden Lab Mercurial Vendor Branch Strategy outlined here:
  https://wiki.lindenlab.com/wiki/Mercurial_Vendor_Branches

* Merge with the default branch
