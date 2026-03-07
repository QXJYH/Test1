<div align="center">
    <p>
      <h1>DDOS Protection</h1>
    </p>
</div>

## navigation
- first go to dash.cloudflare.com
- then go to your domain
- after going to your domain scroll down on the left scroll bar
- click on security then click on security rules
- now look on the next category

## rules
* botapi
    * URI Path contains /botapi
* promocodes
    * URI Path contains /promocodes/redeem
* Skip Challenge for Roblox
    * User Agent contains Roblox and IP Source Address equals [VPS_IP]
* Challenge Non-Roblox Clients
    * Expression: ( not ip.src in { [VPS_IP] }

## Configuration
## botapi
Field - URI Path
Operator - contains
Value - /botapi

Expression Preview
`(http.request.uri.path contains "/botapi")`

Then take action - Skip

Log matching requests - yes

WAF components to skip
- Yes - All remaining custom rules
- Yes - All rate limiting rules
- Yes - All managed rules
- Yes - All Super Bot Fight Mode Rules


More components to skip
- No - Zone Lockdown
- No - User Agent Blocking
- Yes - Browser Integrity Check
- No - Hotlink Protection
- Yes - Security Level
- No - Rate limiting rules (Previous version)
- No - Managed rules (Previous version)

Place at
Select order:
- First

## promocodes
Field - URI Path
Operator - contains
Value - /promocodes/redeem

Expression Preview
`(http.request.uri.path contains "/promocodes/redeem")`

Then take action - Skip

Log matching requests - yes

WAF components to skip
- Yes - All remaining custom rules
- Yes - All rate limiting rules
- Yes - All managed rules
- Yes - All Super Bot Fight Mode Rules


More components to skip
- No - Zone Lockdown
- No - User Agent Blocking
- Yes - Browser Integrity Check
- No - Hotlink Protection
- Yes - Security Level
- No - Rate limiting rules (Previous version)
- No - Managed rules (Previous version)

Place at
Select order:
- Custom

Select which rule this will fire after:
- botapi

## Skip Challenge for Roblox
Field - User Agent
Operator - contains
Value - Roblox

and

Field - IP Source Address
Operator - equals
Value - [VPS_IP]

Expression Preview
`(http.user_agent contains "Roblox" and ip.src eq [VPS_IP])`

Then take action - Skip

Log matching requests - yes

WAF components to skip
- No - All remaining custom rules
- No - All rate limiting rules
- Yes - All managed rules
- No - All Super Bot Fight Mode Rules


More components to skip
- No - Zone Lockdown
- No - User Agent Blocking
- No - Browser Integrity Check
- No - Hotlink Protection
- No - Security Level
- No - Rate limiting rules (Previous version)
- No - Managed rules (Previous version)

Place at
Select order:
- Custom

Select which rule this will fire after:
- promocodes

## Challenge Non-Roblox Clients
Go to expression preview and in the far right theres a button called edit expression
press it then add this:
```
(
  not ip.src in {
    [VPS_IP]
  }
  and not (
    http.host eq "subdomain.your.domain"
    or http.host eq "subdomain1.your.domain"
  )
  and not (
    http.host eq "your.domain"
    and (
      starts_with(http.request.uri.path, "/apisite/")
      or starts_with(http.request.uri.path, "/thumbnails/")
      or starts_with(http.request.uri.path, "/images/")
      or starts_with(http.request.uri.path, "/thumbs/")
    )
  )
)
and not http.user_agent contains "Roblox"
and not http.user_agent contains "Discordbot"
```
Then take action - Managed Challenge

Place at
Select order:
- Custom

Select which rule this will fire after:
- Skip Challenge for Roblox
