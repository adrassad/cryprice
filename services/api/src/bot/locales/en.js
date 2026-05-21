// src/locales/en.js
export default {
  common: {
    yes: "Yes",
    no: "No",
    active: "✅ Active",
    expired: "❌ Expired",
    notSpecified: "not specified",
  },

  users: {
    listTitle: "Select a user:",
    pageInfo: "Page {current} of {total}",
    prevButton: "⬅️ Back",
    nextButton: "Next ➡️",
    backToList: "🔙 Back to list",
    empty: "The user list is empty.",
    error: "❌ Failed to load users list.",
  },
  // General
  main_menu: "🏠 Main menu",
  welcome: "👋 Hello! I'm your assistant.",
  error: "⚠️ An error occurred. Please try again later.",
  status: "Status:",

  //threshold
  threshhold_enter: `Enter the threshold value for the Health Factor.\n\n
  For example: 1.20\n
  To cancel, send /cancel`,
  threshold_error: "Invalid value. Enter a number, for example: 1.20",
  threshold_updated: "✅ Your Health Factor threshold has been updated:",
  action_cancel: "Action canceled.",
  threshold_value: "Пороговое значение HealthFactor: ",

  //profile
  profile: {
    title: "👤 <b>Profile</b>",
    notFound: "❌ Profile not found.",
    telegramId: "🆔 <b>Telegram ID:</b> <code>{telegramId}</code>",
    name: "🙍 <b>Name:</b> {name}",
    username: "🔗 <b>Username:</b> {username}",
    subscriptionTitle: "💳 <b>Subscription</b>",
    plan: "📦 <b>Plan:</b> {plan}",
    validUntil: "📅 <b>Valid until:</b> {date}",
    status: "📍 <b>Status:</b> {status}",
    settingsTitle: "⚙️ <b>Settings</b>",
    threshold: "📉 <b>Health Factor threshold:</b> {value}",
    renewHint: "💡 <i>Renew your subscription to continue monitoring.</i>",
    freePlan: "🆓 Free",
    proPlan: "⭐ Pro",
  },

  start_welcome: `👋 Welcome!

  🤖 <b>Aave Health Monitor</b>

  I track the <b>Health Factor</b> of your wallets on AAVE (Arbitrum)
  and alert you if liquidation risk appears ⚠️

  ---

  🚀 <b>Quick start:</b>

  1. Add your wallet → /add_wallet
  2. Set HF threshold → /set_threshold
  3. I’ll monitor everything 24/7 🔔

  ---

  📊 <b>What I do:</b>

  • Track Health Factor
  • Alert on liquidation risk
  • Monitor price changes (>5%)
  • Support multiple wallets 💼

  ---

  💡 <b>Quick tip:</b>

  Just type: <code>ETH</code> <code>BTC</code> <code>AVAX</code>

  → and get instant price 📈

  ---

  📌 /help — command list
  📌 /profile — your profile & settings
`,

  // Telegram commands
  help_command: `ℹ️ Available commands:
  /start — start
  /add_wallet — add a wallet
  /set_threshold — set Health Factor threshold
  /help — help
  /status - user status
  /positions - positions in Aave
  /healthfactor - 🛡 Show Health Factor on Aave`,

  command_wallet_no_add:
    "⚠️ You don't have any wallets yet. Add one via ➕ Add Wallet.",
  command_wallet_select: "💼 Select a wallet to get the Health Factor on Aave:",
  command_show_positions: "💼 Select a wallet to view positions:",

  // Support
  support_enter: "✍️ Write your message to support.\n\nTo cancel send /cancel",
  support_canceled: "❌ Message sending canceled.",
  support_sent: "✅ Your message has been sent to support.",
  support_sent_title: "New support request",
  support_answer: "💬 Reply",
  support_no_rules: "Not enough permissions",
  support_enter_answer: "✍️ Enter your reply to the user:",
  support_answer_support: "Support reply:",
  support_answered_user: "✅ Reply sent to the user.",
  support_answered_support: "✅ Your message has been sent to support.",
  support_public_notice:
    "ℹ️ This public build does not relay messages to an operator.\nSee README.md for how to report issues or contribute.",
  message: "Message:",

  // Positions and Aave
  no_active_positions: "ℹ️ No active positions in Aave.",
  positions_overview: "📊 Your current positions:",

  no_user: "❌ User not found",
  wallet_limit_reached:
    "⚠️ Wallet limit reached. Remove a wallet or set MAX_WALLETS_PER_USER higher.",
  novalid_address: "❌ Invalid address.\n\nSend a valid address or /cancel",

  // Wallets
  wallets: {
    empty: "Wallets list is empty.",
    no_wallet: "❌ Wallet not found",
    wallet_you_have:
      "⚠️ This wallet is already added.\nSend another address or /cancel",
    wallet_buttom_add: "➕ Add wallet",
    wallet_buttom_del: "➖ Delete wallet",
    wallet_deleted: "🗑 Wallet deleted",
    wallet_deleted_success: "✅ Wallet successfully deleted",
    wallet_select_delete: "💼 Select a wallet to delete:",
    wallet_deleted_error: "❌ Error",
    wallet_deleted_failed: "⚠️ Failed to delete wallet",
    wallet_send: `➕ Send an EVM wallet address
      Example:
      0x1234...abcd
      To cancel: /cancel`,
    wallet_send_canceled: "❌ Wallet addition canceled",
    wallet_sending: `ℹ️ Wallet addition in progress.
      Send an address or /cancel`,
    wallet_added: "✅ Wallet successfully added",
  },

  token_not_found: "🪙 Token <b>{symbol}</b> not found",

  // Healthfactor
  healthfactor_overview: "🛡 Your current Health Factor:",

  // Support
  support_write_message: `✍️ Write your message to support.
      To cancel — send /cancel`,
  support_new_message: "📩 New support message",
  support_message_sent: "✅ Message sent to support. Thank you!",
  support_message_error: "❌ Error sending the message.",
  support_message_canceled: "❌ Sending canceled.",
  support_name_user: "📛 Name:",
  support_message: "💬 Message:",

  // Errors
  error_generic: "❌ An error occurred. Please try again.",

  requests_limit: "⛔ Too many requests. Please try again later.",
};
