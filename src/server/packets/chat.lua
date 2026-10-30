
return function(content, ip, port)
    Server:sendAllExcept(ip, port, "CHAT|"..Server.clients[ip][port].name.."|"..content)
end
