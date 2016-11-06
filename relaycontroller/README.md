# ESP8266 Relay control code

I've been using an ESP8266 to control my boiler with some crudely copy & pasted,
fairly low quality code I found.

I'm slowly starting to learn a bit of Lua, so wanted to throw together my own
code, which presents a web interface/API to control GPIO pins and also to be
able to read the current status of them, which the crude code I was using didn't
support.

## Usage

See the root of this repository for the `init.lua` file I use, which waits to
give you a chance to abort to avoid boot loops, then reads wifi config,
initiates connection, then processes this system.lua file.  Define the pin names
and numbers in a dictionary in `pins.lua`.

Upload all these files with `nodemcu-uploader`, or however you prefer.

Hitting up your ESP's IP should get you a web page listing each pin name you
configured, with links to turn it on, off and to fetch the status; the output
from each of those links is crude JSON, as they're intended to be used as an API
from other code, rather than directly.  (I may, one day, make the web page call
them via AJAX and show the result...)

## Feedback

I wrote this for my own use, but I want it under version control anyway
(obviously), so I may as well share it here in case anyone else finds it useful.

If you do, please feel free to give me feedback!

David Precious, davidp@preshweb.co.uk

