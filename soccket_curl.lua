-- ============================================
-- socket_curl.lua - Módulo de Rede via Curl
-- COMPLETO COM SUPORTE A TELEGRAM
-- Tudo via curl (sem FFI/socket)
-- ============================================

local M = {}

-- ============================================
-- CONFIGURAÇÃO DO TELEGRAM
-- ============================================

M.TOKEN = nil
M.CHAT_ID = nil

function M.setTelegram(token, chat_id)
    M.TOKEN = token
    M.CHAT_ID = chat_id
    print("✅ Telegram configurado!")
    return true
end

-- ============================================
-- 1. FUNÇÃO BÁSICA: EXECUTA CURL
-- ============================================

local function exec_cmd(cmd)
    local success, result = pcall(function()
        local f = io.popen(cmd .. " 2>/dev/null")
        if not f then return "" end
        local data = f:read("*a")
        f:close()
        return data or ""
    end)
    
    if not success then
        return ""
    end
    return result
end

local function exec_curl(cmd)
    return exec_cmd(cmd)
end

-- ============================================
-- 2. ENVIAR MENSAGEM PARA O TELEGRAM
-- ============================================

function M.send_message(text, token, chat_id)
    token = token or M.TOKEN
    chat_id = chat_id or M.CHAT_ID
    
    if not token or not chat_id then
        print("❌ Telegram não configurado! Use setTelegram()")
        return false, "Telegram não configurado"
    end
    
    text = text:gsub('"', '\\"')
    text = text:gsub("\n", "\\n")
    
    local cmd = 'curl -s -X POST "https://api.telegram.org/bot' .. token .. '/sendMessage" -H "Content-Type: application/json" -d \'{"chat_id": "' .. chat_id .. '", "text": "' .. text .. '"}\''
    local result = exec_curl(cmd)
    
    if result:find('"ok":true') then
        print("📨 Mensagem enviada!")
        return true, result
    else
        print("❌ Erro ao enviar mensagem")
        return false, result
    end
end

-- ============================================
-- 3. ENVIAR MENSAGEM FORMATADA (HTML)
-- ============================================

function M.send_html(text, token, chat_id)
    token = token or M.TOKEN
    chat_id = chat_id or M.CHAT_ID
    
    if not token or not chat_id then
        print("❌ Telegram não configurado!")
        return false
    end
    
    text = text:gsub('"', '\\"')
    text = text:gsub("\n", "\\n")
    
    local cmd = 'curl -s -X POST "https://api.telegram.org/bot' .. token .. '/sendMessage" -H "Content-Type: application/json" -d \'{"chat_id": "' .. chat_id .. '", "text": "' .. text .. '", "parse_mode": "HTML"}\''
    local result = exec_curl(cmd)
    
    if result:find('"ok":true') then
        print("📨 Mensagem HTML enviada!")
        return true
    else
        print("❌ Erro ao enviar HTML")
        return false
    end
end

-- ============================================
-- 4. ENVIAR ALERTA (TÍTULO + MENSAGEM)
-- ============================================

function M.send_alert(title, message, token, chat_id)
    local text = "🔔 <b>" .. title .. "</b>\n\n" .. message
    return M.send_html(text, token, chat_id)
end

-- ============================================
-- 5. ENVIAR FOTO
-- ============================================

function M.send_photo(photo_path, caption, token, chat_id)
    token = token or M.TOKEN
    chat_id = chat_id or M.CHAT_ID
    
    if not token or not chat_id then
        print("❌ Telegram não configurado!")
        return false
    end
    
    -- Verifica se o arquivo existe
    local f = io.open(photo_path, "r")
    if not f then
        print("❌ Foto não encontrada:", photo_path)
        return false
    end
    f:close()
    
    caption = caption or ""
    caption = caption:gsub('"', '\\"')
    
    local cmd = 'curl -s -X POST "https://api.telegram.org/bot' .. token .. '/sendPhoto" -F chat_id="' .. chat_id .. '" -F photo=@"' .. photo_path .. '" -F caption="' .. caption .. '"'
    local result = exec_curl(cmd)
    
    if result:find('"ok":true') then
        print("📸 Foto enviada!")
        return true
    else
        print("❌ Erro ao enviar foto")
        return false
    end
end

