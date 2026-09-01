package main

import (
	"bufio"
	"flag"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func main() {
	executeCmd := flag.NewFlagSet("execute", flag.ExitOnError)
	injectCmd := flag.NewFlagSet("inject", flag.ExitOnError)

	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	switch os.Args[1] {
	case "execute":
		executeCmd.Parse(os.Args[2:])
		if executeCmd.NArg() < 1 {
			fmt.Println("❌ Error: script path required")
			fmt.Println("Usage: lenzy-executor execute <script.lua>")
			os.Exit(1)
		}
		handleExecute(executeCmd.Arg(0))

	case "inject":
		injectCmd.Parse(os.Args[2:])
		if injectCmd.NArg() < 1 {
			fmt.Println("❌ Error: lua code required")
			fmt.Println("Usage: lenzy-executor inject \"lua code here\"")
			os.Exit(1)
		}
		handleInject(strings.Join(injectCmd.Args(), " "))

	case "status":
		handleStatus()

	case "help", "-h", "--help":
		printUsage()

	default:
		fmt.Println("❌ Unknown command:", os.Args[1])
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println(`
╔════════════════════════════════════════╗
║     Lenzy-Executor v1.0.0              ║
║     Roblox/Sober Lua Script Executor   ║
╚════════════════════════════════════════╝

Usage:
  lenzy-executor execute <script.lua>     Execute Lua script from file
  lenzy-executor inject "<lua code>"      Execute inline Lua code
  lenzy-executor status                   Check executor status
  lenzy-executor help                     Show this help message

Examples:
  lenzy-executor execute payload.lua
  lenzy-executor inject "print('Hello from Roblox!')"
  lenzy-executor status

Requirements:
  - Roblox/Sober must be running
  - Injector stub must be loaded in the game

Documentation: https://github.com/RLenzy/Lenzy-Executor
	`)
}

func handleExecute(scriptPath string) {
	fmt.Printf("📂 Reading script: %s\n", scriptPath)

	// Check if file exists
	if _, err := os.Stat(scriptPath); os.IsNotExist(err) {
		fmt.Printf("❌ Error: script file not found: %s\n", scriptPath)
		os.Exit(1)
	}

	// Read script content
	content, err := os.ReadFile(scriptPath)
	if err != nil {
		fmt.Printf("❌ Error reading file: %v\n", err)
		os.Exit(1)
	}

	script := string(content)
	fmt.Printf("✅ Script loaded (%d bytes)\n", len(script))

	// Send to injector
	if err := sendToInjector(script); err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("✅ Script executed successfully!")
}

func handleInject(code string) {
	fmt.Printf("📝 Injecting code (%d bytes)\n", len(code))

	if err := sendToInjector(code); err != nil {
		fmt.Printf("❌ Error: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("✅ Code injected successfully!")
}

func handleStatus() {
	fmt.Println("🔍 Checking executor status...")

	// Try to connect to injector socket
	conn, err := net.DialTimeout("unix", getSocketPath(), 2*time.Second)
	if err != nil {
		fmt.Println("❌ Status: DISCONNECTED")
		fmt.Println("   └─ Injector socket not found")
		fmt.Println("   └─ Make sure Roblox/Sober is running with injector loaded")
		os.Exit(1)
	}
	defer conn.Close()

	// Send status ping
	conn.Write([]byte("PING"))
	conn.SetReadDeadline(time.Now().Add(1 * time.Second))

	buffer := make([]byte, 1024)
	n, err := conn.Read(buffer)
	if err != nil {
		fmt.Println("❌ Status: DISCONNECTED")
		os.Exit(1)
	}

	response := string(buffer[:n])
	if strings.Contains(response, "PONG") {
		fmt.Println("✅ Status: CONNECTED")
		fmt.Println("   └─ Injector is running and responsive")
	} else {
		fmt.Println("⚠️  Status: UNKNOWN")
		fmt.Printf("   └─ Response: %s\n", response)
	}
}

func sendToInjector(script string) error {
	socketPath := getSocketPath()

	// Connect to injector socket
	conn, err := net.DialTimeout("unix", socketPath, 5*time.Second)
	if err != nil {
		return fmt.Errorf("cannot connect to injector (socket: %s). Make sure Roblox/Sober is running with injector loaded", socketPath)
	}
	defer conn.Close()

	// Send script
	conn.SetWriteDeadline(time.Now().Add(5 * time.Second))
	_, err = conn.Write([]byte(script))
	if err != nil {
		return fmt.Errorf("failed to send script: %v", err)
	}

	// Wait for response
	conn.SetReadDeadline(time.Now().Add(3 * time.Second))
	buffer := make([]byte, 1024)
	n, err := conn.Read(buffer)
	if err != nil {
		return fmt.Errorf("no response from injector: %v", err)
	}

	response := string(buffer[:n])
	if strings.Contains(response, "ERROR") {
		return fmt.Errorf("injector error: %s", response)
	}

	return nil
}

func getSocketPath() string {
	// Try multiple socket locations for compatibility
	home, _ := os.UserHomeDir()
	paths := []string{
		"/tmp/roblox-executor.sock",
		filepath.Join(home, ".roblox-executor.sock"),
		"/var/run/roblox-executor.sock",
	}

	for _, path := range paths {
		if _, err := os.Stat(path); err == nil {
			return path
		}
	}

	// Default to first option
	return paths[0]
}
