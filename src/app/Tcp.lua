local PacketBuffer = require("app.net.PacketBuffer")
local Protocol = require("app.net.Protocol")

local tcp = class("tcp")

function tcp:ctor()
    self._buf = PacketBuffer.new()
end

function tcp:onStatus(event)
    printInfo("socket status: %s", event.name)
end

function tcp:onConnected(event)
    display.getRunningScene().onTcpConnected(event)
end

function tcp:send(proto_id, msg)
    if not self._socket then
        printError("try to send before connect")
        return
    end

    local def = Protocol.getSend(proto_id)
    local buf = PacketBuffer.createPacket(def, msg)
    printInfo("send %u packet: %s", proto_id, buf:toString(16))
    self._socket:send(buf:getPack())
end

function tcp:onRecv(event)
    print("socket receive raw data:", cc.utils.ByteArray.toString(event.data, 16))
    local msgs = self._buf:parsePackets(event.data)
    local msg = nil
    for i=1,#msgs do
        msg = msgs[i]
    end
end

function tcp:connect(ip, port)
    if not self._socket then
        self._socket = cc.net.SocketTCP.new(ip, port, false)
        self._handles = {
            self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected)),
            self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self.onStatus)),
            self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self.onStatus)),
            self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onStatus)),
            self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self.onRecv)),
        }
    end
    self._socket:connect()
end

function tcp:disconnect()
    if not self._socket then
        printError("try to disconnect when not connected")
        return
    end

    for _, handle in self._handles do
        self._socket:removeEventListener(handle)
    end
    self._socket:disconnect()
end

return tcp:new()