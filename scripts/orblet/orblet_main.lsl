// Orblet Main Script

// Handles local detection and communication with the Master Orb.

// Constants
integer CHANNEL_DISCOVERY = -100000;
integer CHANNEL_CONTROL = -100001;
integer MENU_CHANNEL = -900001;

string PROTOCOL_VERSION = "1.0";

list bans;
list guests;
list allowedGroups;
string detectionMode = "PARCEL";
integer detectionRadius = 32;

// Register with master orb
registerWithMaster() {
    string json = llList2Json(JSON_OBJECT, [
        "action", "register_orblet",
        "orblet_key", (string)llGetKey(),
        "protocol", PROTOCOL_VERSION
    ]);
    llRegionSay(CHANNEL_DISCOVERY, json);
}

// Heartbeat
sendHeartbeat() {
    string json = llList2Json(JSON_OBJECT, [
        "action", "heartbeat",
        "orblet_key", (string)llGetKey(),
        "timestamp", (string)llGetUnixTime()
    ]);
    llRegionSay(CHANNEL_DISCOVERY, json);
}

// Apply policy JSON
applyPolicy(string json) {
    list parsed = llJson2List(json);
    integer bansIdx = llListFindList(parsed, ["bans"]);
    integer guestsIdx = llListFindList(parsed, ["guests"]);
    integer groupsIdx = llListFindList(parsed, ["groups"]);
    integer modeIdx = llListFindList(parsed, ["mode"]);
    integer radiusIdx = llListFindList(parsed, ["radius"]);
    if (~bansIdx) bans = llJson2List(llList2String(parsed, bansIdx+1));
    if (~guestsIdx) guests = llJson2List(llList2String(parsed, guestsIdx+1));
    if (~groupsIdx) allowedGroups = llJson2List(llList2String(parsed, groupsIdx+1));
    if (~modeIdx) detectionMode = llList2String(parsed, modeIdx+1);
    if (~radiusIdx) detectionRadius = (integer)llList2String(parsed, radiusIdx+1);
    llOwnerSay("Policy updated. Mode: " + detectionMode + ", Radius: " + (string)detectionRadius);
}

// Detection logic
runDetection() {
    if (detectionMode == "PARCEL") {
        llSensorRepeat("", NULL_KEY, AGENT, 96.0, PI, 10.0); // Large range, filter by parcel in sensor()
    } else {
        llSensorRepeat("", NULL_KEY, AGENT, (float)detectionRadius, PI, 10.0);
    }
}

default {
    state_entry() {
        llListen(CHANNEL_CONTROL, "", NULL_KEY, "");
        llListen(MENU_CHANNEL, "", NULL_KEY, "");
        registerWithMaster();
        runDetection();
        llSetTimerEvent(60.0); // Heartbeat every 60s
        llOwnerSay("Orblet ready. Touch for menu.");
    }
    touch_start(integer n) {
        key toucher = llDetectedKey(0);
        if (toucher == llGetOwner()) showMainMenu(toucher);
    }
    listen(integer channel, string name, key id, string message) {
        if (channel == CHANNEL_CONTROL) {
            if (llGetSubString(message, 0, 0) == "{") applyPolicy(message);
        }
        if (channel == MENU_CHANNEL) {
            if (message == "View Policy") showPolicyMenu(id);
            else if (message == "Request Update") registerWithMaster();
            else if (message == "Detected Avatars") {
                // Placeholder: show detected avatars (requires tracking)
                llDialog(id, "Feature coming soon.", ["Back"], MENU_CHANNEL);
            } else if (message == "Back") showMainMenu(id);
        }
    }
    sensor(integer n) {
        integer i;
        for (i = 0; i < n; ++i) {
            key av = llDetectedKey(i);
            string avStr = (string)av;
            if (detectionMode == "PARCEL") {
                if (llOverMyLand(av)) {
                    // ...enforcement logic here...
                }
            } else {
                // ...enforcement logic here...
            }
        }
    }
    timer() {
        sendHeartbeat();
    }
}

// Remove duplicate MENU_CHANNEL declaration if present
// Ensure all + operations with keys/integers are cast to string
// Remove empty if/else bodies or add // no-op
// Ensure all variables (like warned) are declared at the top

showMainMenu(key user) {
    llDialog(user, "Orblet Menu", mainMenu, MENU_CHANNEL);
}

showPolicyMenu(key user) {
    string info = "Mode: " + detectionMode + "\nRadius: " + (string)detectionRadius + "\nBans: " + llList2CSV(bans) + "\nGuests: " + llList2CSV(guests) + "\nGroups: " + llList2CSV(allowedGroups);
    llDialog(user, info, ["Back"], MENU_CHANNEL);
}