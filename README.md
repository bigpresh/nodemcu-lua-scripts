# nodemcu Lua scripts

This is a repository of my Lua scripts for my NodeMCU ESP8266 devices.

So far, most of this is just stuff I've written for my own use, but figured it *might* be of use to others, so shared it here.

If you find it useful, I'd very much appreciate hearing from you.

## Usage

`init.lua` does as little as possible beyond outputting a little information
about the ESP module, then loading `wifi.lua` (to establish a wifi connection)
and `system.lua` (your actual app code) - but gives you a delay first in which you can connect over the serial link and say "abort=true" to stop it from
proceeding, or nowifi=true to skip wifi initialialsation.

The reason for this separation, beyond making the code cleaner and reusable,
is that if all your code is in init.lua and you make a mistake, you can get
stuck in a reboot loop where you don't have a chance to upload a fixed file,
and have to erase and reflash the module.  This separation means that if
you make a mistake in your system.lua, you can upload a fixed one easily.
