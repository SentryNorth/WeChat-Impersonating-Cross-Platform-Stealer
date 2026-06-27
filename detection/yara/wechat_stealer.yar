rule wechat_stealer_loader {
    meta:
        description = "Detects the WeChat phishing zsh loader payload"
        author = "Sentry North Security Research"
        date = "2026-06-26"
        tlp = "WHITE"
    strings:
        $domain = "charlestonwaterheater.com"
        $token = "e505bde9e3545ce2361f7cc1f948dcb1124de03384544fea46e99a982a106e6f"
        $api_key = "5190ef1733183a0dc63fb623357f56d6"
        $endpoint = "/dynamic?txd="
        $staging = "/tmp/osalogging.zip"
    condition:
        any of them
}

rule fake_wechat_installer {
    meta:
        description = "Detects fake WeChat installer with decoy Firefox update"
        author = "Sentry North Security Research"
        date = "2026-06-26"
        tlp = "WHITE"
    strings:
        $wechat = "WeChat" ascii
        $firefox = "Firefox is updating" ascii
        $c2 = "charlestonwaterheater.com" ascii
        $malwarebytes = "mbam" ascii
    condition:
        uint16(0) == 0x5A4D and 2 of ($wechat, $firefox, $c2)
}
