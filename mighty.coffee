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
  socket.on 'publish', (message) ->
    io.sockets.send message

  socket.on 'broadcast', (message) ->
    socket.broadcast.send message

  socket.on 'whisper', (message) ->
    socket.emit 'secret', message

