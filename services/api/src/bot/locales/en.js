// src/locales/en.js
export default {
  common: {
    yes: "Yes",
    no: "No",
    notSpecified: "not specified",
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
  nothing_to_cancel: "Nothing to cancel.",
  threshold_value: "Пороговое значение HealthFactor: ",

  //profile
  profile: {
    title: "👤 <b>Profile</b>",
    notFound: "❌ Profile not found.",
    telegramId: "🆔 <b>Telegram ID:</b> <code>{telegramId}</code>",
    name: "🙍 <b>Name:</b> {name}",
    username: "🔗 <b>Username:</b> {username}",
    settingsTitle: "⚙️ <b>Settings</b>",
    threshold: "📉 <b>Health Factor threshold:</b> {value}",
  },

  start_linked_success: `✅ Bot is already activated.

You will receive CryPrice notifications here.
You can change your settings in your profile:
https://app.cryprice.dev`,

  start_not_linked: `👋 Welcome to CryPrice.

To activate the Telegram bot, first sign in to your account on the website and connect Telegram in your profile settings:

https://app.cryprice.dev

This keeps the bot linked to your main account and prevents duplicate accounts.`,

  start_link_success: `✅ Telegram has been successfully connected to your CryPrice account.

You can now receive notifications here.
You can change your settings in your profile:
https://app.cryprice.dev`,

  start_link_failed: `❌ Failed to connect Telegram.

The link may be expired or already used.
Please create a new link in your profile settings:
https://app.cryprice.dev`,

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
  support_public_notice:
    "💬 For support, open the CryPrice app after sign-in or use the public repository issue tracker.",

  // Positions and Aave
  no_active_positions: "ℹ️ No active positions in Aave.",
  positions_overview: "📊 Your current positions:",

  no_user: "❌ User not found",
  novalid_address: "❌ Invalid address.\n\nSend a valid address or /cancel",
  wallet_limit_reached:
    "⚠️ Wallet limit reached. Remove an existing wallet before adding another.",

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

  // Errors
  error_generic: "❌ An error occurred. Please try again.",

  requests_limit: "⛔ Too many requests. Please try again later.",
};
