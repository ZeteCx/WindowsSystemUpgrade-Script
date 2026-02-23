This is a very simple script that use winget and PSWindowsUpdate. I've made to deploay in a server farm context. Note that it can still be used run in a privilaged user enviorment.

Since winget cannot run in system context - it would locate the .exe and would execute it. 

Outside of it itll run windows update silently without any user intervention and without forcing restart on them.

Full disclosure: I used some AI and some help form the internet to modify this script.

If you would like to run it in server context - Run it with the following arguments: -NoProifle -ExecutionPoliciy Bypass -NonInteractive -WindowStyle Hidden 
