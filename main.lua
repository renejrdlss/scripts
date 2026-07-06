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

local net = require("socket_curl")

-- 1. HTTP GET
--local resposta = net.http_get("https://httpbin.org/ip")
--print("IP Público:", resposta)

-- 2. Baixar um arquivo
--net.download("https://httpbin.org/image/png", "/sdcard/imagem.png")

-- 3. Verificar status de um site
--local status = net.status_code("https://google.com")
--print("Status do Google:", status)

-- 4. Obter IP público
--local ip = net.get_public_ip()
--print("Meu IP:", ip)

-- 5. Ping em um host
--local online = net.ping("google.com")
--print("Google está online?", online)

-- 6. Escanear portas
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
