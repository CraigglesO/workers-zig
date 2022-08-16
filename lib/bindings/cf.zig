const std = @import("std");
const allocator = std.heap.page_allocator;
const getString = @import("string").getString;
const jsFree = @import("common.zig").jsFree;
const getObjectValue = @import("object.zig").getObjectValue;
const Request = @import("request").Request;
// The `Cf` struct on an inbound Request contains information
// about the request provided by Cloudflare’s edge.
// [Details](https://developers.cloudflare.com/workers/runtime-apis/request#incomingrequestcfproperties)

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L744
pub const IncomingRequestCfProperties = struct {
  // (e.g. 395747)
  asn: u32 = undefined,
  // The organisation which owns the ASN of the incoming request. (e.g. Google Cloud)
  asOrganization: []const u8 = undefined,
  botManagement: ?BotManagement = null,
  city: ?[]const u8 = null,
  clientAcceptEncoding: ?[]const u8 = null,
  clientTcpRtt: u32 = undefined,
  clientTrustScore: ?u32 = null,
  // The three-letter airport code of the data center that the request (e.g. "DFW")
  colo: []const u8 = undefined,
  continent: ?[]const u8 = null,
  // The two-letter country code in the request. This is the same value
  // as that provided in the CF-IPCountry header. (e.g. "US")
  country: []const u8 = undefined,
  httpProtocol: []const u8 = undefined,
  latitude: ?f32 = null,
  longitude: ?f32 = null,
  // DMA metro code from which the request was issued, e.g. "635"
  metroCode: ?[]const u8 = null,
  postalCode: ?[]const u8 = null,
  // e.g. "Texas"
  region: ?[]const u8 = null,
  // e.g. "TX"
  regionCode: ?[]const u8 = null,
  // e.g. "weight=256;exclusive=1"
  requestPriority: []const u8 = undefined,
  timezone: ?[]const u8 = null,
  tlsVersion: []const u8 = undefined,
  tlsCipher: []const u8 = undefined,
  tlsClientAuth: TlsClientAuth = undefined,

  // Bot managment
  // [Details](https://developers.cloudflare.com/bots/reference/bot-management-variables)
  // https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L799
  pub const BotManagement = struct {
    score: u8 = 0,
    staticResource: bool = false,
    verifiedBot: bool = false,
  };

  // https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L805
  pub const TlsClientAuth = struct {
    certIssuerDNLegacy: []const u8 = undefined,
    certIssuerDN: []const u8 = undefined,
    // "0" | "1"
    certPresented: []const u8 = undefined,
    certSubjectDNLegacy: []const u8 = undefined,
    certSubjectDN: []const u8 = undefined,
    // In format "Dec 22 19:39:00 2018 GMT"
    certNotBefore: []const u8 = undefined,
    // In format "Dec 22 19:39:00 2018 GMT"
    certNotAfter: []const u8 = undefined,
    certSerial: []const u8 = undefined,
    certFingerprintSHA1: []const u8 = undefined,
    // "SUCCESS", "FAILED:reason", "NONE"
    certVerified: []const u8 = undefined
  };

  pub fn init (req: Request) !IncomingRequestCfProperties {
    const jsPtr = getObjectValue(req.id, "cf");
    defer jsFree(jsPtr);
    const str = getString(jsPtr);
    defer allocator.free(str);
    const stream = std.json.TokenStream.init(str);
    return try std.json.parse(IncomingRequestCfProperties, &stream, .{});
  }
};

// In addition to the properties you can set in the RequestInit dict
// that you pass as an argument to the Request constructor, you can
// set certain properties of a `cf` object to control how Cloudflare
// features are applied to that new Request.

pub const RequestInitCfProperties = struct {
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
  // TODO: FOR NOW THIS IS NOT IMPLEMENTED because it is a pain to implement.
  cacheTtlByStatus: ?[]const u8 = null,
  scrapeShield: bool = false,
  apps: bool = false,
  // TODO: This is a lot of work.. worry about it later.
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
  none
};
