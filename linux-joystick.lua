--A modification of the Luvit linux-joystick example code, altered for my own uses

local fs = require('fs')
local Emitter = require('core').Emitter
local Buffer = require('buffer').Buffer
--weblit = require('weblit-app')
-- https://www.kernel.org/doc/Documentation/input/joystick-api.txt
local function parse(buffer)
  local event = {
    time   = buffer:readUInt32LE(1),
    number = buffer:readUInt8(8),
--    value  = buffer:readUInt16LE(5),
    value  = buffer:readInt16LE(5),
  }
  local type = buffer:readUInt8(7)
  if bit.band(type, 0x80) > 0 then event.init = true end
  if bit.band(type, 0x01) > 0 then event.type = "button" end
  if bit.band(type, 0x02) > 0 then event.type = "axis" end
  return event
end

-- Expose as a nice Lua API
local Joystick = Emitter:extend()

function Joystick:initialize(id)
  self:wrap("onOpen")
  self:wrap("onRead")
  self.id = id
  fs.open("/dev/input/js" .. id, "r", "0644", self.onOpen)
end


function Joystick:onOpen(fd)
  print("fd", fd)
  self.fd = fd
  self:startRead()
end

function Joystick:startRead()
  fs.read(self.fd, 8, nil, self.onRead)
end

function Joystick:onRead(chunk)
  local event = parse(Buffer:new(chunk))
  event.id = self.id
  self:emit(event.type, event)
  if self.fd then self:startRead() end
end

function Joystick:close(callback)
  local fd = self.fd
  self.fd = nil
  fs.close(fd, callback)
end
--Arcane magic above, do not touch.
--------------------------------------------------------------------------------
local jsonStringify = require('json').stringify
local ffi = require("ffi")
jsButtons = {}
jsAxes = {}
jsSend = {}--Don't ask what i'm doing here.


js = Joystick:new(1)--Initialize Joystick zero


js:on("button",function (jBtn)--on button press, update the button's slot
  jsButtons[jBtn.number+1]=jBtn.value>0
  jsSend[2]=jsButtons
end)


js:on("axis",function (jAxis)--this will be useful later
  jsAxes[jAxis.number+1]=jAxis.value
  jsSend[1]=jsAxes
print(jAxis.number.." "..jAxis.value)
end)



require('weblit-websocket')
require('weblit-app')

.bind({
  host = "0.0.0.0",
  port = 8080
})
.use(require('weblit-logger'))
.use(require('weblit-auto-headers'))
.use(require('weblit-etag-cache'))

.websocket({
  path = "/",
}, function (req, read, write)
  p(req)
   print(jsonStringify(jsAxes))
    write({
      opcode = 2,
      payload = jsonStringify(jsSend)
    })
  for message in read do
    p(message)
    write({
      opcode = 2,
      payload = jsonStringify(jsSend)
    })
  end
  write()
end)

.start()
