util = require 'util'
express = require 'express'
app = express.createServer(express.logger())
port = process.env.PORT || 5000
io = require('socket.io').listen app

app.listen port

app.get '/', (req, res) ->
  res.sendfile __dirname + '/index.html'

io.configure () ->
  io.set 'transport', ['xhr-polling']
  io.set 'polling duration', 10

io.sockets.on 'connection', (socket) ->
  socket.set 'nickname', '손님' + Math.floor(Math.random() * 100)
  socket.set 'avatar', '00'

  socket.on 'publish', (message) ->
    socket.get 'avatar', (err, avatar) ->
      socket.get 'nickname', (err, nickname) ->
        io.sockets.emit 'publish',
          avatar: avatar
          nickname: nickname
          message: message

  socket.on 'nick', (nickname) ->
    socket.get 'nickname', (err, nickname_old) ->
      socket.set 'nickname', nickname, () ->
        socket.emit 'done'
        io.sockets.send util.format "%s renamed into %s.", nickname_old, nickname

  socket.on 'avatar', (avatar) ->
    socket.set 'avatar', avatar, () ->
      socket.emit 'done'

  socket.on 'who', () ->
    res = for own key, client of io.sockets.clients()
      nickname: client.store.data.nickname
    socket.emit 'who', res

  socket.on 'broadcast', (message) ->
    socket.broadcast.send message

  socket.on 'whisper', (message) ->
    socket.emit 'secret', message
