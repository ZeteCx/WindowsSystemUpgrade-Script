This script utilises Winget and PSWindowsUpdate to deploy in a server farm context.
It can be used in a privileged user environment.

Winget cannot usually run in a system context, so this script resolves that issue by locating the .exe required and executing it.
This will silently and headlessly update windows without user intervention, and more importantly, without forcing a restart.

Full disclosure: AI was partly used in order to assist me in the creation of this script.
If you would like to run this script in a server context, please use the following arguments:

-NoProfile -ExecutionPoliciy Bypass -NonInteractive -WindowStyle Hidden 
