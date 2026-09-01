-- Lenzy-Executor Loader para Infinity Yield
-- Este script carrega o injector do Lenzy-Executor automaticamente
-- Cole este script no console do Infinity Yield

local LenzyLoader = {}
LenzyLoader.Version = "1.0.0"
LenzyLoader.InjectorURL = "https://raw.githubusercontent.com/RLenzy/Lenzy-Executor/main/injector.lua"
LenzyLoader.SocketPath = "/tmp/roblox-executor.sock"

print("[Lenzy-Executor Loader] v" .. LenzyLoader.Version)
print("[Lenzy-Executor Loader] Loading from: " .. LenzyLoader.InjectorURL)

-- Função para carregar o injector
function LenzyLoader:Load()
    print("[Lenzy-Executor Loader] Iniciando carregamento...")
    
    local success, result = pcall(function()
        -- Tentar carregar via HttpGet
        local injectorCode = game:HttpGet(LenzyLoader.InjectorURL)
        
        if not injectorCode or injectorCode == "" then
            error("Injector code is empty")
        end
        
        print("[Lenzy-Executor Loader] Injector baixado com sucesso (" .. string.len(injectorCode) .. " bytes)")
        
        -- Carregar o injector
        local injector = loadstring(injectorCode)()
        
        if injector then
            print("[Lenzy-Executor Loader] ✅ Injector carregado com sucesso!")
            print("[Lenzy-Executor Loader] Versão do injector: " .. (injector.Version or "desconhecida"))
            return injector
        else
            error("Failed to load injector")
        end
    end)
    
    if success then
        return result
    else
        print("[Lenzy-Executor Loader] ❌ Erro ao carregar: " .. tostring(result))
        return nil
    end
end

-- Função para testar conexão
function LenzyLoader:TestConnection()
    print("[Lenzy-Executor Loader] Testando conexão com executor...")
    
    -- Aqui você poderia fazer um teste mais elaborado
    -- Por enquanto, apenas confirmamos que o injector foi carregado
    print("[Lenzy-Executor Loader] Status: PRONTO")
    print("[Lenzy-Executor Loader] Use: lenzy-executor inject \"código lua\"")
end

-- Carregar automaticamente
local injector = LenzyLoader:Load()

if injector then
    LenzyLoader:TestConnection()
    print("[Lenzy-Executor Loader] Pronto para executar scripts!")
    print("[Lenzy-Executor Loader] Exemplos:")
    print("  lenzy-executor inject \"print('Hello')\"")
    print("  lenzy-executor execute script.lua")
else
    print("[Lenzy-Executor Loader] Falha ao carregar o injector")
end

return LenzyLoader
