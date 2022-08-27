const std = @import("std");
const allocator = std.heap.page_allocator;
const getStringFree = @import("string").getStringFree;
const getObjectValue = @import("object.zig").getObjectValue;
const getObjectValueNum = @import("object.zig").getObjectValueNum;
const Request = @import("request").Request;
const common = @import("common.zig");
const jsFree = common.jsFree;
const Null = common.Null;
const True = common.True;
const DefaultValueSize = common.DefaultValueSize;
// The `Cf` struct on an inbound Request contains information
// about the request provided by Cloudflare’s edge.
// [Details](https://developers.cloudflare.com/workers/runtime-apis/request#incomingrequestcfproperties)

// Bot managment
// [Details](https://developers.cloudflare.com/bots/reference/bot-management-variables)
// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L799
pub const IncomingRequestCfPropertiesBotManagement = struct {
  id: u32,

  pub fn init (ptr: u32) IncomingRequestCfPropertiesBotManagement {
    return IncomingRequestCfPropertiesBotManagement{ .id = ptr };
  }

  pub fn score (self: *const IncomingRequestCfPropertiesTLSClientAuth) u8 {
    return getObjectValueNum(self.id, "score", u8);
  }

  pub fn staticResource (self: *const IncomingRequestCfPropertiesTLSClientAuth) bool {
    const jsPtr = getObjectValue(self.id, "staticResource");
    return jsPtr == True;
  }

  pub fn verifiedBot (self: *const IncomingRequestCfPropertiesTLSClientAuth) bool {
    const jsPtr = getObjectValue(self.id, "verifiedBot");
    return jsPtr == True;
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L805
pub const IncomingRequestCfPropertiesTLSClientAuth = struct {
  id: u32,

  pub fn init (ptr: u32) IncomingRequestCfPropertiesTLSClientAuth {
    return IncomingRequestCfPropertiesTLSClientAuth{ .id = ptr };
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certIssuerDNLegacy (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certIssuerDNLegacy");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certIssuerSKI (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certIssuerSKI");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certSubjectDNRFC2253 (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certSubjectDNRFC2253");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certSubjectDNLegacy (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certSubjectDNLegacy");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certFingerprintSHA256 (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certFingerprintSHA256");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certNotBefore (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certNotBefore");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certSKI (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certSKI");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certSerial (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certSerial");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certIssuerDN (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certIssuerDN");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certVerified (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certVerified");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certNotAfter (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certNotAfter");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certSubjectDN (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certSubjectDN");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certPresented (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certPresented");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certRevoked (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certRevoked");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certIssuerSerial (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certIssuerSerial");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certIssuerDNRFC2253 (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certIssuerDNRFC2253");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn certFingerprintSHA1 (self: *const IncomingRequestCfPropertiesTLSClientAuth) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "certFingerprintSHA1");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L744
pub const IncomingRequestCfProperties = struct {
  id: u32,

  pub fn init (ptr: u32) IncomingRequestCfProperties {
    return IncomingRequestCfProperties{ .id = ptr };
  }

  // (e.g. 395747)
  pub fn asn (self: *const IncomingRequestCfProperties) u32 {
    return getObjectValueNum(self.id, "asn", u32);
  }

  // The organisation which owns the ASN of the incoming request. (e.g. Google Cloud)
  pub fn asOrganization (self: *const IncomingRequestCfProperties) []const u8 {
    const jsPtr = getObjectValue(self.id, "asOrganization");
    return getStringFree(jsPtr);
  }

  pub fn botManagement (self: *const IncomingRequestCfProperties) ?IncomingRequestCfPropertiesBotManagement {
    const jsPtr = getObjectValue(self.id, "botManagement");
    if (jsPtr <= DefaultValueSize) return;
    return IncomingRequestCfPropertiesBotManagement.init(getObjectValue(self.id, "botManagement"));
  }

  pub fn city (self: *const IncomingRequestCfProperties) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "city");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  pub fn clientAcceptEncoding (self: *const IncomingRequestCfProperties) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "clientAcceptEncoding");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  pub fn clientTcpRtt (self: *const IncomingRequestCfProperties) u32 {
    return getObjectValueNum(self.id, "clientTcpRtt", u32);
  }

  // NOTE: If clientTrustScore was undefined, 0 is returned.
  pub fn clientTrustScore (self: *const IncomingRequestCfProperties) u32 {
    return getObjectValueNum(self.id, "clientTrustScore", u32);
  }

  // The three-letter airport code of the data center that the request (e.g. "DFW")
  // NOTE: Be sure to free the memory returned by this function.
  pub fn colo (self: *const IncomingRequestCfProperties) []const u8 {
    const jsPtr = getObjectValue(self.id, "colo");
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn continent (self: *const IncomingRequestCfProperties) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "continent");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // The two-letter country code in the request. This is the same value
  // as that provided in the CF-IPCountry header. (e.g. "US")
  // NOTE: Be sure to free the memory returned by this function.
  pub fn country (self: *const IncomingRequestCfProperties) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "country");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // NOTE: Be sure to free the memory returned by this function.
  pub fn httpProtocol (self: *const IncomingRequestCfProperties) []const u8 {
    const jsPtr = getObjectValue(self.id, "httpProtocol");
    return getStringFree(jsPtr);
  }

  // NOTE: If latitude was undefined, this will return 0
  pub fn latitude (self: *const IncomingRequestCfProperties) f32 {
    return getObjectValueNum(self.id, "latitude", f32);
  }

  // NOTE: If latitude was undefined, this will return 0
  pub fn longitude (self: *const IncomingRequestCfProperties) f32 {
    return getObjectValueNum(self.id, "longitude", f32);
  }

  // DMA metro code from which the request was issued, e.g. "635"
  // NOTE: Be sure to free the memory returned by this function.
  pub fn metroCode (self: *const IncomingRequestCfProperties) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "metroCode");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  pub fn postalCode (self: *const IncomingRequestCfProperties) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "postalCode");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // e.g. "Texas"
  pub fn region (self: *const IncomingRequestCfProperties) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "region");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // e.g. "TX"
  pub fn regionCode (self: *const IncomingRequestCfProperties) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "regionCode");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // e.g. "weight=256;exclusive=1"
  pub fn requestPriority (self: *const IncomingRequestCfProperties) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "requestPriority");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  pub fn timezone (self: *const IncomingRequestCfProperties) ?[]const u8 {
    const jsPtr = getObjectValue(self.id, "timezone");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  // TODO: Use http/common/tlsVersion
  pub fn tlsVersion (self: *const IncomingRequestCfProperties) []const u8 {
    const jsPtr = getObjectValue(self.id, "tlsVersion");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  pub fn tlsCipher (self: *const IncomingRequestCfProperties) []const u8 {
    const jsPtr = getObjectValue(self.id, "tlsCipher");
    if (jsPtr <= DefaultValueSize) return;
    return getStringFree(jsPtr);
  }

  pub fn tlsClientAuth (self: *const IncomingRequestCfProperties) IncomingRequestCfPropertiesTLSClientAuth {
    return IncomingRequestCfPropertiesTLSClientAuth.init(getObjectValue(self.id, "tlsClientAuth"));
  }
};

// "cf": {
//         "longitude": "-78.45030",
//         "latitude": "35.63530",
//         "tlsCipher": "AEAD-AES128-GCM-SHA256",
//         "continent": "NA",
//         "asn": 11426,
//         "clientAcceptEncoding": "gzip, deflate, br",
//         "country": "US",
//         "tlsExportedAuthenticator": {
//           "clientFinished": "0d52b026d8e6a94e6c2fe14879076aadf8fdd397c098e06fdc7c5ad4e1a94086",
//           "clientHandshake": "71f05fbcdeaefdefc0fb9f8900292d8ee178d612f776c689b5febd2231f84f16",
//           "serverHandshake": "f59e9dc65da572544f0517ecc617be884b11316a3ef7e8f932891052f5534a68",
//           "serverFinished": "17482eb549da9c2f82b9b0ad287a7ea0615ae213cc4264d075852683b8df2434"
//         },
//         "tlsVersion": "TLSv1.3",
//         "colo": "IAD",
//         "timezone": "America/New_York",
//         "city": "Clayton",
//         "edgeRequestKeepAliveStatus": 1,
//         "requestPriority": "",
//         "httpProtocol": "HTTP/3",
//         "region": "North Carolina",
//         "regionCode": "NC",
//         "asOrganization": "Spectrum",
//         "metroCode": "560",
//         "postalCode": "27520"
//       }
//     },

// In addition to the properties you can set in the RequestInit dict
// that you pass as an argument to the Request constructor, you can
// set certain properties of a `cf` object to control how Cloudflare
// features are applied to that new Request.

// TODO: This is a lot of work.. worry about it later.
// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1290
pub const RequestInitCfProperties = struct {
  id: u32,
  cacheEverything: bool = false,
  // A request's cache key is what determines if two requests are
  // "the same" for caching purposes. If a request has the same cache key
  // as some previous request, then we can serve the same cached response for
  // both. (e.g. 'some-key')
  cacheKey: ?[]const u8 = null,
  // This allows you to append additional Cache-Tag response headers
  // to the origin response without modifications to the origin server.
  // This will allow for greater control over the Purge by Cache Tag feature
  // utilizing changes only in the Workers process.
  cacheTags: ?[]const u8 = null,
  // Force response to be cached for a given number of seconds. (e.g. 300)
  cacheTtl: ?u32 = null,
  // Force response to be cached for a given number of seconds based on the Origin status code.
  // (e.g. { '200-299': 86400, '404': 1, '500-599': 0 })
  cacheTtlByStatus: ?[]const u8 = null, // this isn't correct, relook at it later
  scrapeShield: bool = false,
  apps: bool = false,
  // image: ?RequestInitCfPropertiesImage = null,
  // minify: ?RequestInitCfPropertiesImageMinify,
  image: ?[]const u8 = null,
  minify: ?[]const u8 = null,
  mirage: bool = false,
  // "lossy" | "lossless" | "off"
  polish: ?[]const u8 = null,
  // Redirects the request to an alternate origin server. You can use this,
  // for example, to implement load balancing across several origins.
  // (e.g.us-east.example.com)
  //
  // Note - For security reasons, the hostname set in resolveOverride must
  // be proxied on the same Cloudflare zone of the incoming request.
  // Otherwise, the setting is ignored. CNAME hosts are allowed, so to
  // resolve to a host under a different domain or a DNS only domain first
  // declare a CNAME record within your own zone’s DNS mapping to the
  // external hostname, set proxy on Cloudflare, then set resolveOverride
  // to point to that CNAME record.
  resolveOverride: ?[]const u8 = null,
};

pub const CfRequestInit = union(enum) {
  incomingRequestCfProperties: *const IncomingRequestCfProperties,
  requestInitCfProperties: *const RequestInitCfProperties,
  none,

  pub fn toID (self: *const CfRequestInit) u32 {
    var cfID: u32 = Null;
    switch (self.*) {
      .incomingRequestCfProperties => |crp| cfID = crp.id,
      .requestInitCfProperties => |rip| cfID = rip.id,
      .none => {},
    }
    return cfID;
  }
};
