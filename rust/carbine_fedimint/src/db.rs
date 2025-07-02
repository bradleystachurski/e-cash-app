use std::time::SystemTime;

use fedimint_api_client::api::net::Connector;
use fedimint_core::{
    config::{ClientConfig, FederationId},
    encoding::{Decodable, Encodable},
    impl_db_lookup, impl_db_record,
    invite_code::InviteCode,
};
use serde::{Deserialize, Serialize};

use crate::multimint::FederationMeta;

#[repr(u8)]
#[derive(Clone, Debug)]
pub(crate) enum DbKeyPrefix {
    FederationConfig = 0x00,
    ClientDatabase = 0x01,
    SeedPhraseAck = 0x02,
    NWC = 0x03,
    FederationMeta = 0x04,
    BtcPrice = 0x05,
    WithdrawalRfqDetails = 0x06,
    BlockTimeCache = 0x07,
}

#[derive(Debug, Clone, Encodable, Decodable, Eq, PartialEq, Hash, Ord, PartialOrd)]
pub(crate) struct FederationConfigKey {
    pub(crate) id: FederationId,
}

#[derive(Debug, Clone, Eq, PartialEq, Encodable, Decodable, Serialize, Deserialize)]
pub(crate) struct FederationConfig {
    pub invite_code: InviteCode,
    pub connector: Connector,
    pub federation_name: String,
    pub network: Option<String>,
    pub client_config: ClientConfig,
}

#[derive(Debug, Encodable, Decodable)]
pub(crate) struct FederationConfigKeyPrefix;

impl_db_record!(
    key = FederationConfigKey,
    value = FederationConfig,
    db_prefix = DbKeyPrefix::FederationConfig,
);

impl_db_lookup!(
    key = FederationConfigKey,
    query_prefix = FederationConfigKeyPrefix
);

#[derive(Debug, Encodable, Decodable)]
pub(crate) struct SeedPhraseAckKey;

impl_db_record!(
    key = SeedPhraseAckKey,
    value = (),
    db_prefix = DbKeyPrefix::SeedPhraseAck,
);

#[derive(Debug, Encodable, Decodable)]
pub(crate) struct NostrWalletConnectKey {
    pub(crate) federation_id: FederationId,
}

#[derive(Debug, Encodable, Decodable)]
pub(crate) struct NostrWalletConnectKeyPrefix;

#[derive(Debug, Encodable, Decodable)]
pub(crate) struct NostrWalletConnectConfig {
    pub(crate) secret_key: [u8; 32],
    pub(crate) relay: String,
}

impl_db_record!(
    key = NostrWalletConnectKey,
    value = NostrWalletConnectConfig,
    db_prefix = DbKeyPrefix::NWC,
);

impl_db_lookup!(
    key = NostrWalletConnectKey,
    query_prefix = NostrWalletConnectKeyPrefix,
);

#[derive(Debug, Encodable, Decodable)]
pub(crate) struct FederationMetaKey {
    pub(crate) federation_id: FederationId,
}

impl_db_record!(
    key = FederationMetaKey,
    value = FederationMeta,
    db_prefix = DbKeyPrefix::FederationMeta,
);

#[derive(Debug, Encodable, Decodable)]
pub(crate) struct BtcPriceKey;

#[derive(Debug, Encodable, Decodable)]
pub(crate) struct BtcPrice {
    pub(crate) price: u64,
    pub(crate) last_updated: SystemTime,
}

impl_db_record!(
    key = BtcPriceKey,
    value = BtcPrice,
    db_prefix = DbKeyPrefix::BtcPrice,
);

#[derive(Debug, Clone, Encodable, Decodable, Eq, PartialEq, Hash, Ord, PartialOrd)]
pub(crate) struct WithdrawalRfqDetailsKey {
    pub(crate) operation_id: Vec<u8>,
}

#[derive(Debug, Clone, PartialEq, Encodable, Decodable, Serialize, Deserialize)]
pub(crate) struct WithdrawalRfqDetails {
    pub amount_sats: u64,
    pub fee_rate_sats_per_vb_millis: u64, // Store as millis to avoid f64 encoding issues
    pub tx_size_vb: u32,
    pub fee_sats: u64,
    pub total_sats: u64,
    pub withdrawal_address: String,
    pub created_at_millis: u64, // Store as milliseconds since UNIX epoch
}

#[derive(Debug, Encodable, Decodable)]
pub(crate) struct WithdrawalRfqDetailsKeyPrefix;

impl_db_record!(
    key = WithdrawalRfqDetailsKey,
    value = WithdrawalRfqDetails,
    db_prefix = DbKeyPrefix::WithdrawalRfqDetails,
);

impl_db_lookup!(
    key = WithdrawalRfqDetailsKey,
    query_prefix = WithdrawalRfqDetailsKeyPrefix,
);

#[derive(Debug, Clone, Encodable, Decodable, Eq, PartialEq, Hash, Ord, PartialOrd)]
pub(crate) struct BlockTimeCacheKey {
    pub(crate) txid: String,
}

#[derive(Debug, Clone, PartialEq, Encodable, Decodable, Serialize, Deserialize)]
pub(crate) struct BlockTimeCacheEntry {
    pub block_time: Option<u64>, // None for unconfirmed, Some(timestamp) for confirmed
    pub network: String, // "bitcoin", "signet", "regtest"
    pub fetched_at: u64, // Unix timestamp when this was cached
    pub expires_at: u64, // Unix timestamp when this expires (0 = never expires)
}

impl BlockTimeCacheEntry {
    pub fn is_expired(&self) -> bool {
        if self.expires_at == 0 {
            return false; // Never expires (confirmed transactions)
        }
        let now = SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();
        now > self.expires_at
    }

    pub fn new_confirmed(block_time: u64, network: String) -> Self {
        let now = SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();
        Self {
            block_time: Some(block_time),
            network,
            fetched_at: now,
            expires_at: 0, // Never expires for confirmed transactions
        }
    }

    pub fn new_unconfirmed(network: String, ttl_seconds: u64) -> Self {
        let now = SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();
        Self {
            block_time: None,
            network,
            fetched_at: now,
            expires_at: now + ttl_seconds,
        }
    }

    pub fn new_failed(network: String, ttl_seconds: u64) -> Self {
        let now = SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();
        Self {
            block_time: None,
            network,
            fetched_at: now,
            expires_at: now + ttl_seconds,
        }
    }
}

#[derive(Debug, Encodable, Decodable)]
pub(crate) struct BlockTimeCacheKeyPrefix;

impl_db_record!(
    key = BlockTimeCacheKey,
    value = BlockTimeCacheEntry,
    db_prefix = DbKeyPrefix::BlockTimeCache,
);

impl_db_lookup!(
    key = BlockTimeCacheKey,
    query_prefix = BlockTimeCacheKeyPrefix,
);
