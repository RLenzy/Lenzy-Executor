#!/bin/bash

# ╔════════════════════════════════════════════════════════════════╗
# ║     Lenzy-Executor Auto-Inject                                 ║
# ║     Carrega o executor e injeta automaticamente no jogo        ║
# ╚════════════════════════════════════════════════════════════════╝

set -e

VERSION="1.0.0"
INJECTOR_URL="https://raw.githubusercontent.com/RLenzy/Lenzy-Executor/main/injector.lua"
INFINITY_YIELD_URL="https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
SOCKET_PATH="/tmp/roblox-executor.sock"
TEMP_DIR="/tmp/lenzy-executor-$$"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Lenzy-Executor Auto-Inject v${VERSION}      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
}

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Cleanup
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# Main
main() {
    print_header
    
    # Criar diretório temporário
    mkdir -p "$TEMP_DIR"
    
    print_info "Preparando script de injeção com Infinity Yield..."
    
    # Criar script all-in-one
    ALL_IN_ONE="$TEMP_DIR/all_in_one.lua"
    cat > "$ALL_IN_ONE" << 'EOFSCRIPT'
-- ╔═══════════════════════════════════════════════════════════╗
-- ║   Lenzy-Executor All-In-One Loader                       ║
-- ║   Cole isto no console do Roblox/Sober e execute!        ║
-- ╚═══════════════════════════════════════════════════════════╝

print("[Lenzy-Executor] Iniciando injeção automática...")
print("[Lenzy-Executor] Versão: 1.0.0")
print("[Lenzy-Executor] ═════════════════════════════════════")

-- Primeiro, carrega o Infinity Yield
print("[Lenzy-Executor] Carregando Infinity Yield...")
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

if success then
    print("[Lenzy-Executor] ✅ Infinity Yield carregado com sucesso!")
    wait(2) -- Aguardar o Infinity Yield inicializar
else
    print("[Lenzy-Executor] ⚠️  Aviso ao carregar Infinity Yield: " .. tostring(result))
end

-- Agora carrega o Lenzy-Executor
print("[Lenzy-Executor] Carregando Lenzy-Executor Injector...")

local LenzyAutoInject = {}
LenzyAutoInject.InjectorURL = "https://raw.githubusercontent.com/RLenzy/Lenzy-Executor/main/injector.lua"
LenzyAutoInject.SocketPath = "/tmp/roblox-executor.sock"
LenzyAutoInject.MaxRetries = 5
LenzyAutoInject.RetryDelay = 1

-- Função para carregar o injector
function LenzyAutoInject:LoadInjector()
    print("[Lenzy-Executor] Carregando injector...")
    
    local success, result = pcall(function()
        local injectorCode = game:HttpGet(LenzyAutoInject.InjectorURL)
        
        if not injectorCode or injectorCode == "" then
            error("Injector code is empty")
        end
        
        print("[Lenzy-Executor] Injector baixado (" .. string.len(injectorCode) .. " bytes)")
        
        local injector = loadstring(injectorCode)()
        
        if injector then
            print("[Lenzy-Executor] ✅ Injector carregado com sucesso!")
            return injector
        else
            error("Failed to load injector")
        end
    end)
    
    if success then
        return result
    else
        print("[Lenzy-Executor] Erro ao carregar: " .. tostring(result))
        return nil
    end
end

-- Carregar injector com retry
local injector = nil
for retry = 1, LenzyAutoInject.MaxRetries do
    print("[Lenzy-Executor] Tentativa " .. retry .. "/" .. LenzyAutoInject.MaxRetries)
    
    injector = LenzyAutoInject:LoadInjector()
    
    if injector then
        break
    end
    
    if retry < LenzyAutoInject.MaxRetries then
        print("[Lenzy-Executor] Aguardando " .. LenzyAutoInject.RetryDelay .. "s antes de retry...")
        wait(LenzyAutoInject.RetryDelay)
    end
end

-- Resultado final
if injector then
    print("[Lenzy-Executor] ═════════════════════════════════════")
    print("[Lenzy-Executor] ✅ EXECUTOR PRONTO!")
    print("[Lenzy-Executor] ═════════════════════════════════════")
    print("[Lenzy-Executor] Infinity Yield está aberto (F9)")
    print("[Lenzy-Executor] Comandos disponíveis no terminal:")
    print("[Lenzy-Executor]   lenzy-executor inject \"codigo\"")
    print("[Lenzy-Executor]   lenzy-executor execute arquivo.lua")
    print("[Lenzy-Executor]   lenzy-executor status")
    print("[Lenzy-Executor] ═════════════════════════════════════")
else
    print("[Lenzy-Executor] ❌ FALHA AO CARREGAR EXECUTOR")
    print("[Lenzy-Executor] Verifique sua conexão de internet")
end

return LenzyAutoInject
EOFSCRIPT
    
    print_status "Script criado com sucesso!"
    
    # Exibir o script
    echo ""
    print_info "Copie este script e cole no console do Roblox/Sober:"
    echo ""
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    cat "$ALL_IN_ONE"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Instruções
    echo -e "${GREEN}INSTRUÇÕES:${NC}"
    echo "1. Abra o Sober e entre em um jogo (ex: Blox Fruits)"
    echo "2. Abra o console do Roblox (F9 ou clique direito > DevTools)"
    echo "3. Abra a aba 'Console'"
    echo "4. Cole o script acima e pressione Enter"
    echo "5. Aguarde até ver: ✅ EXECUTOR PRONTO!"
    echo ""
    echo -e "${GREEN}Depois, no terminal, use:${NC}"
    echo ""
    echo -e "   ${BLUE}lenzy-executor inject \"print('Hello!')\"${NC}"
    echo -e "   ${BLUE}lenzy-executor execute script.lua${NC}"
    echo -e "   ${BLUE}lenzy-executor status${NC}"
    echo ""
    echo -e "${GREEN}Pronto! Agora você tem Infinity Yield + Lenzy-Executor! 🚀${NC}"
    echo ""
}

main "$@"
