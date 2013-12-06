CAT424-glitch-backend
=====================

![Landscape](http://revdancatt.github.io/CAT422-glitch-location-viewer/img/landscape1.jpg)

This code is the backend server for the MVURXI Glitch "chat-room-game". You can "play/chat" here: http://mvurxi.com

Read more on the [Dev Blog](http://blog.mvurxi.com).

This code works in two parts, this is the backend Node server running socket.io, you'll need to run `npm install` to install the modules, and Coffee to compile from CoffeeScript to .js. Then run with...

`node server.js`

The other part is the front end, which you can find here: https://github.com/revdancatt/CAT422-glitch-location-viewer

You'll need to edit the code in `index.html` to point to your own backend.

## NOTE


This is all very experimental and not meant to be a _robust_ client/server set-up, it's just a rough proof of concept, or interesting code to dig through if you want to see some socket.io stuff in action.

There are a few hacks in there and you wouldn't want to run this in production.

## TODO

* Break out various bits of the code into their own files to improve the structure of the code
* Clean up the code so the logic makes a bit more sense
* Bit of optimisation
* Move the model towards using userId and roomId rather than the actual names and labels
* Server broadcasts when a user joins/exits a room
* "God" broadcast if the server needs to come down
* Glitch time/date broadcast
* Allow the client to get a list of locations where users currently are
* Lots more stuff

## Contact

Say "Hi" [@revdancatt](http://twitter.com/revdancatt)

## License

The sever code has a GNU GENERAL PUBLIC LICENSE.

