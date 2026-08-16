# Security model

## Access keys

Production keys are **not stored in this repository**. `src/Security/Keys.lua` is intentionally empty. Configure `Config.Security.Endpoint` with an HTTPS endpoint that accepts a JSON verification request and returns an authoritative response such as:

```json
{
  "valid": true,
  "active": true,
  "plan": "monthly",
  "expiresAt": 1798761600,
  "owner": "account-id"
}
```

The backend—not the client—must enforce activation state, plan expiry, rate limits, device policy, nonce replay protection, and audit logging.

## Important limitations

- A secret embedded in public Lua source is not secret. Base64, XOR, minification, and obfuscation do not change that.
- HMAC cannot be trusted when its signing key ships to the client. Sign responses on the backend instead.
- Executor `gethwid` support varies. WiliExplorer marks account fallback IDs as `strong = false`; it does not claim that a UserId is hardware identity.
- Obfuscation may increase copying effort but is not an authorization boundary.
- Keep release signing and authoritative key data in private infrastructure.

## Reporting

Do not open a public issue containing credentials, keys, backend URLs with private tokens, or user identifiers. Revoke exposed credentials before sharing a minimal reproduction.
