// Constants
integer CHANNEL_DISCOVERY = -100000;
integer CHANNEL_CONTROL = -100001;

string PROTOCOL_VERSION = "1.0";

// Policy state
list bans;
list guests;
list allowedGroups;
list orblets;
string detectionMode = "PARCEL"; // or "RADIUS"
integer detectionRadius = 32;

// Send policy JSON to orblet
sendPolicy(key orbletKey) {
    string json = llList2Json(JSON_OBJECT, [
        "action", "policy_update",
        "bans", llList2Json(JSON_ARRAY, bans),
        "guests", llList2Json(JSON_ARRAY, guests),
        "groups", llList2Json(JSON_ARRAY, allowedGroups),
        "mode", detectionMode,
        "radius", (string)detectionRadius
    ]);
    llRegionSayTo(orbletKey, CHANNEL_CONTROL, json);
}

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

// Master Orb Core Functionality

// Orblet Registry
list orblets;

// Admin Commands
handleAdminCommand(string command, list args) {
    if (command == "add_ban") {
        string avatarKey = llList2String(args, 0);
        llOwnerSay("Banning avatar: " + avatarKey);
        // Add to ban list (persistent storage logic to be implemented)
    } else if (command == "remove_ban") {
        string avatarKey = llList2String(args, 0);
        llOwnerSay("Removing ban: " + avatarKey);
        // Remove from ban list
    } else if (command == "list_orblets") {
        llOwnerSay("Registered Orblets: " + llList2CSV(orblets));
    }
}

// Listen for Admin Commands
integer MENU_CHANNEL = -900000;
list mainMenu = ["Orblets", "Bans", "Guests", "Groups", "Detection Mode", "Push Policy"];

showMainMenu(key user) {
    llDialog(user, "Master Orb Menu", mainMenu, MENU_CHANNEL);
}

showDetectionMenu(key user) {
    llDialog(user, "Detection Mode", ["PARCEL", "RADIUS", "Back"], MENU_CHANNEL);
}

default {
    state_entry() {
        llListen(CHANNEL_DISCOVERY, "", NULL_KEY, "");
        llListen(CHANNEL_CONTROL, "", NULL_KEY, "");
        llListen(MENU_CHANNEL, "", NULL_KEY, "");
        llOwnerSay("Master Orb ready. Touch for menu.");
    }

    touch_start(integer n) {
        key toucher = llDetectedKey(0);
        if (toucher == llGetOwner()) showMainMenu(toucher);
    }

    listen(integer channel, string name, key id, string message) {
        if (channel == CHANNEL_DISCOVERY) {
            // Expect JSON registration
            if (llGetSubString(message, 0, 0) == "{") {
                list parsed = llJson2List(message);
                string action = llList2String(parsed, llListFindList(parsed, ["action"])+1);
                if (action == "register_orblet") {
                    if (!~llListFindList(orblets, [id])) orblets += [id];
                    llOwnerSay("Orblet registered: " + (string)id);
                    sendPolicy(id);
                } else if (action == "heartbeat") {
                    // Optionally update last-seen
                }
            }
        } else if (channel == CHANNEL_CONTROL) {
            // Admin commands or orblet status
            list parts = llParseString2List(message, ["|"], []);
            string command = llList2String(parts, 0);
            list args = llDeleteSubList(parts, 0, 0);
            handleAdminCommand(command, args);
        } else if (channel == MENU_CHANNEL) {
            if (message == "Detection Mode") showDetectionMenu(id);
            else if (message == "PARCEL" || message == "RADIUS") {
                detectionMode = message;
                llOwnerSay("Detection mode set to: " + detectionMode);
                integer i;
                for (i = 0; i < llGetListLength(orblets); ++i) sendPolicy(llList2Key(orblets, i));
                showMainMenu(id);
            } else if (message == "Back") showMainMenu(id);
            // Add more menu branches for Orblets, Bans, Guests, Groups, Push Policy as needed
        }
    }
}