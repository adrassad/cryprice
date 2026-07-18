/// SessionStorage keys shared with `web/index.html` controllerchange guard.
const String kAuthFlowInProgressKey = 'cryprice_auth_flow_in_progress';
const String kAuthFlowStartedAtKey = 'cryprice_auth_flow_started_at';
const String kSwReloadPendingKey = 'cryprice_sw_reload_pending';

const Duration kAuthFlowGuardTimeout = Duration(minutes: 2);
