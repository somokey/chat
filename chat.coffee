util = require 'util'
express = require('express')
app = express()
server = require('http').createServer(app)
port = process.env.PORT || 5000
io = require('socket.io').listen server

server.listen port

app.get '/', (req, res) ->
  res.sendfile __dirname + '/index.html'
app.use express.static 'public'

#app.get '/1997.mp3', (req, res) ->
#  res.sendfile __dirname + '/1997.mp3'
#app.get '/1997.ogg', (req, res) ->
#  res.sendfile __dirname + '/1997.ogg'


io.sockets.on 'connection', (socket) ->
  socket.store = {}
  socket.store.data = {}

  socket.store.data.nickname = '손님' + Math.floor(Math.random() * 100)
  socket.store.data.avatar = '00'

  socket.broadcast.emit 'user connected'

  socket.on 'publish', (message) ->
    io.sockets.emit 'publish',
      avatar: socket.store.data.avatar
      nickname: socket.store.data.nickname
      message: socket.store.data.message

  socket.on 'nick', (nickname) ->
    socket.store.data.nickname = nickname
    io.sockets.emit 'user changed nickname'

  socket.on 'avatar', (avatar) ->
    socket.store.data.avatar = avatar
    io.sockets.emit 'user changed avatar'

  socket.on 'who', () ->
    res = for own key, otherSocket of io.sockets.sockets
      avatar: otherSocket.store.data.avatar
      nickname: otherSocket.store.data.nickname
    socket.emit 'who', res

  socket.on 'broadcast', (message) ->
    socket.broadcast.send message

  socket.on 'whisper', (message) ->
    socket.emit 'secret', message

  socket.on 'disconnect', () ->
    io.sockets.emit 'user disconnected',