-- ============================================
-- 6. ENVIAR DOCUMENTO
-- ============================================

function M.send_document(doc_path, caption, token, chat_id)
    token = token or M.TOKEN
    chat_id = chat_id or M.CHAT_ID
    
    if not token or not chat_id then
        print("❌ Telegram não configurado!")
        return false
    end
    
    local f = io.open(doc_path, "r")
    if not f then
        print("❌ Documento não encontrado:", doc_path)
        return false
    end
    f:close()
    
    caption = caption or ""
    caption = caption:gsub('"', '\\"')
    
    local cmd = 'curl -s -X POST "https://api.telegram.org/bot' .. token .. '/sendDocument" -F chat_id="' .. chat_id .. '" -F document=@"' .. doc_path .. '" -F caption="' .. caption .. '"'
    local result = exec_curl(cmd)
    
    if result:find('"ok":true') then
        print("📄 Documento enviado!")
        return true
    else
        print("❌ Erro ao enviar documento")
        return false
    end
end

-- ============================================
-- 7. ENVIAR VÍDEO
-- ============================================

function M.send_video(video_path, caption, token, chat_id)
    token = token or M.TOKEN
    chat_id = chat_id or M.CHAT_ID
    
    if not token or not chat_id then
        print("❌ Telegram não configurado!")
        return false
    end
    
    local f = io.open(video_path, "r")
    if not f then
        print("❌ Vídeo não encontrado:", video_path)
        return false
    end
    f:close()
    
    caption = caption or ""
    caption = caption:gsub('"', '\\"')
    
    local cmd = 'curl -s -X POST "https://api.telegram.org/bot' .. token .. '/sendVideo" -F chat_id="' .. chat_id .. '" -F video=@"' .. video_path .. '" -F caption="' .. caption .. '"'
    local result = exec_curl(cmd)
    
    if result:find('"ok":true') then
        print("🎬 Vídeo enviado!")
        return true
    else
        print("❌ Erro ao enviar vídeo")
        return false
    end
end

-- ============================================
-- 8. ENVIAR ÁUDIO
-- ============================================

function M.send_audio(audio_path, caption, token, chat_id)
    token = token or M.TOKEN
    chat_id = chat_id or M.CHAT_ID
    
    if not token or not chat_id then
        print("❌ Telegram não configurado!")
        return false
    end
    
    local f = io.open(audio_path, "r")
    if not f then
        print("❌ Áudio não encontrado:", audio_path)
        return false
    end
    f:close()
    
    caption = caption or ""
    caption = caption:gsub('"', '\\"')
    
    local cmd = 'curl -s -X POST "https://api.telegram.org/bot' .. token .. '/sendAudio" -F chat_id="' .. chat_id .. '" -F audio=@"' .. audio_path .. '" -F caption="' .. caption .. '"'
    local result = exec_curl(cmd)
    
    if result:find('"ok":true') then
        print("🎵 Áudio enviado!")
        return true
    else
        print("❌ Erro ao enviar áudio")
        return false
    end
end

-- ============================================
-- 9. ENVIAR LOCALIZAÇÃO
-- ============================================

function M.send_location(latitude, longitude, token, chat_id)
    token = token or M.TOKEN
    chat_id = chat_id or M.CHAT_ID
    
    if not token or not chat_id then
        print("❌ Telegram não configurado!")
        return false
    end
    
    local cmd = 'curl -s -X POST "https://api.telegram.org/bot' .. token .. '/sendLocation" -F chat_id="' .. chat_id .. '" -F latitude="' .. latitude .. '" -F longitude="' .. longitude .. '"'
    local result = exec_curl(cmd)
    
    if result:find('"ok":true') then
        print("📍 Localização enviada!")
        return true
    else
        print("❌ Erro ao enviar localização")
        return false
    end
end

-- ============================================
-- 10. ENVIAR CONTATO
-- ============================================

function M.send_contact(phone, first_name, last_name, token, chat_id)
    token = token or M.TOKEN
    chat_id = chat_id or M.CHAT_ID
    
    if not token or not chat_id then
        print("❌ Telegram não configurado!")
        return false
    end
    
    last_name = last_name or ""
    
    local cmd = 'curl -s -X POST "https://api.telegram.org/bot' .. token .. '/sendContact" -F chat_id="' .. chat_id .. '" -F phone_number="' .. phone .. '" -F first_name="' .. first_name .. '" -F last_name="' .. last_name .. '"'
    local result = exec_curl(cmd)
    
    if result:find('"ok":true') then
        print("👤 Contato enviado!")
        return true
    else
        print("❌ Erro ao enviar contato")
        return false
    end
