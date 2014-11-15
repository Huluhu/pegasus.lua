socket = require 'socket'

DEFAULT_ERROR_MESSAGE = [[
    <!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN'
        'http://www.w3.org/TR/html4/strict.dtd'>
    <html>
    <head>
        <meta http-equiv='Content-Type' content='text/html;charset=utf-8'>
        <title>Error response</title>
    </head>
    <body>
        <h1>Error response</h1>
        <p>Error code: %(code)</p>
        <p>Message: %(message).</p>
    </body>
    </html>
]]

DEFAULT_HEAD = 'HTTP/1.1 {{ STATUS_CODE }} OK\r\nContent-Type: text/html;charset=utf-8\r\n\r\n'

RESPONSES = {
    s200 = { code = '200', response = 'Continue' },
    s101 = 'Switching Protocols',
    s200 = 'OK',
    s201 = 'Created',
    s202 = 'Accepted',
    s203 = 'Non-Authoritative Information',
    s204 = 'No Content',
    s205 = 'Reset Content',
    s206 = 'Partial Content',
    s300 = 'Multiple Choices',
    s301 = 'Moved Permanently',
    s302 = 'Found',
    s303 = 'See Other',
    s304 = 'Not Modified',
    s305 = 'Use Proxy',
    s307 = 'Temporary Redirect',
    s400 = 'Bad Request',
    s401 = 'Unauthorized',
    s402 = 'Payment Required',
    s403 = 'Forbidden',
    s404 = { code = '404', response = 'Not Found' },
    s405 = 'Method Not Allowed',
    s406 = 'Not Acceptable',
    s407 = 'Proxy Authentication Required',
    s408 = 'Request Time-out',
    s409 = 'Conflict',
    s410 = 'Gone',
    s411 = 'Length Required',
    s412 = 'Precondition Failed',
    s413 = 'Request Entity Too Large',
    s414 = 'Request-URI Too Large',
    s415 = 'Unsupported Media Type',
    s416 = 'Requested range not satisfiable',
    s417 = 'Expectation Failed',
    s500 = 'Internal Server Error',
    s501 = 'Not Implemented',
    s502 = 'Bad Gateway',
    s503 = 'Service Unavailable',
    s504 = 'Gateway Time-out',
    s505 = 'HTTP Version not supported',
}

function fileOpen(filename)
    print(filename)
    local file = io.open(filename, 'r')

    if file then
        return file:read('*all')
    end

    return nil
end

HTTPServer = {}

function HTTPServer:new(port)
    local self = {}
    self.port = port or '9090'
    setmetatable(self, { __index = HTTPServer })

    return self
end

function HTTPServer:bind()
    local server = assert(socket.bind("*", self.port))
    local ip, port = server:getsockname()
    print("Server is up on port " .. self.port)

    while 1 do
        self.client = server:accept()
        self.client:settimeout(10)

        local line, err = self.client:receive()
        local isValid = not err

        if isValid then
            self:doGET(line)
        end

        self.client:close()
    end
end

function HTTPServer:doGET(line)
    self:parser(line, 'GET')
end

function HTTPServer:parser(line, method)
    local filename = '.' .. string.match(line, '^GET%s(.*)%sHTTP%/[0-9]%.[0-9]')
    local response = fileOpen(filename)

    if response then
        self:sendContent(response, '200')
        return
    end

    self:sendContent(DEFAULT_ERROR_MESSAGE, '400')
end

function HTTPServer:sendContent(response, statusCode)
    local head = string.gsub(DEFAULT_HEAD, '{{ STATUS_CODE }}', statusCode)
    local content = head .. response

    self.client:send(content)
end

function HTTPServer:sendHead()

end

function HTTPServer:sendResponse()
    
end

http = HTTPServer:new('9090')
http:bind()