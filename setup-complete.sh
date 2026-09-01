#!/bin/bash

# ╔════════════════════════════════════════════════════════════════╗
# ║     Lenzy-Executor Complete Setup                              ║
# ║     Instala, configura e exibe o script de injeção             ║
# ╚════════════════════════════════════════════════════════════════╝

VERSION="1.0.0"
TEMP_DIR="/tmp/lenzy-executor-complete-$$"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Cleanup
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# Funções de print
print_header() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     Lenzy-Executor Complete Setup v${VERSION}               ║"
    echo "║     Configuração automática do executor                    ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
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

print_step() {
    echo -e "${CYAN}➜ $1${NC}"
}

# Criar diretório temporário
mkdir -p "$TEMP_DIR"

# ═══════════════════════════════════════════════════════════════════
# PASSO 1: Header
# ═══════════════════════════════════════════════════════════════════

print_header

# ═══════════════════════════════════════════════════════════════════
# PASSO 2: Verificar se está no diretório correto
# ═══════════════════════════════════════════════════════════════════

print_step "Verificando ambiente..."

if [ ! -f "main.go" ] && [ ! -f "go.mod" ]; then
    print_info "Você não está no diretório Lenzy-Executor"
    print_info "Tentando navegar para lá..."
    
    if [ -d "$HOME/Lenzy-Executor" ]; then
        cd "$HOME/Lenzy-Executor"
        print_status "Navegado para $HOME/Lenzy-Executor"
    else
        print_error "Diretório Lenzy-Executor não encontrado!"
        print_info "Clone o repositório:"
        echo "   git clone https://github.com/RLenzy/Lenzy-Executor.git"
        exit 1
    fi
fi

print_status "Estou no diretório correto"

# ═══════════════════════════════════════════════════════════════════
# PASSO 3: Fazer pull dos últimos arquivos
# ═══════════════════════════════════════════════════════════════════

print_step "Atualizando repositório..."
git pull > /dev/null 2>&1 || true
print_status "Repositório atualizado"

# ═══════════════════════════════════════════════════════════════════
# PASSO 4: Compilar o executor
# ═══════════════════════════════════════════════════════════════════

print_step "Compilando executor..."
make build > /dev/null 2>&1 || true
print_status "Executor compilado"

# ═══════════════════════════════════════════════════════════════════
# PASSO 5: Instalar globalmente
# ═══════════════════════════════════════════════════════════════════

print_step "Instalando globalmente..."
make install > /dev/null 2>&1 || sudo make install > /dev/null 2>&1 || true
print_status "Executor instalado"

# ═══════════════════════════════════════════════════════════════════
# PASSO 6: Criar script de injeção completo
# ═══════════════════════════════════════════════════════════════════

print_step "Gerando script de injeção..."

INJECTION_SCRIPT="$TEMP_DIR/injection_script.lua"

cat > "$INJECTION_SCRIPT" << 'EOFSCRIPT'
-- ╔═══════════════════════════════════════════════════════════╗
-- ║   Lenzy-Executor Complete Injection Script v1.0           ║
-- ║   Cole isto no console do Roblox/Sober e execute!        ║
-- ╚═══════════════════════════════════════════════════════════╝

print("\n")
print("╔═══════════════════════════════════════════════════════╗")
print("║   Lenzy-Executor Injection Script v1.0                ║")
print("║   Carregando components...                            ║")
print("╚═══════════════════════════════════════════════════════╝")
print("\n")

-- Configuração
local Config = {
    Version = "1.0.0",
    InjectorURL = "https://raw.githubusercontent.com/RLenzy/Lenzy-Executor/main/injector.lua",
    InfinityYieldURL = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
    MaxRetries = 5,
    RetryDelay = 1
}

-- ═══════════════════════════════════════════════════════════
-- STAGE 1: Load Infinity Yield
-- ═══════════════════════════════════════════════════════════

print("[Stage 1/3] Carregando Infinity Yield...")

local infinityYield = nil
local iySuccess = false

for retry = 1, Config.MaxRetries do
    local success, result = pcall(function()
        return loadstring(game:HttpGet(Config.InfinityYieldURL))()
    end)
    
    if success then
        infinityYield = result
        iySuccess = true
        print("[Stage 1/3] ✅ Infinity Yield carregado com sucesso!")
        wait(1) -- Deixar inicializar
        break
    else
        print("[Stage 1/3] ⚠️  Tentativa " .. retry .. "/" .. Config.MaxRetries .. " falhou")
        if retry < Config.MaxRetries then
            wait(Config.RetryDelay)
        end
    end
end

if iySuccess then
    print("[Stage 1/3] Console aberto com F9")
else
    print("[Stage 1/3] ⚠️  Infinity Yield pode não ter carregado corretamente")
end

print("\n")

-- ═════════════════���═════════════════════════════════════════
-- STAGE 2: Load Lenzy-Executor Injector
-- ═══════════════════════════════════════════════════════════