end

-- ============================================
-- 11. ENVIAR MENSAGEM COM BOTÕES
-- ============================================

function M.send_buttons(text, buttons, token, chat_id)
    token = token or M.TOKEN
    chat_id = chat_id or M.CHAT_ID
    
    if not token or not chat_id then
        print("❌ Telegram não configurado!")
        return false
    end
    
    text = text:gsub('"', '\\"')
    text = text:gsub("\n", "\\n")
    
    -- Constrói o teclado inline
    local keyboard = '{"inline_keyboard": ['
    for i, row in ipairs(buttons) do
        keyboard = keyboard .. '['
        for j, btn in ipairs(row) do
            if j > 1 then keyboard = keyboard .. ',' end
            keyboard = keyboard .. string.format(
                '{"text": "%s", "callback_data": "%s"}',
                btn.text:gsub('"', '\\"'),
                btn.data:gsub('"', '\\"')
            )
        end
        keyboard = keyboard .. ']'
        if i < #buttons then keyboard = keyboard .. ',' end
    end
    keyboard = keyboard .. ']}'
    
    local cmd = 'curl -s -X POST "https://api.telegram.org/bot' .. token .. '/sendMessage" -H "Content-Type: application/json" -d \'{"chat_id": "' .. chat_id .. '", "text": "' .. text .. '", "reply_markup": ' .. keyboard .. '}\''
    local result = exec_curl(cmd)
    
    if result:find('"ok":true') then
        print("📨 Mensagem com botões enviada!")
        return true
    else
        print("❌ Erro ao enviar botões")
        return false
    end
end

-- ============================================
-- 12. ENVIAR ARQUIVO POR EXTENSÃO (AUTO-DETECT)
-- ============================================

-- ============================================
-- 12. ENVIAR ARQUIVO POR EXTENSÃO (AUTO-DETECT)
-- ============================================

function M.send_file(file_path, caption, token, chat_id)
    token = token or M.TOKEN
    chat_id = chat_id or M.CHAT_ID
    
    if not token or not chat_id then
        print("❌ Telegram não configurado!")
        return false
    end
    
    local f = io.open(file_path, "r")
    if not f then
        print("❌ Arquivo não encontrado:", file_path)
        return false
    end
    f:close()
    
    -- Detecta extensão
    local ext = file_path:match("%.([^%.]+)$")
    ext = ext and ext:lower() or ""
    
    -- 🔥 CORREÇÃO: Usar colchetes nas chaves
    local extensions = {
        ["jpg"] = "photo", ["jpeg"] = "photo", ["png"] = "photo", ["gif"] = "photo",
        ["mp4"] = "video", ["mov"] = "video", ["avi"] = "video", ["3gp"] = "video",
        ["mp3"] = "audio", ["wav"] = "audio", ["ogg"] = "audio", ["m4a"] = "audio"
    }
    
    local tipo = extensions[ext] or "document"
    
    if tipo == "photo" then
        return M.send_photo(file_path, caption, token, chat_id)
    elseif tipo == "video" then
        return M.send_video(file_path, caption, token, chat_id)
    elseif tipo == "audio" then
        return M.send_audio(file_path, caption, token, chat_id)
    else
        return M.send_document(file_path, caption, token, chat_id)
    end
end

-- ============================================
-- 13. DNS RESOLVE
-- ============================================

