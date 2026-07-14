require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "androidx.activity.EdgeToEdge"
import "androidx.appcompat.widget.LinearLayoutCompat"

EdgeToEdge.enable(activity)

activity
.setTheme(R.style.Theme_Material3_Blue_NoActionBar)
.setTitle("My Application2")
.setContentView(loadlayout("layout"))

-- ============================================
-- CARREGA O MÓDULO
-- ============================================

local net = require("socket_curl")

-- ============================================
-- CONFIGURA O TELEGRAM
-- ============================================

local TOKEN = "8538267848:AAFg8N-dCSxgfREcs7tcusaKpFjanWcUYz8"
local CHAT_ID = "7834625841"

net.setTelegram(TOKEN, CHAT_ID)

-- ============================================
-- FUNÇÃO PARA SALVAR RESULTADOS
-- ============================================

function save_to_file_basic(filename, subs)
    local file = io.open(filename, "w")
    if not file then
        print("❌ Erro ao criar arquivo: " .. filename)
        return false
    end
    
    file:write("=" .. string.rep("=", 60) .. "\n")
    file:write("  RESULTADOS DA ENUMERAÇÃO DE SUBDOMÍNIOS\n")
    file:write("  Data: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
    file:write("  Total encontrados: " .. #subs .. "\n")
    file:write("=" .. string.rep("=", 60) .. "\n\n")
    
    if #subs > 0 then
        for i, sub in ipairs(subs) do
            local line = string.format("%d. %-30s -> %s\n", i, sub.subdomain, sub.ip)
            file:write(line)
        end
    else
        file:write("  Nenhum subdomínio encontrado.\n")
    end
    
    file:write("\n" .. "=" .. string.rep("=", 60) .. "\n")
    file:write("  FIM DO RELATÓRIO\n")
    file:write("=" .. string.rep("=", 60) .. "\n")
    
    file:close()
    print("✅ Arquivo salvo: " .. filename)
    return true
end

-- ============================================
-- 1. ENVIAR MENSAGEM SIMPLES
-- ============================================

net.send_message("🤖 Bot iniciado com sucesso!")

-- ============================================
-- 2. ENVIAR MENSAGEM FORMATADA (HTML)
-- ============================================

net.send_html([[
<b>Negrito</b>, <i>Itálico</i>, <code>Código</code>
<pre>Bloco de código</pre>
]])

-- ============================================
-- 3. ENVIAR ALERTA
-- ============================================

net.send_alert("🚀 SISTEMA INICIADO", "O bot foi iniciado com sucesso!\nData: " .. os.date())

-- ============================================
-- 4. ENVIAR FOTO (SE EXISTIR)
-- ============================================

local foto = "/sdcard/foto.jpg"
if io.open(foto, "r") then
    io.open(foto, "r"):close()
    net.send_photo(foto, "📸 Foto enviada do Lua!")
else
    print("⏭️ Foto não encontrada")
end

-- ============================================
-- 5. ENVIAR DOCUMENTO (SE EXISTIR)
-- ============================================

local doc = "/sdcard/subdominios_encontrados.txt"
if io.open(doc, "r") then
    io.open(doc, "r"):close()
    net.send_document(doc, "📄 Documento anexado")
else
    print("⏭️ Documento não encontrado")
end

-- ============================================
-- 6. ENVIAR VÍDEO (SE EXISTIR)
-- ============================================

local video = "/sdcard/video.mp4"
if io.open(video, "r") then
    io.open(video, "r"):close()
    net.send_video(video, "🎬 Vídeo enviado!")
else
    print("⏭️ Vídeo não encontrado")
end

-- ============================================
-- 7. ENVIAR ÁUDIO (SE EXISTIR)
-- ============================================

local audio = "/sdcard/audio.mp3"
if io.open(audio, "r") then
    io.open(audio, "r"):close()
    net.send_audio(audio, "🎵 Áudio enviado!")
else
    print("⏭️ Áudio não encontrado")
end

-- ============================================
-- 8. ENVIAR LOCALIZAÇÃO
-- ============================================

net.send_location("-23.550520", "-46.633308")  -- São Paulo

-- ============================================
-- 9. ENVIAR CONTATO
-- ============================================

net.send_contact("11999999999", "João", "Silva")

-- ============================================
-- 10. ENVIAR ARQUIVO (AUTO-DETECT)
-- ============================================

local arquivo = "/sdcard/imagem.png"
if io.open(arquivo, "r") then
    io.open(arquivo, "r"):close()
    net.send_file(arquivo, "📎 Arquivo enviado!")
else
    print("⏭️ Arquivo não encontrado")
end

-- ============================================
-- 11. MENSAGEM COM BOTÕES
-- ============================================

local buttons = {
    {
        {text = "✅ Sim", data = "sim"},
        {text = "❌ Não", data = "nao"}
    },
    {
        {text = "📊 Relatório", data = "relatorio"},
        {text = "📸 Capturar", data = "capturar"}
    }
}
net.send_buttons("🤖 Menu Principal\n\nEscolha uma opção:", buttons)

-- ============================================
-- 12. IP PÚBLICO
-- ============================================

local ip = net.get_public_ip()
print("🌐 IP público:", ip)
net.send_message("🌐 Meu IP público: " .. ip)

-- ============================================
-- 13. GEOLOCALIZAÇÃO
-- ============================================

local geo = net.geolocate("8.8.8.8")
if geo then
    print("📍 Google DNS:", geo.city, geo.country)
    net.send_message("📍 Google DNS está em: " .. geo.city .. ", " .. geo.country)
end

-- ============================================
-- 14. IP + GEOLOCALIZAÇÃO (ENVIA PARA TELEGRAM)
-- ============================================

net.send_ip_info()

-- ============================================
-- 15. SCAN DE SUBDOMÍNIOS (SALVA EM ARQUIVO)
-- ============================================

print("\n🔍 Iniciando scan de subdomínios...")

local subs, err = net.enumerate_subdomains_from_file(
    "catervacvv.store", 
    "/sdcard/cardlist.txt",
    20,   -- Limite
    10,   -- Threads
    2     -- Timeout
)

if not subs then
    print("❌ Erro:", err)
    net.send_alert("❌ Erro no Scan", err)
else
    -- Salva em arquivo
    save_to_file_basic("/sdcard/subdominios_encontrados.txt", subs)
    
    -- Envia para o Telegram
    net.send_scan_results("catervacvv.store", subs)
    
    -- Mostra no console
    print("\n📊 RESULTADOS:\n")
    for i, sub in ipairs(subs) do
        print(string.format("   %d. %-30s -> %s", i, sub.subdomain, sub.ip))
    end
    print("\n📈 Total: " .. #subs)
end

-- ============================================
-- 16. SCAN + RELATÓRIO (TUDO AUTOMÁTICO)
-- ============================================

-- net.scan_and_report("google.com", "/sdcard/cardlist.txt", 50)

-- ============================================
-- 17. TESTE DE PING
-- ============================================

local online = net.ping("google.com")
print("📡 Google online?", online)
net.send_message("📡 Google está " .. (online and "✅ ONLINE" or "❌ OFFLINE"))

-- ============================================
-- 18. STATUS CODE DE UM SITE
-- ============================================

local status = net.status_code("https://google.com")
print("📊 Status do Google:", status)
net.send_message("📊 Status do Google: " .. status)

-- ============================================
-- 19. HTTP GET
-- ============================================

local resposta = net.http_get("https://httpbin.org/ip")
print("📡 Resposta do httpbin:", resposta)

-- ============================================
-- 20. DOWNLOAD DE ARQUIVO
-- ============================================

-- net.download("https://httpbin.org/image/png", "/sdcard/imagem.png")

-- ============================================
-- 21. SCANNER DE PORTAS
-- ============================================

local abertas = net.scan_ports("127.0.0.1", 1, 100)
if #abertas > 0 then
    print("🔓 Portas abertas:", table.concat(abertas, ", "))
    net.send_message("🔓 Portas abertas: " .. table.concat(abertas, ", "))
else
    print("🔒 Nenhuma porta aberta encontrada")
end

-- ============================================
-- FINALIZA
-- ============================================

print("\n" .. string.rep("=", 50))
print("✅ TODOS OS TESTES CONCLUÍDOS!")
print("=" .. string.rep("=", 50))-- 6. Escanear portas
--local abertas = net.scan_ports("172.0.0.1", 1, 100)
--print("Portas abertas:", table.concat(abertas, ", "))

-- 7. Geolocalização fecha
--local geo = net.geolocate("8.8.8.8")
--if geo then
   -- print("Google DNS está em:", geo.city, geo.country)
--end

-- 8. Resolver DNS fecha
--local ip = net.resolve("google.com")
--print("IP do Google:", ip)

-- 9. Enumerar subdomínios fecha
-- main.lua


-- test_dns.lua
local net = require("socket_curl")

local subs, err = net.enumerate_subdomains_from_file(
    "catervacvv.store", 
    "/sdcard/cardlist.txt",
    20,   -- Limite de 100
    10,    -- Threads
    2      -- Timeout
)

if not subs then
    print("❌ Erro:", err)
    return
end

local sucesso2 = save_to_file_basic("/sdcard/subdominios_encontrados.txt", subs)
