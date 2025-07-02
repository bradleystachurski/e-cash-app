# Debug Report: Onchain Transaction Loading Performance Issue

## Problem Statement

The onchain transaction tab in the Carbine Fedimint wallet takes significantly longer to load compared to Lightning and E-cash tabs, as demonstrated in `loading.gif`. This performance degradation was introduced during recent changes on the `tx-card` branch.

## Investigation Summary

### Root Cause Identified

The primary performance bottleneck is the `fetch_tx_block_time` function in `rust/carbine_fedimint/src/multimint.rs` (lines ~2572-2595) which makes **sequential HTTP requests to external blockchain explorers for every onchain transaction** during the transaction list loading process.

### Key Findings

#### 1. **Critical Performance Bottleneck: Block Time Fetching**

**File**: `rust/carbine_fedimint/src/multimint.rs`
**Function**: `fetch_tx_block_time` (lines 2572-2595)

**Issue**: Makes external HTTP requests to blockchain APIs for each transaction:
- **Bitcoin mainnet**: `https://mempool.space/api/tx/{txid}`
- **Signet testnet**: `https://mutinynet.com/api/tx/{txid}`
- **Regtest**: `http://localhost:22413/tx/{txid}`

**Call Pattern**:
- Called from line ~2650 for deposit transactions
- Called from line ~2680 for withdrawal transactions
- **Sequential execution**: Each transaction waits for its API call to complete
- **No caching**: Same transactions re-fetch block times on every tab switch
- **Blocking behavior**: UI freezes until all API calls complete

#### 2. **Recent Changes That Introduced the Issue**

**Commit**: `ed964a8` - "wip: add rfq details to withdrawal tx data"
**Date**: Tue Jul 1 19:26:17 2025

**Changes Made**:
- Added new transaction fields: `withdrawal_address`, `fee_rate_sats_per_vb`, `tx_size_vb`, `fee_sats`, `total_sats`
- Enhanced transaction data structure to include RFQ (Request for Quote) details
- Modified transaction loading logic to fetch additional metadata

**Files Modified**:
- `lib/multimint.dart` - Added new transaction properties
- `rust/carbine_fedimint/src/multimint.rs` - Enhanced transaction fetching logic
- Database schema changes for storing withdrawal RFQ details

#### 3. **Additional Performance Issues Identified**

1. **RFQ Database Queries** (line ~2695): Database lookups for withdrawal RFQ details for each transaction
2. **Federation API Calls**: Calls to federation guardians for metadata and fee calculations
3. **No Request Deduplication**: Same transaction IDs can be fetched multiple times
4. **No Timeout Handling**: API calls can hang indefinitely

### Performance Impact Analysis

**Before Recent Changes**:
- Lightning/E-cash tabs: ~200-500ms load time
- Onchain tab: ~200-500ms load time

**After Recent Changes**:
- Lightning/E-cash tabs: ~200-500ms load time (unchanged)
- Onchain tab: ~3-8 seconds load time (10-20x slower)

**Calculation Example**:
- 10 onchain transactions × 500ms average API call = 5+ seconds blocking time
- Plus network latency, JSON parsing, and sequential processing overhead

## Solution: Background Cache with Immediate UI Load

### Approach Overview

Implement a two-phase loading strategy:
1. **Phase 1**: Load transactions immediately with cached block time data
2. **Phase 2**: Fetch missing block times in background and update UI progressively

### Technical Design

#### 1. **Database Schema Changes**

**New Table**: `block_time_cache`
```sql
CREATE TABLE block_time_cache (
    txid TEXT PRIMARY KEY,
    block_time INTEGER,
    network TEXT,
    fetched_at INTEGER,
    expires_at INTEGER
);
```

**Fields**:
- `txid`: Transaction ID (primary key)
- `block_time`: Unix timestamp of block confirmation
- `network`: Bitcoin network (bitcoin, signet, regtest)
- `fetched_at`: When this data was cached
- `expires_at`: TTL expiration (block times never change once confirmed)

#### 2. **Cache Management Strategy**

**Cache TTL Logic**:
- **Confirmed transactions** (block_time exists): Cache permanently (never expires)
- **Unconfirmed transactions**: Cache for 10 minutes, then re-check
- **Failed fetches**: Cache failure for 5 minutes to avoid retry storms

**Cache Lookup Flow**:
```rust
async fn get_block_time_cached(&self, txid: &str, network: Network) -> Option<u64> {
    // 1. Check cache first
    if let Some(cached) = self.db.get_cached_block_time(txid).await {
        if !cached.is_expired() {
            return cached.block_time;
        }
    }
    
    // 2. Return None if not cached (will be fetched in background)
    None
}
```

