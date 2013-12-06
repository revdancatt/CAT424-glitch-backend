app = require("express")()
server = require("http").createServer(app)
io = require("socket.io").listen(server)
colours = require('colors')

io.enable('browser client minification');
io.enable('browser client etag');
io.enable('browser client gzip');
io.set('log level', 1);

io.set('transports', [
    'websocket'
  , 'flashsocket'
  , 'htmlfile'
  , 'xhr-polling'
  , 'jsonp-polling'
]);


colours.setTheme({
  info: 'green',
  data: 'grey',
  help: 'cyan',
  warn: 'yellow',
  debug: 'blue',
  error: 'red',
  alert: 'magenta'
})


console.log('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'.rainbow)


app.get "/", (req, res) ->
    res.sendfile __dirname + "/index.html"

control = 
    usernames: {}
    usernames_list: []
    rooms: {}
    rooms_list: []

setInterval (->

    for room in control.rooms_list
        users = {}
        for user in control.rooms[room].users_list
            users[user] = 
                x: control.usernames[user].position.x
                y: control.usernames[user].position.y
                facing: control.usernames[user].position.facing
        try
            io.sockets.in(room).emit('positions', users)
), 1000

#  Make the sockets thing
io.sockets.on "connection", (socket) ->
  
    # When a player joins a room
    socket.on "adduser", (username, room, x, y, facing) ->

        #   make sure name is unique
        orginalName = username
        counter = 1
        while username in control.usernames_list
            username = orginalName + counter
            counter++
    
        #  Store the username and the room
        socket.username = username
        control.usernames[username] =
            position:
                x: x
                y: y
                facing: facing
            room: room
        if username not in control.usernames_list
            control.usernames_list.push username

        socket.room = room
        socket.join(room)

        if room not in control.rooms_list
            control.rooms_list.push room

        if room not of control.rooms
            control.rooms[room] =
                users_list: []
            control.rooms[room].users_list.push username
        else
            if username not in control.rooms[room].users_list
                control.rooms[room].users_list.push username



    #   When the user joins a new room we need
    #   to remove them from the old room and
    #   put them in the new room, and we'll have a new
    #   x,y co-ord
    socket.on "joinroom", (room, x, y, facing) ->

        #   remove the user from the old room
        control.rooms[socket.room].users_list = control.rooms[socket.room].users_list.filter (x) -> x isnt socket.username

        #   If there are no users left in the old room then
        #   we can remove it from the dict and array
        if control.rooms[socket.room].users_list.length is 0
            delete control.rooms[socket.room]
            control.rooms_list = control.rooms_list.filter (x) -> x isnt socket.room

        #   Tell the old room the user has left
        io.sockets.in(socket.room).emit('leaveRoom', socket.username)

        #   Put the user into the new room
        socket.leave(socket.room)
        socket.room = room
        socket.join(socket.room)
        if room not of control.rooms
            control.rooms[room] =
                users_list: []
            control.rooms[room].users_list.push(socket.username)
        else
            if socket.username not in control.rooms[room].users_list
                control.rooms[room].users_list.push socket.username

        #   add the room to the rooms array if it's not
        #   already in there
        if room not in control.rooms_list
            control.rooms_list.push room

        #   update the user details
        control.usernames[socket.username].room = room
        control.usernames[socket.username].position.x = x
        control.usernames[socket.username].position.y = y
        control.usernames[socket.username].position.facing = facing


    socket.on "disconnect", () ->

        #   remove the user from the room
        control.rooms[socket.room].users_list = control.rooms[socket.room].users_list.filter (x) -> x isnt socket.username

        #   If there are no users left in the old room then
        #   we can remove it from the dict and array
        if control.rooms[socket.room].users_list.length is 0
            delete control.rooms[socket.room]
            control.rooms_list = control.rooms_list.filter (x) -> x isnt socket.room

        #   remove the user from the user list
        control.usernames_list = control.usernames_list.filter (x) -> x isnt socket.username
        delete control.usernames[socket.username]

        io.sockets.in(socket.room).emit('leaveRoom', socket.username)
        
        socket.leave(socket.room)

    socket.on "changeName", (newName) ->

        #   1st clean up the name
        newName = newName.replace(/\ /g, '_').replace(/[^a-zA-Z 0-9 ]+/g,'')
        return if newName is socket.username
        return if newName is ''

        #   make sure name is unique
        orginalName = newName
        counter = 1
        while newName in control.usernames_list
            newName = orginalName + counter
            counter++

        #   remove the old name from the username_list and
        #   add the new one
        control.usernames_list = control.usernames_list.filter (x) -> x isnt socket.username
        control.usernames_list.push newName
        control.usernames[newName] = control.usernames[socket.username]
        delete control.usernames[socket.username]
        #   Update the room user list
        control.rooms[socket.room].users_list = control.rooms[socket.room].users_list.filter (x) -> x isnt socket.username
        control.rooms[socket.room].users_list.push newName

        #   Tell everyone in the room than a name has changed
        oldName = socket.username
        socket.username = newName
        io.sockets.in(socket.room).emit('changeName', oldName, newName)


    socket.on "setPosition", (position) ->

        if socket.username of control.usernames
            control.usernames[socket.username].position = position

    #   Local chat
    socket.on "localChat", (msg) ->

        io.sockets.in(socket.room).emit('localChat', socket.username, msg)

    #   global chat
    socket.on "globalChat", (msg) ->

        io.sockets.emit('globalChat', socket.username, msg)


server.listen 8282
