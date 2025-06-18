# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Carbine is a Fedimint wallet built using Flutter for the frontend and Rust for core federation client functionality, connected via Flutter Rust Bridge. It enables users to interact with Bitcoin federated mints for custodial Bitcoin transactions.

## Development Setup

Uses Nix flakes for dependency management and reproducible builds:

```bash
# Enter development environment
nix develop

# Generate Flutter bindings from Rust code
just generate

# Run the app on Linux
just run
```

## Common Commands

### Building
- `just generate` - Generate Flutter Rust Bridge bindings and build Rust library
- `just build-linux` - Build Rust library for Linux
- `just build-android-x86_64` - Build for Android x86_64
- `just build-android-arm` - Build for Android ARM

### Development
- `flutter pub run build_runner build --delete-conflicting-outputs` - Build generated Dart code (freezed)
- `dart format lib/*.dart` - Format Dart code (required by pre-commit hook)

### Important: After Rust Changes
**CRITICAL**: After making changes to Rust code (`rust/carbine_fedimint/src/`), you MUST run:
1. `just generate` - Regenerate Flutter bindings
2. `just build-linux` - Rebuild the Rust library

The Flutter app will not see Rust changes until both steps are completed.

### Testing
- `flutter test` - Run Flutter/Dart tests

## Architecture

### Core Components

**Rust Backend (`rust/carbine_fedimint/`):**
- `lib.rs` - Main FFI interface exposing functions to Flutter via flutter_rust_bridge
- `multimint.rs` - Core wallet functionality managing multiple federation clients
- `db.rs` - Database operations using RocksDB
- `nostr.rs` - Nostr integration for NWC (Nostr Wallet Connect) and federation discovery
- `event_bus.rs` - Event handling system

**Flutter Frontend (`lib/`):**
- `main.dart` - App entry point, initializes Rust backend
- `app.dart` - Main app widget with federation management and navigation
- `screens/dashboard.dart` - Main wallet interface
- `multimint.dart` - Flutter data models for federation management
- `lib.dart` - Generated Flutter Rust Bridge bindings

### Key Patterns

**State Management:**
- Uses StatefulWidget pattern for local state
- Rust backend maintains global state via static OnceCell instances
- Real-time updates via StreamSink for deposit monitoring

**Federation Management:**
- Multi-federation support through `Multimint` wrapper
- Each federation represented by `FederationSelector` 
- Recovery mode support for wallet restoration

**Payment Flow:**
- Lightning payments via LNv1 and LNv2 gateways
- On-chain deposits and withdrawals
- E-cash (Cashu) token support
- Payment previews with fee calculation

### Data Flow

1. Flutter UI calls Rust functions via FFI bindings
2. Rust `Multimint` manages federation clients and operations
3. Database persistence via RocksDB
4. Event streams for real-time updates (deposits, transactions)
5. Nostr integration for federation discovery and NWC

## Linting and Formatting

- Dart formatting enforced by pre-commit hook: `scripts/git-hooks/pre-commit.sh`
- Flutter lints from `package:flutter_lints/flutter.yaml`
- Rust follows standard rustfmt conventions

## Build System

- Uses `just` for task running (Justfile)
- Nix flake provides reproducible development environment
- Cross-platform builds supported (Linux, Android, iOS, macOS, Windows)
- Flutter Rust Bridge generates FFI bindings automatically

## Database

- RocksDB for persistent storage
- Database path: `{app_documents_dir}/client.db`
- Handles federation configs, wallet state, transaction history
- Concurrent access managed by Rust backend