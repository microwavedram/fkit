-- Welcome to fKit's Main Config

return {
    --[[
        -- README --
        Hey there, this is a short message from the fKit developer.
        Just want everyone who uses this to understand why it was made,
        and my annoyance with other frameworks.

        fKit was made from a combination between:
         - boredom
         - annoyance with other frameworks
         - dislike of obfuscation

        fKit is currently open source and always will be.
        as a developer myself, I find the fact that obfuscation is required for anything
        of value in this day and age particually annoying. Obfuscation helps no one but those
        who make money off it. I could have very easily obfuscated this whole
        framework and started forcing people to buy it with excessive amounts of money, however
        I believe that this is the wrong approch as it prevents you (a developer)
        from building upon this framework and spinning it to your requirements.

        Thank You
        (you can now go set "I_HAVE_READ_THIS = true")
        
        All of the original source code and instructions can be
        found on github (https://github.com/microwavedram/fkit)
    ]]
    I_HAVE_READ_THIS = true;

    --[[
        things developers need to know

        - all paths to instances ("Arms/Development Arms") are rooted at ServerScriptService/fKit/Resources
        - for a client to access a resource, the resource requested needs to have the Client attribute set to true
        - animations are done using a custom animation runner. animations are stored as keyframe sequences.
        - keyframe sequences can be got from the target you are animating's AnimSaves model contained within after saving an animation
    ]]


    -- LANGUAGE --
    LANGUAGE = "en_us"; -- translators i need u :)
    
    -- VIEWMODEL --
    Viewmodel = {
        Viewmodel = "Arms/Development Arms";
        
        -- Used to try and replicate the client animations for other players
        -- ["Character Part"] = {Origin = "Viewmodel Arm Origin, Target = "Viewmodel Hand"}
        InverseKinematicsTargets = {
            ["RightHand"] = {Origin = "RightArmRoot", Target = "RightHand"};
            ["LeftHand"] = {Origin = "LeftArmRoot", Target = "LeftHand"};
        };

        -- Viewmodel Arm Spring [Camera->ViewmodelRoot]
        Spring = {
            Speed = 50;
            Damper = 0.8
        };
    };

    DynamicCrosshair = {
        CastDistance = 4000;
        CastParams = (function()
            local CastParams = RaycastParams.new();
            CastParams.RespectCanCollide = true
            return CastParams
        end)()
    };
}