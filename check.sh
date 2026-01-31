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
NC='\033[0m'

FAILED=0

print_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════╗"
    echo "║   interactions.work - Check & Test    ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

run_step() {
    local name="$1"
    shift
    echo -e "${YELLOW}▶ $name${NC}"
    if "$@"; then
        echo -e "${GREEN}✓ $name passed${NC}"
        echo ""
    else
        echo -e "${RED}✗ $name failed${NC}"
        echo ""
        FAILED=1
    fi
}

check_rust() {
    echo -e "${BLUE}━━━ Rust ━━━${NC}"
    echo ""
    cd "$RUST_DIR"

    run_step "cargo fmt --check" cargo fmt --check
    run_step "cargo check --workspace" cargo check --workspace
    run_step "cargo clippy --workspace --all-targets" cargo clippy --workspace --all-targets -- -D warnings
    run_step "cargo test --workspace" cargo test --workspace
}

check_flutter() {
    echo -e "${BLUE}━━━ Flutter ━━━${NC}"
    echo ""
    cd "$FLUTTER_DIR"

    run_step "dart format --set-exit-if-changed" dart format --set-exit-if-changed .
    run_step "flutter analyze" flutter analyze
    run_step "flutter test" flutter test
}

print_summary() {
    echo ""
    echo -e "${BLUE}━━━ Summary ━━━${NC}"
    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}All checks passed!${NC}"
    else
        echo -e "${RED}Some checks failed.${NC}"
        exit 1
    fi
}

main() {
    print_header

    # Parse arguments
    RUST_ONLY=false
    FLUTTER_ONLY=false
    FIX=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --rust)
                RUST_ONLY=true
                shift
                ;;
            --flutter)
                FLUTTER_ONLY=true
                shift
                ;;
            --fix)
                FIX=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --rust      Check Rust only"
                echo "  --flutter   Check Flutter only"
                echo "  --fix       Auto-fix formatting issues"
                echo "  -h, --help  Show this help"
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
                ;;
        esac
    done

    # Auto-fix mode
    if [[ "$FIX" == true ]]; then
        echo -e "${YELLOW}Auto-fixing formatting...${NC}"
        echo ""
        if [[ "$FLUTTER_ONLY" != true ]]; then
            cd "$RUST_DIR"
            cargo fmt
            echo -e "${GREEN}✓ Rust formatted${NC}"
        fi
        if [[ "$RUST_ONLY" != true ]]; then
            cd "$FLUTTER_DIR"
            dart format .
            echo -e "${GREEN}✓ Flutter formatted${NC}"
        fi
        echo ""
        echo -e "${GREEN}Formatting complete. Run without --fix to verify.${NC}"
        exit 0
    fi

    # Run checks
    if [[ "$FLUTTER_ONLY" != true ]]; then
        check_rust
    fi

    if [[ "$RUST_ONLY" != true ]]; then
        check_flutter
    fi

    print_summary
}

main "$@"
