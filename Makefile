.PHONY: build install clean help

BINARY_NAME=lenzy-executor
BINARY_PATH=./bin/$(BINARY_NAME)
INSTALL_PATH=/usr/local/bin/$(BINARY_NAME)

help:
	@echo "Lenzy-Executor Build Commands:"
	@echo "  make build      - Build the executor binary"
	@echo "  make install    - Build and install to /usr/local/bin"
	@echo "  make clean      - Remove build artifacts"
	@echo "  make run        - Run the executor (shows help)"
	@echo "  make test       - Run basic tests"

build:
	@echo "🔨 Building Lenzy-Executor..."
	@mkdir -p bin
	@go build -o $(BINARY_PATH) .
	@echo "✅ Build complete: $(BINARY_PATH)"

install: build
	@echo "📦 Installing to system..."
	@sudo cp $(BINARY_PATH) $(INSTALL_PATH)
	@sudo chmod +x $(INSTALL_PATH)
	@echo "✅ Installed successfully!"
	@echo "   Try: lenzy-executor help"

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf bin/
	@echo "✅ Clean complete"

run: build
	@$(BINARY_PATH) help

test:
	@echo "🧪 Running tests..."
	@go test -v ./...

.DEFAULT_GOAL := help
