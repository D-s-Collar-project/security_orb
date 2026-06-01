// Persistent Storage Service

// Add Admin
addAdmin(key adminKey) {
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXT, "Adding admin: " + (string)adminKey, <1,1,1>, 1.0]);
    llMessageLinked(LINK_THIS, 0, "add_admin|" + (string)adminKey, "");
}

// Remove Admin
removeAdmin(key adminKey) {
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXT, "Removing admin: " + (string)adminKey, <1,1,1>, 1.0]);
    llMessageLinked(LINK_THIS, 0, "remove_admin|" + (string)adminKey, "");
}

// List Admins
listAdmins() {
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEXT, "Listing admins...", <1,1,1>, 1.0]);
    llMessageLinked(LINK_THIS, 0, "list_admins", "");
}

// Example Usage
// addAdmin("example-key");
// removeAdmin("example-key");
// listAdmins();