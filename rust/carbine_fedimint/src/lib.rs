#![allow(unexpected_cfgs)]

mod db;
mod event_bus;
mod frb_generated;
mod multimint;
mod nostr;
use db::SeedPhraseAckKey;
use event_bus::EventBus;
use fedimint_core::config::ClientConfig;
/* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
use flutter_rust_bridge::frb;
use futures_util::StreamExt;
use multimint::{
    FederationMeta, FederationSelector, Multimint, MultimintCreation, MultimintEvent,
    PaymentPreview, Transaction, Utxo,
};
use nostr::{NWCConnectionInfo, NostrClient, PublicFederation};
use tokio::sync::{OnceCell, RwLock};

use std::path::PathBuf;
use std::{str::FromStr, sync::Arc};

use anyhow::{anyhow, bail};
use fedimint_api_client::api::net::Connector;
use fedimint_bip39::Language;
use fedimint_client::{Client, OperationId};
use fedimint_core::{
    config::FederationId, db::Database, encoding::Encodable, invite_code::InviteCode,
    util::SafeUrl, Amount,
};
use fedimint_lnv2_client::{FinalReceiveOperationState, FinalSendOperationState};
use fedimint_mint_client::{ReissueExternalNotesState, SpendOOBState};
use fedimint_rocksdb::RocksDb;
use lightning_invoice::Bolt11Invoice;

use crate::db::{FederationConfig, FederationConfigKey, FederationConfigKeyPrefix};
use crate::frb_generated::StreamSink;
use crate::multimint::DepositEventKind;

static MULTIMINT: OnceCell<Multimint> = OnceCell::const_new();
static DATABASE: OnceCell<Database> = OnceCell::const_new();
static NOSTR: OnceCell<Arc<RwLock<NostrClient>>> = OnceCell::const_new();
static EVENT_BUS: OnceCell<EventBus<MultimintEvent>> = OnceCell::const_new();

fn get_multimint() -> Multimint {
    MULTIMINT.get().expect("Multimint not initialized").clone()
}

async fn get_database(path: String) -> Database {
    DATABASE
        .get_or_init(|| async {
            let db_path = PathBuf::from_str(&path)
                .expect("Could not parse db path")
                .join("client.db");
            RocksDb::open(db_path)
                .await
                .expect("Could not open database")
                .into()
        })
        .await
        .clone()
}

fn get_nostr_client() -> Arc<RwLock<NostrClient>> {
    NOSTR.get().expect("NostrClient not initialized").clone()
}

async fn create_nostr_client(db: Database) {
    NOSTR
        .get_or_init(|| async {
            Arc::new(RwLock::new(
                NostrClient::new(db)
                    .await
                    .expect("Could not create nostr client"),
            ))
        })
        .await;
}

pub fn get_event_bus() -> EventBus<MultimintEvent> {
    EVENT_BUS
        .get()
        .expect("EventBus is not initialized")
        .clone()
}

async fn create_event_bus() {
    EVENT_BUS
        .get_or_init(|| async { EventBus::new(100, 1000) })
        .await;
}

async fn log_to_flutter(message: &str) {
    get_event_bus()
        .publish(MultimintEvent::Log(message.to_string()))
        .await;
}

async fn log_to_flutter_str(message: String) {
    get_event_bus().publish(MultimintEvent::Log(message)).await;
}

#[frb]
pub async fn create_new_multimint(path: String) {
    create_event_bus().await;
    let db = get_database(path).await;
    MULTIMINT
        .get_or_init(|| async {
            Multimint::new(db.clone(), MultimintCreation::New)
                .await
                .expect("Could not create multimint")
        })
        .await;
    create_nostr_client(db).await;
}

#[frb]
pub async fn load_multimint(path: String) {
    create_event_bus().await;
    let db = get_database(path).await;
    MULTIMINT
        .get_or_init(|| async {
            Multimint::new(db.clone(), MultimintCreation::LoadExisting)
                .await
                .expect("Could not create multimint")
        })
        .await;
    create_nostr_client(db).await;
}

#[frb]
pub async fn create_multimint_from_words(path: String, words: Vec<String>) {
    create_event_bus().await;
    let db = get_database(path).await;
    MULTIMINT
        .get_or_init(|| async {
            Multimint::new(db.clone(), MultimintCreation::NewFromMnemonic { words })
                .await
                .expect("Could not create multimint")
        })
        .await;
    create_nostr_client(db).await;
}

#[frb]
pub async fn wallet_exists(path: String) -> anyhow::Result<bool> {
    let db_path = PathBuf::from_str(&path)?.join("client.db");
    let db: Database = RocksDb::open(db_path).await?.into();
    if let Ok(_) = Client::load_decodable_client_secret::<Vec<u8>>(&db).await {
        Ok(true)
    } else {
        Ok(false)
    }
}

#[frb]
pub async fn get_mnemonic() -> Vec<String> {
    let multimint = get_multimint();
    multimint.get_mnemonic()
}

#[frb]
pub async fn wait_for_recovery(invite_code: String) -> anyhow::Result<FederationSelector> {
    let mut multimint = get_multimint();
    multimint.wait_for_recovery(invite_code).await
}

#[frb]
pub async fn join_federation(
    invite_code: String,
    recover: bool,
) -> anyhow::Result<FederationSelector> {
    let mut multimint = get_multimint();
    multimint
        .join_federation(invite_code.clone(), recover)
        .await
}

#[frb]
pub async fn federations() -> Vec<(FederationSelector, bool)> {
    let multimint = get_multimint();
    multimint.federations().await
}

#[frb]
pub async fn balance(federation_id: &FederationId) -> u64 {
    let multimint = get_multimint();
    multimint.balance(federation_id).await
}

#[frb]
pub async fn receive(
    federation_id: &FederationId,
    amount_msats_with_fees: u64,
    amount_msats_without_fees: u64,
    gateway: String,
    is_lnv2: bool,
) -> anyhow::Result<(String, OperationId, String, String, u64)> {
    let gateway = SafeUrl::parse(&gateway)?;
    let multimint = get_multimint();
    let (invoice, operation_id) = multimint
        .receive(
            federation_id,
            amount_msats_with_fees,
            amount_msats_without_fees,
            gateway,
            is_lnv2,
        )
        .await?;
    let pubkey = invoice.get_payee_pub_key();
    let payment_hash = invoice.payment_hash();
    let expiry = invoice.expiry_time().as_secs();
    Ok((
        invoice.to_string(),
        operation_id,
        pubkey.to_string(),
        payment_hash.to_string(),
        expiry,
    ))
}

#[frb]
pub async fn select_receive_gateway(
    federation_id: &FederationId,
    amount_msats: u64,
) -> anyhow::Result<(String, u64, bool)> {
    let amount = Amount::from_msats(amount_msats);
    let multimint = get_multimint();
    multimint
        .select_receive_gateway(federation_id, amount)
        .await
}

#[frb]
pub async fn send_lnaddress(
    federation_id: &FederationId,
    amount_msats: u64,
    address: String,
) -> anyhow::Result<OperationId> {
    let lnurl = lnurl::lightning_address::LightningAddress::from_str(&address)?.lnurl();
    let async_client = lnurl::AsyncClient::from_client(reqwest::Client::new());
    let response = async_client.make_request(&lnurl.url).await?;
    match response {
        lnurl::LnUrlResponse::LnUrlPayResponse(response) => {
            let invoice = async_client
                .get_invoice(&response, amount_msats, None, None)
                .await?;

            let multimint = get_multimint();
            let bolt11 = Bolt11Invoice::from_str(invoice.invoice())?;
            let (gateway_url, _, is_lnv2) = multimint
                .select_send_gateway(
                    federation_id,
                    Amount::from_msats(amount_msats),
                    bolt11.clone(),
                )
                .await?;
            let gateway = SafeUrl::parse(&gateway_url)?;
            return multimint
                .send(federation_id, bolt11.to_string(), gateway, is_lnv2)
                .await;
        }
        other => bail!("Unexpected response from lnurl: {other:?}"),
    }
}

#[frb]
pub async fn send(
    federation_id: &FederationId,
    invoice: String,
    gateway: String,
    is_lnv2: bool,
) -> anyhow::Result<OperationId> {
    let multimint = get_multimint();
    let gateway = SafeUrl::parse(&gateway)?;
    multimint
        .send(federation_id, invoice, gateway, is_lnv2)
        .await
}

#[frb]
pub async fn await_send(
    federation_id: &FederationId,
    operation_id: OperationId,
) -> anyhow::Result<(FinalSendOperationState, String)> {
    let multimint = get_multimint();
    multimint.await_send(federation_id, operation_id).await
}

#[frb]
pub async fn await_receive(
    federation_id: &FederationId,
    operation_id: OperationId,
) -> anyhow::Result<(FinalReceiveOperationState, u64)> {
    let multimint = get_multimint();
    multimint.await_receive(federation_id, operation_id).await
}

#[frb]
pub async fn list_federations_from_nostr(force_update: bool) -> Vec<PublicFederation> {
    let nostr_client = get_nostr_client();
    let mut nostr = nostr_client.write().await;

    let multimint = get_multimint();

    let public_federations = nostr.get_public_federations(force_update).await;

    let mut joinable_federations = Vec::new();
    for pub_fed in public_federations {
        if !multimint.contains_client(&pub_fed.federation_id).await {
            joinable_federations.push(pub_fed);
        }
    }

    joinable_federations
}

#[frb]
pub async fn payment_preview(
    federation_id: &FederationId,
    bolt11: String,
) -> anyhow::Result<PaymentPreview> {
    let invoice = Bolt11Invoice::from_str(&bolt11)?;
    let amount_msats = invoice
        .amount_milli_satoshis()
        .expect("No amount specified");
    let payment_hash = invoice.payment_hash().consensus_encode_to_hex();
    let network = invoice.network().to_string();

    let multimint = get_multimint();
    let (gateway, amount_with_fees, is_lnv2) = multimint
        .select_send_gateway(federation_id, Amount::from_msats(amount_msats), invoice)
        .await?;

    Ok(PaymentPreview {
        amount_msats,
        payment_hash,
        network,
        invoice: bolt11,
        gateway,
        amount_with_fees,
        is_lnv2,
    })
}

#[frb]
pub async fn get_federation_meta(invite_code: String) -> anyhow::Result<FederationMeta> {
    let multimint = get_multimint();
    multimint.get_cached_federation_meta(invite_code).await
}

#[frb]
pub async fn transactions(
    federation_id: &FederationId,
    timestamp: Option<u64>,
    operation_id: Option<Vec<u8>>,
    modules: Vec<String>,
) -> Vec<Transaction> {
    let multimint = get_multimint();
    multimint
        .transactions(federation_id, timestamp, operation_id, modules)
        .await
}

#[frb]
pub async fn send_ecash(
    federation_id: &FederationId,
    amount_msats: u64,
) -> anyhow::Result<(OperationId, String, u64)> {
    let multimint = get_multimint();
    multimint.send_ecash(federation_id, amount_msats).await
}

#[frb]
pub async fn await_ecash_send(
    federation_id: &FederationId,
    operation_id: OperationId,
) -> anyhow::Result<SpendOOBState> {
    let multimint = get_multimint();
    multimint
        .await_ecash_send(federation_id, operation_id)
        .await
}

#[frb]
pub async fn parse_ecash(federation_id: &FederationId, ecash: String) -> anyhow::Result<u64> {
    let multimint = get_multimint();
    multimint.parse_ecash(federation_id, ecash).await
}

#[frb]
pub async fn reissue_ecash(
    federation_id: &FederationId,
    ecash: String,
) -> anyhow::Result<OperationId> {
    let multimint = get_multimint();
    multimint.reissue_ecash(federation_id, ecash).await
}

#[frb]
pub async fn await_ecash_reissue(
    federation_id: &FederationId,
    operation_id: OperationId,
) -> anyhow::Result<ReissueExternalNotesState> {
    let multimint = get_multimint();
    multimint
        .await_ecash_reissue(federation_id, operation_id)
        .await
}

#[frb]
pub async fn refund(federation_id: &FederationId) -> anyhow::Result<(String, u64)> {
    let multimint = get_multimint();
    multimint.refund(federation_id).await
}

#[frb]
pub async fn has_seed_phrase_ack() -> bool {
    let multimint = get_multimint();
    multimint.has_seed_phrase_ack().await
}

#[frb]
pub async fn ack_seed_phrase() {
    let multimint = get_multimint();
    multimint.ack_seed_phrase().await
}

#[frb]
pub async fn word_list() -> Vec<String> {
    Language::English
        .word_list()
        .iter()
        .map(|s| s.to_string())
        .collect()
}

#[frb]
pub async fn subscribe_deposits(sink: StreamSink<DepositEventKind>, federation_id: FederationId) {
    let event_bus = get_event_bus();
    let mut stream = event_bus.subscribe();

    while let Some(evt) = stream.next().await {
        if let MultimintEvent::Deposit((evt_fed_id, deposit)) = evt {
            if evt_fed_id == federation_id {
                if sink.add(deposit).is_err() {
                    break;
                }
            }
        }
    }
}

#[frb]
pub async fn monitor_deposit_address(
    federation_id: FederationId,
    address: String,
) -> anyhow::Result<()> {
    let multimint = get_multimint();
    multimint
        .monitor_deposit_address(federation_id, address)
        .await
}

#[frb]
pub async fn allocate_deposit_address(federation_id: FederationId) -> anyhow::Result<String> {
    let multimint = get_multimint();
    multimint.allocate_deposit_address(federation_id).await
}

#[frb]
pub async fn get_nwc_connection_info() -> Vec<(FederationSelector, NWCConnectionInfo)> {
    let nostr_client = get_nostr_client();
    let nostr = nostr_client.read().await;
    nostr.get_nwc_connection_info().await
}

#[frb]
pub async fn set_nwc_connection_info(
    federation_id: FederationId,
    relay: String,
) -> NWCConnectionInfo {
    let nostr_client = get_nostr_client();
    let mut nostr = nostr_client.write().await;
    nostr.set_nwc_connection_info(federation_id, relay).await
}

#[frb]
pub async fn get_relays() -> Vec<String> {
    let nostr_client = get_nostr_client();
    let nostr = nostr_client.read().await;
    nostr.get_relays().await
}

#[frb]
pub async fn wallet_summary(invite: String) -> anyhow::Result<Vec<Utxo>> {
    let multimint = get_multimint();
    multimint.wallet_summary(invite).await
}

#[frb]
pub async fn subscribe_multimint_events(sink: StreamSink<MultimintEvent>) {
    let event_bus = get_event_bus();
    let mut stream = event_bus.subscribe();

    while let Some(mm_event) = stream.next().await {
        if sink.add(mm_event).is_err() {
            break;
        }
    }
}

#[frb]
pub async fn federation_id_to_string(federation_id: FederationId) -> String {
    federation_id.to_string()
}
