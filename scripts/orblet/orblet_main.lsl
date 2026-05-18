// Orblet Main Script

// Handles local detection and communication with the Master Orb.

// Constants
integer CHANNEL_DISCOVERY = -100000;
integer CHANNEL_CONTROL = -100001;
integer CHANNEL_DEBUG = -100002;

string PROTOCOL_VERSION = "1.0";

integer RADIUS_MIN = 1;
integer RADIUS_MAX = 32;

integer TIMEOUT_WARNING = 30; // seconds
integer TIMEOUT_TEMP_GUEST = 120; // minutes

// Entry point
default {
    state_entry() {
        llRegionSay(CHANNEL_DISCOVERY, "HELLO|" + llGetKey() + "|" + PROTOCOL_VERSION);
        llOwnerSay("Orblet initialized.");
    }

    listen(integer channel, string name, key id, string message) {
        if (channel == CHANNEL_CONTROL) {
            // Handle control messages from the Master Orb
            llOwnerSay("Received control message: " + message);
        }
    }
}

// JSON Communication Example

// Function to parse JSON packet
handleJSONMessage(string jsonMessage) {
    list parsed = llJson2List(jsonMessage);
    string action = llList2String(parsed, llListFindList(parsed, ["action"]));
    list data = llJson2List(llList2String(parsed, llListFindList(parsed, ["data"])));

    if (action == "update_policy") {
        // Handle policy update
        llOwnerSay("Policy update received: " + llList2CSV(data));
    }
}

// Example usage in listen event
// handleJSONMessage(message);