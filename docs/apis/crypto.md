# Crypto

[Learn more via the developer docs](https://developers.cloudflare.com/workers/runtime-apis/web-crypto/)

## Importing

```zig
const worker = @import("workers-zig");
const getRandomValues = worker.getRandomValues;
const randomUUID = worker.randomUUID;
```

## getRandomValues
```zig
pub fn getRandomValues (buf: []const u8) void
```

## randomUUID
```zig
pub fn randomUUID () []const u8
```