function M.resolve(host)
    local ping_cmd = 'ping -c 1 "' .. host .. '" 2>/dev/null | head -1 | grep -oE "([0-9]+\\.){3}[0-9]+"'
    local result = exec_cmd(ping_cmd)
    if result and #result > 0 then
        local ip = result:match("%d+%.%d+%.%d+%.%d+")
        if ip then
            return ip
        end
    end
    
    local getent_cmd = 'getent ahosts "' .. host .. '" 2>/dev/null | head -1 | cut -d" " -f1'
    result = exec_cmd(getent_cmd)
    if result and #result > 0 then
        local ip = result:match("%d+%.%d+%.%d+%.%d+")
        if ip then
            return ip
        end
    end
    
    local commands = {
        'nslookup "' .. host .. '" 2>/dev/null | grep "Address:" | tail -1 | grep -oE "([0-9]+\\.){3}[0-9]+"',
        'dig +short "' .. host .. '" 2>/dev/null | head -1'
    }
    
    for _, cmd in ipairs(commands) do
        local result = exec_cmd(cmd)
        if result and #result > 0 then
            local ip = result:match("%d+%.%d+%.%d+%.%d+")
            if ip then
                return ip
            end
        end
    end
    
    return nil
end

-- ============================================
-- 14. SUBDOMAIN ENUMERATION
-- ============================================

