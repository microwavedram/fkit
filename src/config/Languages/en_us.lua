return {
    ["fkit.description"] = "A no BS General Perpose Gun System";

    ["log.startup.success"] = "fKit Successfully started.";

    ["debug.resource_requested_no_permission"] = "Resource \"%%s\" was requested but was disallowed";
    ["debug.resource_requested_no_exist"] = "Resource \"%%s\" was requested but does not exist";
    ["debug.character_no_exist"] = "Character does not exist. Cannot equip.";
    
    ["warn.weapon.no_equip"] = "Failed to find an equip animation at \"%%s\", skipping";
    ["debug.weapon.no_server_id"] = "Failed to get a server id for behavior, generating tempory client id.";
    ["error.weapon.behavior_fail_load"] = "WeaponBehavior \"%%s\" failed to load. \n%%s";
    ["error.weapon.behavior_type_fail_load"] = "BehaviorType \"%%s\" failed to load. \n%%s";
    ["error.weapon.viewmodel.weld_to_no_exist"] = "The WeldTo point of %%s does not exist.";

    ["error.animation.different_models"] = "Unable to generate transition on animations that are on different instances (%%s, %%s)";
    ["error.animation.transition_to_animation_playing"] = "Animation to transition to must not be playing. {%%s}";
}