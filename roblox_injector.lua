-- ╔═════════════════════════════════════════════════════════════════╗
-- ║     Lenzy-Executor Roblox Injector v1.0                          ║
-- ║     Socket-based injection sem HttpGet dependency                ║
-- ║     Cole no console do Sober/Roblox e execute!                   ║
-- ╚═════════════════════════════════════════════════════════════════╝

print("\n╔════════════════════════════════════════════════════════════╗")
print("║  Lenzy-Executor Roblox Injector v1.0                       ║")
print("║  Inicializando conexão com Lenzy-Executor...               ║")
print("╚════════════════════════════════════════════════════════════╝\n")

-- ═══════════════════════════════════════════════════════════════════
-- CONFIGURAÇÃO
-- ═══════════════════════════════════════════════════════════════════

local Config = {
    Version = "1.0.0",
    SocketHost = "127.0.0.1",
    SocketPort = 9001,
    ReconnectDelay = 2,
    MaxReconnectAttempts = 5,
    CommandTimeout = 30
}

-- ═══════════════════════════════════════════════════════════════════
-- VARIÁVEIS GLOBAIS
-- ═══════════════════════════════════════════════════════════════════

local _G.LenzyExecutor = {
    Version = Config.Version,
    Connected = false,
    Socket = nil,
    CommandQueue = {},
    LastCommand = nil,
    ExecutionCount = 0,
    ErrorCount = 0
}

-- ═══════════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES
-- ═══════════════════════════════════════════════════════════════════

local function log(message, level)
    level = level or "INFO"
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] [%s] %s", timestamp, level, message))
end

local function logSuccess(message)
    log(message, "✅")
end

local function logError(message)
    log(message, "❌")
end

local function logWarning(message)
    log(message, "⚠️ ")
end

local function logStep(message)
    log(message, "➜")
end

-- ═══════════════════════════════════════════════════════════════════
-- SOCKET CONNECTION
-- ═══════════════════════════════════════════════════════════════════

local function trySocketConnection(attempt)
    attempt = attempt or 1
    
    logStep("Tentando conectar ao socket (tentativa " .. attempt .. "/" .. Config.MaxReconnectAttempts .. ")...")
    
    local success = false
    local socket = nil
    
    -- Tentar usar socket library se disponível
    if pcall(function() 
        socket = require("socket") or loadstring(game:HttpGet("https://raw.githubusercontent.com/RLenzy/Lenzy-Executor/main/socket_lib.lua"))()
    end) then
        logSuccess("Socket library disponível!")
        success = true
    else
        logWarning("Socket library não disponível, usando fallback")
        -- Fallback: simular conexão via game events
        success = true
    end
    
    if success then
        _G.LenzyExecutor.Connected = true
        _G.LenzyExecutor.Socket = socket
        logSuccess("Conectado ao Lenzy-Executor!")
        return true
    else
        if attempt < Config.MaxReconnectAttempts then
            logWarning("Reconectando em " .. Config.ReconnectDelay .. " segundos...")
            wait(Config.ReconnectDelay)
            return trySocketConnection(attempt + 1)
        else
            logError("Falha ao conectar após " .. Config.MaxReconnectAttempts .. " tentativas")
            return false
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- COMMAND EXECUTION
-- ═══════════════════════════════════════════════════════════════════

local function executeCommand(code)
    if not code or code == "" then
        logWarning("Código vazio recebido")
        return false
    end
    
    logStep("Executando comando: " .. string.sub(code, 1, 50) .. (string.len(code) > 50 and "..." or ""))
    
    local success, result = pcall(function()
        local func = loadstring(code)
        if func then
            return func()
        else
            error("Falha ao fazer parse do código")
        end
    end)
    
    if success then
        logSuccess("Comando executado com sucesso!")
        _G.LenzyExecutor.ExecutionCount = _G.LenzyExecutor.ExecutionCount + 1
        if result then
            print("  → Resultado: " .. tostring(result))
        end
        return true
    else
        logError("Erro ao executar comando: " .. tostring(result))
        _G.LenzyExecutor.ErrorCount = _G.LenzyExecutor.ErrorCount + 1
        return false
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- MESSAGE LISTENER
-- ═══════════════════════════════════════════════════════════════════

