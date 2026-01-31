#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUST_DIR="$SCRIPT_DIR/rust"
FLUTTER_DIR="$SCRIPT_DIR/flutter"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════╗"
    echo "║        interactions.work              ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

build_tui() {
    echo -e "${YELLOW}Building TUI (Rust)...${NC}"
    cd "$RUST_DIR"
    cargo build --release -p interactions-tui
    echo -e "${GREEN}TUI build complete!${NC}"
}

build_flutter() {
    echo -e "${YELLOW}Building Flutter Desktop...${NC}"
    cd "$FLUTTER_DIR"
    flutter build linux --release
    echo -e "${GREEN}Flutter Desktop build complete!${NC}"
}

run_tui() {
    echo -e "${BLUE}Launching TUI...${NC}"
    cd "$SCRIPT_DIR"
    "$RUST_DIR/target/release/interactions"
}

run_flutter() {
    echo -e "${BLUE}Launching Flutter Desktop...${NC}"
    cd "$SCRIPT_DIR"
    "$FLUTTER_DIR/build/linux/x64/release/bundle/interactions"
}

show_menu() {
    echo ""
    echo "Select an option:"
    echo "  1) Run TUI (Terminal)"
    echo "  2) Run Flutter Desktop"
    echo "  3) Exit"
    echo ""
    read -rp "Choice [1-3]: " choice

    case $choice in
        1)
            run_tui
            ;;
        2)
            run_flutter
            ;;
        3)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            show_menu
            ;;
    esac
}

main() {
    print_header

    # Parse arguments
    BUILD_ONLY=false
    SKIP_BUILD=false
    RUN_TARGET=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --build-only)
                BUILD_ONLY=true
                shift
                ;;
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --tui)
                RUN_TARGET="tui"
                shift
                ;;
            --flutter)
                RUN_TARGET="flutter"
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --build-only    Build apps without running"
                echo "  --skip-build    Skip build step and run directly"
                echo "  --tui           Run TUI directly (skips menu)"
                echo "  --flutter       Run Flutter Desktop directly (skips menu)"
                echo "  -h, --help      Show this help"
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
                ;;
        esac
    done

    # Build phase
    if [[ "$SKIP_BUILD" != true ]]; then
        build_tui
        build_flutter
    fi

    # Exit if build-only
    if [[ "$BUILD_ONLY" == true ]]; then
        echo -e "${GREEN}All builds complete!${NC}"
        exit 0
    fi

    # Run phase
    if [[ -n "$RUN_TARGET" ]]; then
        case $RUN_TARGET in
            tui)
                run_tui
                ;;
            flutter)
                run_flutter
                ;;
        esac
    else
        show_menu
    fi
}

main "$@"