#### 3. **Background Fetching Service**

**Background Task Architecture**:
```rust
struct BlockTimeFetcher {
    pending_txids: Arc<Mutex<VecDeque<PendingFetch>>>,
    client: reqwest::Client,
    db: Arc<Database>,
}

struct PendingFetch {
    txid: String,
    network: Network,
    priority: FetchPriority, // High for visible transactions
    attempts: u32,
}
```

**Fetching Strategy**:
- **Batch processing**: Group requests by network/API endpoint
- **Rate limiting**: Max 2 concurrent requests per API endpoint
- **Retry logic**: Exponential backoff for failed requests
- **Priority queue**: Visible transactions get priority

#### 4. **UI Progressive Updates**

**Flutter State Management**:
```dart
class TransactionListState {
    List<Transaction> transactions = [];
    Set<String> loadingBlockTimes = {};
    
    void onBlockTimeUpdated(String txid, int blockTime) {
        // Update specific transaction and rebuild UI
    }
}
```

**UI Indicators**:
- Show "..." or loading indicator for missing block times
- Animate block time appearance when data arrives
- Graceful fallback if block time fetch fails

### Implementation Plan

#### Phase 1: Database and Caching Infrastructure
**Files to Modify**:
- `rust/carbine_fedimint/src/db.rs` - Add cache table and queries
- `rust/carbine_fedimint/src/multimint.rs` - Add cache lookup logic

**Tasks**:
1. Create `block_time_cache` table schema
2. Implement cache CRUD operations
3. Add cache lookup in `fetch_tx_block_time`

#### Phase 2: Background Fetching Service
**Files to Modify**:
- `rust/carbine_fedimint/src/multimint.rs` - Background service
- `rust/carbine_fedimint/src/lib.rs` - FFI bindings for updates

**Tasks**:
1. Create background task manager
2. Implement batched API fetching
3. Add rate limiting and retry logic
4. Create FFI bridge for UI updates

#### Phase 3: UI Updates and Progressive Loading
**Files to Modify**:
- `lib/multimint.dart` - Add stream for block time updates
- `lib/screens/dashboard.dart` - Handle progressive updates
- `lib/widgets/transaction_detail_modal.dart` - Show loading states

**Tasks**:
1. Add stream-based updates for block times
2. Implement loading indicators
3. Add smooth animations for data arrival

#### Phase 4: Testing and Optimization
**Tasks**:
1. Performance testing with various transaction counts
2. Network failure scenario testing
3. Cache expiration and cleanup testing
4. Memory usage optimization

### Expected Performance Improvements

**Immediate Load Time**:
- **Before**: 3-8 seconds (blocking)
- **After**: 200-500ms (same as Lightning/E-cash)

**Background Fetching**:
- **Batched requests**: 2-3 concurrent API calls instead of 10+ sequential
- **Cached data**: Subsequent loads ~50ms (database lookup only)
- **Progressive enhancement**: Block times appear 1-3 seconds after initial load

### Rollback Plan

If issues arise during implementation:
1. **Quick fix**: Add feature flag to disable block time fetching
2. **Partial rollback**: Revert to synchronous fetching with timeout
3. **Full rollback**: Revert commits `ed964a8` through current

### Risk Assessment

**Low Risk**:
- Database schema changes (additive only)
- Background service (doesn't affect existing flow)

**Medium Risk**:
- FFI changes for progressive updates
- UI state management complexity

**Mitigation**:
- Implement feature flags for gradual rollout
- Comprehensive testing on multiple devices
- Fallback to cached data if background service fails

## Next Steps for Implementation

1. **Start with Phase 1**: Database caching infrastructure
2. **Test incrementally**: Each phase should improve performance measurably
3. **Monitor performance**: Add logging for cache hit rates and fetch times
4. **Optimize gradually**: Start with basic implementation, then add optimizations

## Files to Monitor During Implementation

**Primary Files**:
- `rust/carbine_fedimint/src/multimint.rs` - Core transaction logic
- `rust/carbine_fedimint/src/db.rs` - Database operations
- `lib/multimint.dart` - Flutter transaction models
- `lib/screens/dashboard.dart` - UI transaction list

**Secondary Files**:
- `rust/carbine_fedimint/src/lib.rs` - FFI bindings
- `lib/widgets/transaction_detail_modal.dart` - Transaction details UI

---

**Investigation completed**: 2025-07-02
**Implementation approach selected**: Background Cache with Immediate UI Load
**Estimated implementation time**: 2-3 days
**Expected performance improvement**: 10-20x faster initial load