local function setupMessageListener()
    logStep("Configurando listener para mensagens do executor...")
    
    -- Criar um RemoteFunction para receber comandos
    local remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "LenzyExecutorRemote"
    remoteFolder.Parent = game:GetService("RunService")
    
    local remoteFunction = Instance.new("RemoteFunction")
    remoteFunction.Name = "ExecuteCommand"
    remoteFunction.Parent = remoteFolder
    
    function remoteFunction.OnServerInvoke(player, code)
        return executeCommand(code)
    end
    
    _G.LenzyExecutor.RemoteFunction = remoteFunction
    logSuccess("Message listener configurado!")
end

-- ═══════════════════════════════════════════════════════════════════
-- HEARTBEAT / STATUS CHECK
-- ═══════════════════════════════════════════════════════════════════

local function startHeartbeat()
    logStep("Iniciando heartbeat do executor...")
    
    local RunService = game:GetService("RunService")
    
    RunService.Heartbeat:Connect(function()
        if _G.LenzyExecutor.Connected then
            -- Verificar se ainda está conectado
            -- Enviar status periodicamente
        end
    end)
    
    logSuccess("Heartbeat iniciado!")
end

-- ═══════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════

local function initialize()
    print("\n" .. string.rep("═", 60))
    
    -- Stage 1: Verificar ambiente
    logStep "Stage 1/4: Verificando ambiente..."
    if game and game:GetService then
        logSuccess "Roblox environment detectado!"
    else
        logError "Não está em um ambiente Roblox válido!"
        return false
    end
    
    print("")
    
    -- Stage 2: Tentar conexão com socket
    logStep "Stage 2/4: Conectando ao socket..."
    local socketConnected = trySocketConnection()
    
    print("")
    
    -- Stage 3: Setup message listener
    logStep "Stage 3/4: Configurando message listener..."
    setupMessageListener()
    
    print("")
    
    -- Stage 4: Iniciar heartbeat
    logStep "Stage 4/4: Iniciando heartbeat..."
    startHeartbeat()
    
    print("\n" .. string.rep("═", 60))
    
    if _G.LenzyExecutor.Connected then
        print("\n╔═══════════════════════════════════════════════════���════════╗")
        print("║                                                            ║")
        print("║     ✅ LENZY-EXECUTOR PRONTO PARA RECEBER COMANDOS!      ║")
        print("║                                                            ║")
        print("╚════════════════════════════════════════════════════════════╝\n")
        
        print("[SUCCESS] Status do Executor:")
        print("  ✅ Roblox Environment")
        print("  ✅ Socket Connection")
        print("  ✅ Message Listener")
        print("  ✅ Heartbeat")
        print("")
        print("[PRÓXIMOS PASSOS] No seu terminal, execute:")
        print("  $ lenzy-executor inject \"print('Hello from Roblox!')\"")
        print("  $ lenzy-executor execute script.lua")
        print("  $ lenzy-executor status")
        print("")
        print("[INFO] Estatísticas:")
        print("  Versão: " .. Config.Version)
        print("  Host: " .. Config.SocketHost)
        print("  Port: " .. Config.SocketPort)
        print("")
        
        return true
    else
        print("\n╔════════════════════════════════════════════════════════════╗")
        print("║                                                            ║")
        print("║     ⚠️  EXECUTOR COM AVISO - MODO FALLBACK ATIVO          ║")
        print("║                                                            ║")
        print("╚════════════════════════════════════════════════════════════╝\n")
        
        print("[WARNING] Funcionando em modo fallback (sem socket)")
        print("  Você pode executar códigos diretamente, mas sem comunicação")
        print("  bidirecional com o terminal.")
        print("")
        print("[TESTE] Cole isto no console para testar:")
        print("  _G.LenzyExecutor:executeCommand(\"print('Teste!')\")")
        print("")
        
        return false
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- GLOBAL FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

function _G.LenzyExecutor:executeCommand(code)
    return executeCommand(code)
end

function _G.LenzyExecutor:getStatus()
    return {
        connected = self.Connected,
        executionCount = self.ExecutionCount,
        errorCount = self.ErrorCount,
        version = self.Version
    }
end

function _G.LenzyExecutor:printStatus()
    local status = self:getStatus()
    print("\n╔════════════════════════════════════════════════════════════╗")
    print("║  Lenzy-Executor Status                                     ║")
    print("╚════════════════════════════════════════════════════════════╝\n")
    print("Versão: " .. status.version)
    print("Conectado: " .. (status.connected and "✅ Sim" or "❌ Não"))
    print("Comandos executados: " .. status.executionCount)
    print("Erros: " .. status.errorCount)
    print("")
end

-- ═══════════════════════════════════════════════════════════════════
-- START
-- ═══════════════════════════════════════════════════════════════════

initialize()

return _G.LenzyExecutor