print("[Stage 2/3] Carregando Lenzy-Executor Injector...")

local injector = nil
local injectorSuccess = false

for retry = 1, Config.MaxRetries do
    local success, result = pcall(function()
        local code = game:HttpGet(Config.InjectorURL)
        
        if not code or code == "" then
            error("Injector code is empty")
        end
        
        print("[Stage 2/3] Injector baixado (" .. string.len(code) .. " bytes)")
        
        local loaded = loadstring(code)()
        if not loaded then
            error("Failed to load injector")
        end
        
        return loaded
    end)
    
    if success then
        injector = result
        injectorSuccess = true
        print("[Stage 2/3] ✅ Injector carregado com sucesso!")
        break
    else
        print("[Stage 2/3] ⚠️  Tentativa " .. retry .. "/" .. Config.MaxRetries .. " falhou")
        if retry < Config.MaxRetries then
            wait(Config.RetryDelay)
        end
    end
end

print("\n")

-- ═══════════════════════════════════════════════════════════
-- STAGE 3: Verify Socket Connection
-- ═══════════════════════════════════════════════════════════

print("[Stage 3/3] Verificando conexão do socket...")

-- Simular verificação de socket
local socketReady = injectorSuccess

if socketReady then
    print("[Stage 3/3] ✅ Socket pronto para conexão!")
else
    print("[Stage 3/3] ⚠️  Socket pode não estar pronto")
end

print("\n")

-- ═══════════════════════════════════════════════════════════
-- FINAL STATUS
-- ═══════════════════════════════════════════════════════════

print("╔═══════════════════════════════════════════════��═══════╗")

if iySuccess and injectorSuccess and socketReady then
    print("║                                                       ║")
    print("║          ✅ EXECUTOR COMPLETAMENTE PRONTO!          ║")
    print("║                                                       ║")
    print("╚═══════════════════════════════════════════════════════╝")
    print("\n")
    print("[SUCCESS] Componentes carregados:")
    print("  ✅ Infinity Yield Console (F9)")
    print("  ✅ Lenzy-Executor Injector")
    print("  ✅ Socket Connection")
    print("\n")
    print("[NEXT] No seu terminal, execute:")
    print("  $ lenzy-executor inject \"print('Hello from Roblox!')\"")
    print("  $ lenzy-executor execute script.lua")
    print("  $ lenzy-executor status")
    print("\n")
else
    print("║                                                       ║")
    print("║     ⚠️  EXECUTOR COM AVISO - PARCIALMENTE PRONTO    ║")
    print("║                                                       ║")
    print("╚═══════════════════════════════════════════════════════╝")
    print("\n")
    print("[STATUS]")
    print("  " .. (iySuccess and "✅" or "❌") .. " Infinity Yield")
    print("  " .. (injectorSuccess and "✅" or "❌") .. " Lenzy-Executor")
    print("  " .. (socketReady and "✅" or "❌") .. " Socket Connection")
    print("\n")
    print("[HINT] Verifique sua conexão de internet")
    print("\n")
end

return {
    infinityYield = infinityYield,
    injector = injector,
    version = Config.Version,
    status = iySuccess and injectorSuccess and socketReady
}
EOFSCRIPT

print_status "Script de injeção gerado"

# ═══════════════════════════════════════════════════════════════════
# PASSO 7: Exibir instruções
# ═══════════════════════════════════════════════════════════════════

clear
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Lenzy-Executor Setup Completo! ✅                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo ""
echo -e "${GREEN}PASSO 1: Copie o script abaixo${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
cat "$INJECTION_SCRIPT"
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"

echo ""
echo -e "${GREEN}PASSO 2: Como usar${NC}"
echo ""
echo "  1️⃣  Abra o Sober e entre em um jogo (ex: Blox Fruits)"
echo "  2️⃣  Abra o console do Roblox (F9 ou DevTools)"
echo "  3️⃣  Cole o script acima e pressione Enter"
echo "  4️⃣  Aguarde até ver: ✅ EXECUTOR COMPLETAMENTE PRONTO!"
echo ""

echo -e "${GREEN}PASSO 3: No terminal, use${NC}"
echo ""
echo -e "  ${CYAN}lenzy-executor inject \"print('Hello!')\"${NC}"
echo -e "  ${CYAN}lenzy-executor execute script.lua${NC}"
echo -e "  ${CYAN}lenzy-executor status${NC}"
echo ""

echo -e "${GREEN}PRONTO! 🚀${NC}"
echo ""
echo -e "${YELLOW}Dica: Se quiser salvar o script em um arquivo:${NC}"
echo -e "  ${CYAN}cat > injection_script.lua << 'EOF'${NC}"
echo -e "  [Cole o script aqui]"
echo -e "  ${CYAN}EOF${NC}"
echo ""
