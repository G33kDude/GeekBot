GeekBot
=======

The official bot of the [AutoHotkey IRC channel](https://autohotkey.com/boards/viewtopic.php?f=5&t=59).


Mentions:

* Documentation search function [courtesy of
	Run1e](https://autohotkey.com/boards/viewtopic.php?f=6&t=28677)


Installing under Linux
----------------------

1. Install a desktop environment (if one is not avaiable) for Wine/AHK to
   function correctly. The packages `xvfb` (X server), `fluxbox`
   (window manager), and `x11vnc` (optional VNC server) make for a lightweight,
   remotely accessible desktop.

2. Download and install the latest Wine (1.7 or greater) from WineHQ:
   https://www.winehq.org/download

3. Grab the [latest AutoHotkey](https://github.com/Lexikos/AutoHotkey_L/releases/latest).
   Portable U32 is preferred, and you can get a copy by:
   * Running the installer on a Windows system and choosing "extract to..."
   * Opening the installer in an archive manager which supports it (e.g. 7-Zip)
   * Downloading from https://autohotkey.com/download/

4. (Optional) Grab a copy of `screen` or `tmux` for remote shell management.


Running under Linux
-------------------

If your system doesn't boot into a desktop automatically, you will first
need to start a desktop environment.

1. Run `export DISPLAY=:0` to set the display for graphical programs to use.
2. Run `Xvfb -screen 0 800x600x24` to start the X server at 800x600 resolution
   with 24 bit colors.
3. Run `fluxbox` to start the window manager.
4. (Optional) Run `x11vnc -nopw -forever -shared -localhost` to start a VNC
   server. With these settings it will run indefinitely, but for security
   reasons it will only accept connections from localhost. Use SSH port
   forwarding to connect from a remote system.

Once the desktop has been set up, it's time to start the bot. If you're
starting the bot over SSH, make sure that the `DISPLAY` variable has been
exported appropriately (for `xvfb`, `export DISPLAY=:0` again).

To start the bot in the current shell session, use the command
`wine AutoHotkey.exe GeekBot.ahk`.

To start the bot in a new detachable session using `screen`, use the command
`screen -S geekbot -d -m wine AutoHotkey.exe GeekBot.ahk`. With this approach
you can terminate your SSH connection without terminating the bot.

To later attach to the `screen` session, use `screen -r geekbot`. To detach
from the session while you have it open, press `Control-a` followed by `d`.


Sandbox Plugins
---------------

The sandbox plugin allows you to run AutoHotkey code using chat commands.
It is disabled by default due to a number of security vulnerabilities,
but here's how to enable it anyway:

1. Download the sandbox dll from
   [here](http://www.golguppe.com/autohotkey/sandbox/ahksandboxansi.dll).
   (this link may change in the future)

2. Place it in a folder where it will not be moved. Moving the dll after
   retistration will break references stored in the registry which are
   not easy to fix.

3. 1. If using Windows, run `regsvr32 ahksandboxansi.dll` as admin.
   2. If using Wine, run `wine regsvr32 ahksandboxansi.dll` as normal user.

4. Move the sandbox plugin from the disabled plugin folder to the normal
   plugin folder.


The python sandbox plugin allows you to run Python3 code using chat commands.
It relies on an HTTP server written in python that wraps the excellent
sandboxing package `pypy-sandbox`. The server has to be running for the
plugin to work. To enable it, follow these steps:

1. Install the `pypy-sandbox` package for Python3.
2. Run the `PySandboxServer.py` file using Python3.
3. Move the python sandbox plugin from the disabled plugin folder to
   the normal plugin folder.


Notes
-----

* The first time you run GeekBot, a Settings.ini will be generated. Edit
  this file to enter your connection information and other settings.
