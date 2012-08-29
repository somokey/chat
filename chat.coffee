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
  socket.store.data.nickname = '손님' + Math.floor(Math.random() * 100)
  socket.store.data.avatar = '00'

  io.sockets.emit 'user connected'

  socket.on 'publish', (message) ->
    socket.get 'avatar', (err, avatar) ->
      socket.get 'nickname', (err, nickname) ->
        io.sockets.emit 'publish',
          avatar: avatar
          nickname: nickname
          message: message

  socket.on 'nick', (nickname) ->
    socket.store.data.nickname = nickname
    io.sockets.emit 'user changed nickname'

  socket.on 'avatar', (avatar) ->
    socket.store.data.avatar = avatar
    io.sockets.emit 'user changed avatar'

  socket.on 'who', () ->
    res = for own key, client of io.sockets.clients()
      avatar: client.store.data.avatar
      nickname: client.store.data.nickname
    socket.emit 'who', res

  socket.on 'broadcast', (message) ->
    socket.broadcast.send message

  socket.on 'whisper', (message) ->
    socket.emit 'secret', message

  socket.on 'disconnect', () ->
    io.sockets.emit 'user disconnected',