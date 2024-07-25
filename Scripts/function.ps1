
function New-Sharedpassword {
    <#
    .SYNOPSIS
    Generate a new shared password and shared url.

    .DESCRIPTION
    This function generates a new shared password and pushes it to the web. The password is retrievable via the returned URL. The password is set to expire after a certain number of views or days. The password and url are returned as a hashtable object with the keys "password" and "url".

    .PARAMETER expireviews
    The number of views after which the password will expire.

    .PARAMETER expiredays
    The number of days after which the password will expire.

    .PARAMETER pwpushurl
    The URL of the password push service.

    .EXAMPLE
    New-Sharedpassword

    .EXAMPLE
    New-Sharedpassword -length 12 -expireviews 30 -expiredays 14 -pwpushurl "https://pw.yesit.com.au/

    .NOTES
    #>

    param (
        $length = 12,
        $expireviews = 30,
        $expiredays = 14,
        $pwpushurl = "https://pw.yesit.com.au/"
    )

    $password = ""
    while ($password.Length -le $length) {
        $passwordraw = Invoke-WebRequest "https://www.dinopass.com/password/strong"
        $password = $passwordraw.Content
    }


    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")

    $body = @"
    {
        "password": {
            "payload": "$password",
            "retrieval_step": true,
            "expire_after_views": $expireviews,
            "expire_after_days": $expiredays
        }
    }
"@

    $response = Invoke-RestMethod ($pwpushurl + 'p.json') -Method 'POST' -Headers $headers -Body $body
    $url = ($pwpushurl + 'p/' + $response.url_token + "/r")

    $result = @{
        "password" = $password
        "url"      = $url
    }

    return $result
}
