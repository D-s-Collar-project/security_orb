// JSON Communication Example

// Function to send JSON packet to Orblets
sendJSONToOrblet(key orbletKey, string action, list data) {
    string jsonPacket = llList2Json(JSON_OBJECT, [
        "action", action,
        "data", llList2Json(JSON_ARRAY, data)
    ]);
    llRegionSayTo(orbletKey, CHANNEL_CONTROL, jsonPacket);
}

// Example usage
// sendJSONToOrblet(orbletKey, "update_policy", ["policy_version", 2]);