function M.enumerate_subdomains_from_file(domain, filepath, max_items, max_threads, timeout)
    timeout = timeout or 2
    max_threads = max_threads or 30
    max_items = max_items or 500
    
    local cmd = 'cat "' .. filepath .. '" 2>/dev/null'
    local raw_data = exec_cmd(cmd)
    
    if not raw_data or #raw_data == 0 then
        return nil, "Arquivo vazio ou não encontrado: " .. filepath
    end
    
    local temp_table = {}
    raw_data:gsub("[^\n]+", function(matched_line)
        local clean = matched_line:gsub("%s+", "")
        if #clean > 0 then
            table.insert(temp_table, clean)
        end
    end)
    
    local limit = math.min(#temp_table, max_items)
    local wordlist = {}
    for i = 1, limit do
        wordlist[i] = temp_table[i]
    end
    
    if #wordlist == 0 then
        return nil, "Wordlist vazia"
    end
    
    print("[INFO] 📋 Carregados " .. #wordlist .. " subdomínios")
    print("[INFO] 🔍 Iniciando enumeração para: " .. domain)
    
    local found = {}
    local total = #wordlist
    local checked = 0
    
    for i = 1, #wordlist do
        local sub = wordlist[i]
        local host = sub .. "." .. domain
        local ip = M.resolve(host)
        
        checked = checked + 1
        
        if ip then
            print(string.format("[%d/%d] ✅ %s -> %s", checked, total, host, ip))
            table.insert(found, {subdomain = host, ip = ip})
        end
        
        if i % 10 == 0 then
            print(string.format("[INFO] ⏳ Progresso: %.1f%%", (checked/total)*100))
            os.execute("sleep 0.3")
            collectgarbage()
        end
    end
    
    return found
end

-- ============================================
-- 15. HTTP GET
-- ============================================

function M.http_get(url, timeout, headers)
    timeout = timeout or 10
    headers = headers or {}
    
    local cmd = 'curl -s -L -m ' .. timeout .. ' "' .. url .. '"'
    for key, value in pairs(headers) do
        cmd = cmd .. ' -H "' .. key .. ': ' .. value .. '"'
    end
    
    return exec_curl(cmd)
end

-- ============================================
-- 16. IP PÚBLICO
-- ============================================

function M.get_public_ip()
    local services = {
        "https://api.ipify.org",
        "https://icanhazip.com",
        "https://ifconfig.me/ip"
    }
    
    for _, url in ipairs(services) do
        local response = M.http_get(url, 5)
        if response and #response > 0 then
            local ip = response:match("%d+%.%d+%.%d+%.%d+")
            if ip then
                return ip
            end
        end
    end
    
    return "Não foi possível obter IP"
end

-- ============================================
-- 17. GEOLOCALIZAÇÃO
-- ============================================

function M.geolocate(ip)
    local url = "http://ip-api.com/csv/" .. ip
    local response = M.http_get(url, 5)
    
    if response and #response > 0 then
        local fields = {}
        for field in response:gmatch("([^,]*),?") do
            table.insert(fields, field)
        end
        
        if #fields >= 5 then
            return {
                status = fields[1] or "unknown",
                country = fields[2] or "unknown",
                countryCode = fields[3] or "unknown",
                region = fields[4] or "unknown",
                city = fields[5] or "unknown",
                zip = fields[6] or "unknown",
                lat = fields[7] or "0",
                lon = fields[8] or "0",
                timezone = fields[9] or "unknown",
                isp = fields[10] or "unknown",
                org = fields[11] or "unknown",
                query = fields[13] or ip
            }
        end
    end
    
    return nil
end

-- ============================================
-- 18. STATUS CODE
-- ============================================

function M.status_code(url, timeout)
    timeout = timeout or 5
    local cmd = 'curl -s -o /dev/null -w "%{http_code}" -m ' .. timeout .. ' "' .. url .. '"'
    local result = exec_curl(cmd)
    return tonumber(result) or 0
end

-- ============================================
-- 19. PING
-- ============================================

function M.ping(host, count)
    count = count or 1
    local cmd = 'ping -c ' .. count .. ' -W 1 "' .. host .. '" 2>/dev/null'
    local result = exec_curl(cmd)
    return result:find("1 received") ~= nil or result:find("1 packets received") ~= nil
end

-- ============================================
-- 20. DOWNLOAD
-- ============================================

function M.download(url, dest_path, timeout)
    timeout = timeout or 30
    local cmd = 'curl -s -L -m ' .. timeout .. ' "' .. url .. '" -o "' .. dest_path .. '"'
    exec_curl(cmd)
    
    local f = io.open(dest_path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- ============================================
-- 21. SCANNER DE PORTAS
-- ============================================

function M.scan_ports(host, start_port, end_port, timeout)
    timeout = timeout or 1
    local results = {}
    
    for port = start_port, end_port do
        local cmd = 'timeout ' .. timeout .. ' nc -zv "' .. host .. '" ' .. port .. ' 2>&1'
        local result = exec_cmd(cmd)
        if result:find("succeeded") or result:find("Connected") or result:find("open") then
            table.insert(results, port)
        end
    end
    
    return results
end

-- ============================================
-- 22. ENVIAR RESULTADOS DE SCAN
-- ============================================

function M.send_scan_results(domain, results, token, chat_id)
    local msg = "📊 SCAN DE SUBDOMÍNIOS\n"
    msg = msg .. "━━━━━━━━━━━━━━━━\n"
    msg = msg .. "📍 Alvo: " .. domain .. "\n"
    msg = msg .. "🔍 Encontrados: " .. #results .. "\n"
    msg = msg .. "━━━━━━━━━━━━━━━━\n\n"
    
    if #results > 0 then
        for i, sub in ipairs(results) do
            if i <= 20 then
                msg = msg .. string.format("%d. %s → %s\n", i, sub.subdomain, sub.ip)
            end
        end
        
        if #results > 20 then
            msg = msg .. "\n... e mais " .. (#results - 20) .. " subdomínios"
        end
    else
        msg = msg .. "❌ Nenhum subdomínio encontrado."
    end
    
    return M.send_message(msg, token, chat_id)
end

-- ============================================
-- 23. IP + GEOLOCALIZAÇÃO (COM ENVIO)
-- ============================================

function M.send_ip_info(token, chat_id)
    local ip = M.get_public_ip()
    local geo = M.geolocate(ip)
    
    local msg = "🌐 INFORMAÇÕES DE CONEXÃO\n"
    msg = msg .. "━━━━━━━━━━━━━━━━\n"
    msg = msg .. "📡 IP: " .. ip .. "\n"
    
    if geo then
        msg = msg .. "📍 Cidade: " .. geo.city .. "\n"
       headers = headers or {}
    
    local cmd = 'curl -s -L -m ' .. timeout .. ' "' .. url .. '"'
    
    for key, value in pairs(headers) do
        cmd = cmd .. ' -H "' .. key .. ': ' .. value .. '"'
    end
    
    return exec_curl(cmd)
end

-- ============================================
-- 3. HTTP POST
-- ============================================

function M.http_post(url, data, content_type, timeout)
    timeout = timeout or 10
    content_type = content_type or "application/json"
    
    local cmd = 'curl -s -L -m ' .. timeout
    cmd = cmd .. ' -X POST'
    cmd = cmd .. ' -H "Content-Type: ' .. content_type .. '"'
    cmd = cmd .. ' -d "' .. data .. '"'
    cmd = cmd .. ' "' .. url .. '"'
    
    return exec_curl(cmd)
end

-- ============================================
-- 4. DOWNLOAD DE ARQUIVO
-- ============================================

function M.download(url, dest_path, timeout)
    timeout = timeout or 30
    local cmd = 'curl -s -L -m ' .. timeout .. ' "' .. url .. '" -o "' .. dest_path .. '"'
    exec_curl(cmd)
    
    local f = io.open(dest_path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- ============================================
-- 5. UPLOAD DE ARQUIVO
-- ============================================

function M.upload(url, file_path, timeout)
    timeout = timeout or 30
    local cmd = 'curl -s -L -m ' .. timeout .. ' -F "file=@' .. file_path .. '" "' .. url .. '"'
    return exec_curl(cmd)
end

-- ============================================
-- 6. HEADERS E STATUS
-- ============================================

function M.head(url, timeout)
    timeout = timeout or 5
    local cmd = 'curl -s -I -m ' .. timeout .. ' "' .. url .. '"'
    return exec_curl(cmd)
end

function M.status_code(url, timeout)
    timeout = timeout or 5
    local cmd = 'curl -s -o /dev/null -w "%{http_code}" -m ' .. timeout .. ' "' .. url .. '"'
    local result = exec_curl(cmd)
    return tonumber(result) or 0
end

-- ============================================
-- 7. IP PÚBLICO (ESTÁVEL)
-- ============================================

function M.get_public_ip()
    -- Tenta 3 serviços diferentes
    local services = {
        "https://api.ipify.org",
        "https://icanhazip.com",
        "https://ifconfig.me/ip"
    }
    
    for _, url in ipairs(services) do
        local response = M.http_get(url, 5)
        if response and #response > 0 then
            local ip = response:match("%d+%.%d+%.%d+%.%d+")
            if ip then
                return ip
            end
        end
    end
    
    return "Não foi possível obter IP"
end

-- ============================================
-- 8. TESTE DE CONEXÃO (PING)
-- ============================================

function M.ping(host, count)
    count = count or 1
    local cmd = 'ping -c ' .. count .. ' -W 1 "' .. host .. '" 2>/dev/null'
    local result = exec_curl(cmd)
    return result:find("1 received") ~= nil or result:find("1 packets received") ~= nil
end

-- ============================================
-- 9. SCANNER DE PORTAS (VIA NC/NETCAT)
-- ============================================

function M.scan_port(host, port, timeout)
    timeout = timeout or 1
    -- Tenta diferentes comandos
    local commands = {
        'timeout ' .. timeout .. ' nc -zv "' .. host .. '" ' .. port .. ' 2>&1',
        'nc -zv -w ' .. timeout .. ' "' .. host .. '" ' .. port .. ' 2>&1',
        'timeout ' .. timeout .. ' telnet "' .. host .. '" ' .. port .. ' 2>&1'
    }
    
    for _, cmd in ipairs(commands) do
        local result = exec_cmd(cmd)
        if result:find("succeeded") or result:find("Connected") or result:find("open") then
            return true
        end
    end
    
    return false
end

-- ============================================
-- 10. SCANNER DE PORTAS (RANGE)
-- ============================================

function M.scan_ports(host, start_port, end_port, timeout)
    timeout = timeout or 1
    local results = {}
    
    for port = start_port, end_port do
        if M.scan_port(host, port, timeout) then
            table.insert(results, port)
        end
    end
    
    return results
end

-- ============================================
-- 11. GEOLOCALIZAÇÃO (SEGURA - SEM JSON)
-- ============================================

function M.geolocate(ip)
    -- Tenta obter geolocalização via ip-api.com (formato CSV)
    local url = "http://ip-api.com/csv/" .. ip
    local response = M.http_get(url, 5)
    
    if response and #response > 0 then
        -- Parse CSV: status,country,countryCode,region,regionName,city,zip,lat,lon,timezone,isp,org,as,query
        local fields = {}
        for field in response:gmatch("([^,]*),?") do
            table.insert(fields, field)
        end
        
        if #fields >= 5 then
            return {
                status = fields[1] or "unknown",
                country = fields[2] or "unknown",
                countryCode = fields[3] or "unknown",
                region = fields[4] or "unknown",
                city = fields[5] or "unknown",
                zip = fields[6] or "unknown",
                lat = fields[7] or "0",
                lon = fields[8] or "0",
                timezone = fields[9] or "unknown",
                isp = fields[10] or "unknown",
                org = fields[11] or "unknown",
                query = fields[13] or ip
            }
        end
    end
    
    return nil
end

-- ============================================
-- 12. WHOIS (COM FALLBACK)
-- ============================================

function M.whois(domain)
    -- Tenta diferentes comandos
    local commands = {
        'whois "' .. domain .. '" 2>/dev/null | head -20',
        'whois "' .. domain .. '" 2>/dev/null'
    }
    
    for _, cmd in ipairs(commands) do
        local result = exec_cmd(cmd)
        if result and #result > 10 then
            return result
        end
    end
    
    return nil
end

-- ============================================
-- 13. DNS RESOLVE (VIA CURL + FALLBACKS)
-- ============================================

function M.resolve(host)
    -- Método 1: Usar o 'curl' para resolver DNS (mais confiável no Android)
    -- O 'curl' usa a resolução DNS do sistema, e você já confirmou que ele funciona.
    local cmd = 'curl -s -o /dev/null -w "%{resolve}" --dns-servers 8.8.8.8 "' .. host .. '" 2>/dev/null'
    -- Nota: A opção --dns-servers pode não estar disponível em todas as versões do curl.
    -- Vamos tentar uma abordagem mais simples e universal primeiro.
    
    -- Método 2: Usar 'ping' para obter o IP (já que o ping funciona no seu teste)
    local ping_cmd = 'ping -c 1 "' .. host .. '" 2>/dev/null | head -1 | grep -oE "([0-9]+\\.){3}[0-9]+"'
    local result = exec_cmd(ping_cmd)
    if result and #result > 0 then
        local ip = result:match("%d+%.%d+%.%d+%.%d+")
        if ip then
            return ip
        end
    end

    -- Método 3: Usar 'getent' (comum em sistemas Android com Termux)
    local getent_cmd = 'getent ahosts "' .. host .. '" 2>/dev/null | head -1 | cut -d" " -f1'
    result = exec_cmd(getent_cmd)
    if result and #result > 0 then
        local ip = result:match("%d+%.%d+%.%d+%.%d+")
        if ip then
            return ip
        end
    end

    -- Método 4: Tentar os comandos tradicionais (nslookup/dig) como último recurso
    local commands = {
        'nslookup "' .. host .. '" 2>/dev/null | grep "Address:" | tail -1 | grep -oE "([0-9]+\\.){3}[0-9]+"',
        'dig +short "' .. host .. '" 2>/dev/null | head -1'
    }
    
    for _, cmd in ipairs(commands) do
        local result = exec_cmd(cmd)
        if result and #result > 0 then
            local ip = result:match("%d+%.%d+%.%d+%.%d+")
            if ip then
                return ip
            end
        end
    end
    
    -- Se tudo falhar, retorna nil
    return nil
end

-- ============================================
-- 14. BANNER GRABBER (SEGURO)
-- ============================================

function M.grab_banner(host, port, timeout)
    timeout = timeout or 2
    
    -- Tenta diferentes comandos
    local commands = {
        'timeout ' .. timeout .. ' nc "' .. host .. '" ' .. port .. ' < /dev/null 2>&1',
        'echo -e "HEAD / HTTP/1.0\\n\\n" | timeout ' .. timeout .. ' nc "' .. host .. '" ' .. port .. ' 2>&1',
        'echo "" | timeout ' .. timeout .. ' telnet "' .. host .. '" ' .. port .. ' 2>&1'
    }
    
    for _, cmd in ipairs(commands) do
        local result = exec_cmd(cmd)
        if result and #result > 0 then
            return result
        end
    end
    
    return nil
end

--- ============================================
-- 15. SUBDOMAIN ENUMERATION (COM LIMITE)
-- ============================================

function M.enumerate_subdomains_from_file(domain, filepath, max_items, max_threads, timeout)
    timeout = timeout or 2
    max_threads = max_threads or 30
    max_items = max_items or 500  -- Limite padrão de 500
    
    -- Lê o arquivo
    local cmd = 'cat "' .. filepath .. '" 2>/dev/null'
    local raw_data = exec_cmd(cmd)
    
    if not raw_data or #raw_data == 0 then
        return nil, "Arquivo vazio ou não encontrado: " .. filepath
    end
    
    -- Processa o arquivo
    local temp_table = {}
    raw_data:gsub("[^\n]+", function(matched_line)
        local clean = matched_line:gsub("%s+", "")
        if #clean > 0 then
            table.insert(temp_table, clean)
        end
    end)
    
    -- Aplica o limite
    local limit = math.min(#temp_table, max_items)
    local wordlist = {}
    for i = 1, limit do
        wordlist[i] = temp_table[i]
    end
    
    if #wordlist == 0 then
        return nil, "Wordlist vazia"
    end
    
    print("[INFO] 📋 Carregados " .. #wordlist .. " subdomínios (limite: " .. max_items .. ")")
    print("[INFO] 🔍 Iniciando enumeração para: " .. domain)
    print("[INFO] ⏱️  Isso pode levar alguns segundos...\n")
    
    local found = {}
    local total = #wordlist
    local checked = 0
    
    -- Processa um por um com pausas
    for i = 1, #wordlist do
        local sub = wordlist[i]
        local host = sub .. "." .. domain
        local ip = M.resolve(host)
        
        checked = checked + 1
        
        if ip then
            print(string.format("[%d/%d] ✅ %s -> %s", checked, total, host, ip))
            table.insert(found, {subdomain = host, ip = ip})
        end
        
        -- Pausa a cada 10 itens
        if i % 10 == 0 then
            print(string.format("[INFO] ⏳ Progresso: %.1f%% (%d/%d)", 
                (checked/total)*100, checked, total))
            os.execute("sleep 0.3")  -- Pausa curta
            collectgarbage()         -- Limpa memória
        end
    end
    
    return found
end

-- ============================================
-- 16. SUBDOMAIN ENUMERATION (COM WORDLIST PADRÃO EMBUTIDA)
-- ============================================

function M.enumerate_subdomains(domain, wordlist)
    -- Se não fornecida uma wordlist, usa a padrão
    wordlist = wordlist or {
        "www", "mail", "ftp", "admin", "dev", "test", 
        "api", "blog", "shop", "vpn", "dns", "ns1", "ns2",
        "webmail", "cpanel", "mysql", "backup", "monitor",
        "secure", "portal", "remote", "exchange", "owa",
        "autodiscover", "lync", "meet", "sip", "voip",
        "apps", "app", "mobile", "m", "wap", "mobi",
        "download", "uploads", "files", "media", "static",
        "cdn", "cloud", "storage", "data", "db",
        "internal", "corp", "office", "work", "staff",
        "support", "help", "faq", "docs", "wiki"
    }
    
    local found = {}
    
    for _, sub in ipairs(wordlist) do
        local host = sub .. "." .. domain
        local ip = M.resolve(host)
        if ip then
            table.insert(found, {subdomain = host, ip = ip})
        end
    end
    
    return found
end

-- ============================================
-- 16. HTTP STATUS COM BANNER
-- ============================================

function M.http_status(url, timeout)
    timeout = timeout or 5
    
    -- Tenta obter status e server
    local cmd = 'curl -s -I -m ' .. timeout .. ' "' .. url .. '" 2>/dev/null'
    local result = exec_curl(cmd)
    
    if result and #result > 0 then
        -- Extrai status code
        local status = result:match("HTTP/%d%.%d (%d+)")
        -- Extrai server
        local server = result:match("Server: (.+)")
        
        return {
            status = tonumber(status) or 0,
            server = server or "unknown",
            headers = result
        }
    end
    
    return nil
end

-- ============================================
-- 17. DOWNLOAD DE IMAGEM (RAW)
-- ============================================

function M.download_raw(url, timeout)
    timeout = timeout or 10
    local cmd = 'curl -s -L -m ' .. timeout .. ' "' .. url .. '"'
    return exec_curl(cmd)
end

-- ============================================
-- 18. VERIFICAÇÃO DE SSL
-- ============================================

function M.ssl_info(domain, timeout)
    timeout = timeout or 5
    local cmd = 'echo | timeout ' .. timeout .. ' openssl s_client -connect "' .. domain .. ':443" -servername "' .. domain .. '" 2>/dev/null | openssl x509 -noout -text 2>/dev/null | head -20'
    return exec_cmd(cmd)
end

-- ============================================
-- RETORNA O MÓDULO
-- ============================================

return M
