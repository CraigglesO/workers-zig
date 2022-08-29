const std = @import("std");
const common = @import("../bindings/common.zig");
const Classes = common.Classes;
const jsFree = common.jsFree;
const jsCreateClass = common.jsCreateClass;
const toJSBool = common.toJSBool;
const Array = @import("../bindings/array.zig").Array;
const ArrayBuffer = @import("../bindings/arraybuffer.zig").ArrayBuffer;
const object = @import("../bindings/object.zig");
const Object = object.Object;
const getObjectValue = object.getObjectValue;
const string = @import("../bindings/string.zig");
const String = string.String;
const getStringFree = string.getStringFree;

pub extern fn jsGetRandomValues (bufPtr: u32) void;
// NOTE: be sure to free the bytes after use
pub fn getRandomValues (buf: []const u8) void {
  // 1) push the buf over to js
  const ab = ArrayBuffer.new(buf);
  const uint8 = jsCreateClass(Classes.Uint8Array, ab.id);
  // 2) create the random values
  jsGetRandomValues(uint8);
  // 3) re-ownership of bytes
  return ab.bytes();
}
pub extern fn jsRandomUUID () [*:0]const u8;
// NOTE: be sure to free the string after use
pub fn randomUUID () []const u8 {
  const rand = jsRandomUUID();
  return std.mem.span(rand);
}

// https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto
// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1561
// encrypt(
//   algorithm: string | SubtleCryptoEncryptAlgorithm,
//   key: CryptoKey,
//   plainText: ArrayBuffer | ArrayBufferView
// ): Promise<ArrayBuffer>;
// decrypt(
//   algorithm: string | SubtleCryptoEncryptAlgorithm,
//   key: CryptoKey,
//   cipherText: ArrayBuffer | ArrayBufferView
// ): Promise<ArrayBuffer>;
// sign(
//   algorithm: string | SubtleCryptoSignAlgorithm,
//   key: CryptoKey,
//   data: ArrayBuffer | ArrayBufferView
// ): Promise<ArrayBuffer>;
// verify(
//   algorithm: string | SubtleCryptoSignAlgorithm,
//   key: CryptoKey,
//   signature: ArrayBuffer | ArrayBufferView,
//   data: ArrayBuffer | ArrayBufferView
// ): Promise<boolean>;
// digest(
//   algorithm: Hash,
//   data: ArrayBuffer | ArrayBufferView
// ): Promise<ArrayBuffer>;
// generateKey(
//   algorithm: string | SubtleCryptoGenerateKeyAlgorithm,
//   extractable: boolean,
//   keyUsages: string[]
// ): Promise<CryptoKey | CryptoKeyPair>;
// deriveKey(
//   algorithm: string | SubtleCryptoDeriveKeyAlgorithm,
//   baseKey: CryptoKey,
//   derivedKeyAlgorithm: string | SubtleCryptoImportKeyAlgorithm,
//   extractable: boolean,
//   keyUsages: string[]
// ): Promise<CryptoKey>;
// deriveBits(
//   algorithm: string | SubtleCryptoDeriveKeyAlgorithm,
//   baseKey: CryptoKey,
//   length: number | null
// ): Promise<ArrayBuffer>;
// importKey(
//   format: string,
//   keyData: ArrayBuffer,
//   algorithm: string | SubtleCryptoImportKeyAlgorithm,
//   extractable: boolean,
//   keyUsages: string[]
// ): Promise<CryptoKey>;
// exportKey(format: string, key: CryptoKey): Promise<ArrayBuffer>;
// wrapKey(
//   format: string,
//   key: CryptoKey,
//   wrappingKey: CryptoKey,
//   wrapAlgorithm: string | SubtleCryptoEncryptAlgorithm
// ): Promise<ArrayBuffer>;
// unwrapKey(
//   format: string,
//   wrappedKey: ArrayBuffer | ArrayBufferView,
//   unwrappingKey: CryptoKey,
//   unwrapAlgorithm: string | SubtleCryptoEncryptAlgorithm,
//   unwrappedKeyAlgorithm: string | SubtleCryptoImportKeyAlgorithm,
//   extractable: boolean,
//   keyUsages: string[]
// ): Promise<CryptoKey>;

pub const Data = union(enum) {
  bytes: []const u8,
  arrayBuffer: ArrayBuffer,

  pub fn toID (self: *const Data) u32 {
    switch (self.*) {
      .bytes => |b| return ArrayBuffer.new(b).id,
      .arrayBuffer => |*ab| return ab.id,
    }
  }

  pub fn free (self: *const Data, id: u32) void {
    switch (self.*) {
      .bytes => jsFree(id),
      else => {},
    }
  }
};

pub const SubtleCryptoDeriveKeyAlgorithm = struct {
  name: []const u8,
  salt: ?Data = null,
  iterations: ?u32 = null,
  hash: ?Hash = null,
  public: ?CryptoKey = null,
  info: ?Data = null,
};

pub const Hash = union(enum) {
  string: []const u8,
  algorithm: CryptoKeyKeyAlgorithm,

  pub fn toID (self: *const Hash) u32 {
    switch (self.*) {
      .string => |str| return String(str).id,
      .algorithm => |h| return h.toObject().id,
    }
  }

  pub fn free (id: u32) void {
    jsFree(id);
  }
};

pub const CryptoKeyKeyAlgorithm = struct {
  name: []const u8,

  pub fn toObject (self: *const CryptoKeyKeyAlgorithm) Object {
    const obj = Object.new();
    obj.setText("name", self.name);
    return obj;
  }
};

pub const SubtleCryptoEncryptAlgorithm = struct {
  name: []const u8,
  iv: ?Data,
  additionalData: ?Data,
  tagLength: ?u32,
  counter: ?Data,
  length: ?u32,
  label: ?Data,

  pub fn toObject (self: *const SubtleCryptoEncryptAlgorithm) u32 {
    const obj = Object.new();
    obj.setText("name", self.name);
    if (self.iv != null) {
      const id = self.iv.?.toID();
      defer self.iv.?.free(id);
      obj.setID("iv", id);
    }
    if (self.additionalData != null) {
      const id = self.additionalData.?.toID();
      defer self.additionalData.?.free(id);
      obj.setID("additionalData", id);
    }
    if (self.tagLength != null) obj.setNum("tagLength", self.tagLength.?);
    if (self.counter != null) {
      const id = self.counter.?.toID();
      defer self.counter.?.free(id);
      obj.setID("counter", id);
    }
    if (self.length != null) obj.setNum("length", self.length.?);
    if (self.label != null) {
      const id = self.label.?.toID();
      defer self.label.?.free(id);
      obj.setID("label", id);
    }
  }
};

pub const SubtleCryptoGenerateKeyAlgorithm = struct {
  name: []const u8,
  hash: ?Hash,
  modulusLength: ?u32,
  publicExponent: ?Data,
  length: ?u32,
  namedCurve: ?[]const u8,

  pub fn toObject (self: *const SubtleCryptoGenerateKeyAlgorithm) u32 {
    const obj = Object.new();
    obj.setText("name", self.name);
    if (self.hash != null) {
      const id = self.hash.?.toID();
      defer self.hash.?.free(id);
      obj.setID("hash", id);
    }
    if (self.modulusLength != null) obj.setNum("modulusLength", self.modulusLength.?);
    if (self.publicExponent != null) {
      const id = self.publicExponent.?.toID();
      defer self.publicExponent.?.free(id);
      obj.setID("publicExponent", id);
    }
    if (self.length != null) obj.setNum("length", self.length.?);
    if (self.namedCurve != null) obj.setText("namedCurve", self.namedCurve.?);
  }
};

pub const SubtleCryptoImportKeyAlgorithm = struct {
  name: []const u8,
  hash: ?Hash,
  length: ?u32,
  namedCurve: ?[]const u8,
  compressed: ?bool,

  pub fn toObject (self: *const SubtleCryptoImportKeyAlgorithm) u32 {
    const obj = Object.new();
    obj.setText("name", self.name);
    if (self.hash != null) {
      const id = self.hash.?.toID();
      defer self.hash.?.free(id);
      obj.setID("hash", id);
    }
    if (self.length != null) obj.setNum("length", self.length.?);
    if (self.namedCurve != null) obj.setText("namedCurve", self.namedCurve.?);
    if (self.compressed != null) obj.setID("compressed", toJSBool(self.compressed));
  }
};

// interface SubtleCryptoImportKeyAlgorithm {
//   name: string;
//   hash?: Hash;
//   length?: number;
//   namedCurve?: string;
//   compressed?: boolean;
// }

pub const SubtleCryptoSignAlgorithm = struct {
  name: []const u8,
  hash: ?Hash,
  dataLength: ?u32,
  saltLength: ?u32,

  pub fn toObject (self: *const SubtleCryptoSignAlgorithm) u32 {
    const obj = Object.new();
    obj.setText("name", self.name);
    if (self.hash != null) {
      const id = self.hash.?.toID();
      defer self.hash.?.free(id);
      obj.setID("hash", id);
    }
    if (self.dataLength != null) obj.setNum("dataLength", self.dataLength.?);
    if (self.saltLength != null) obj.setNum("saltLength", self.saltLength.?);
  }
};

pub const CryptoKey = struct {
  id: u32,

  pub fn init (jsPtr: u32) CryptoKey {
    return CryptoKey{ .id = jsPtr };
  }

  pub fn free (self: *const CryptoKey) void {
    jsFree(self);
  }

  pub fn getType (self: *const CryptoKey) []const u8 {
    return getStringFree(getObjectValue(self.id, "type"));
  }

  pub fn extractable (self: *const CryptoKey) bool {
    const b = getObjectValue(self.id, "extractable");
    return b == true;
  }

  // pub fn algorithm (self: *const CryptoKey) CryptoKeyAlgorithmVariant {
  //   return CryptoKeyAlgorithmVariant.init(getObjectValue(self.id, "algorithm"));
  // }

  pub fn usages (self: *const CryptoKey) [][]const u8 {
    const arr = Array.new(getObjectValue(self.id, "usages"));
    const size = arr.length();
    const slice: [][]const u8 = &[size][]const u8;
    var index = 0;
    while (index < size) {
      const str = getStringFree(arr.get(index));
      slice = (slice ++ str);
      index += 1;
    }
  }
};

pub const CryptoKeyPair = struct {
  publicKey: CryptoKey,
  privateKey: CryptoKey,

  pub fn init (jsPtr: u32) CryptoKeyPair {
    // grab each CryptoKey
    return CryptoKeyPair{
      .publicKey = CryptoKey.init(getObjectValue(jsPtr, "publicKey")),
      .privateKey = CryptoKey.init(getObjectValue(jsPtr, "privateKey")),
    };
  }

  pub fn free (self: *const CryptoKeyPair) void {
    self.publicKey.free();
    self.privateKey.free();
  }
};

// pub const CryptoKeyAlgorithmVariant = union(enum) {
//   cryptoKeyKeyAlgorithm: CryptoKeyKeyAlgorithm,
//   cryptoKeyAesKeyAlgorithm: CryptoKeyAesKeyAlgorithm,
//   cryptoKeyHmacKeyAlgorithm: CryptoKeyHmacKeyAlgorithm,
//   cryptoKeyRsaKeyAlgorithm: CryptoKeyRsaKeyAlgorithm,
//   cryptoKeyEllipticKeyAlgorithm: CryptoKeyEllipticKeyAlgorithm,
//   cryptoKeyVoprfKeyAlgorithm: CryptoKeyVoprfKeyAlgorithm,
//   cryptoKeyOprfKeyAlgorithm: CryptoKeyOprfKeyAlgorithm,

//   pub fn init (jsPtr: u32) CryptoKeyAlgorithmVariant {
//     // get the "name" property

//     // depending upon the name, build the appropriate algo.
//   }
// };

// interface CryptoKeyAesKeyAlgorithm {
//   name: string;
//   length: number;
// }

// interface CryptoKeyHmacKeyAlgorithm {
//   name: string;
//   hash: CryptoKeyKeyAlgorithm;
//   length: number;
// }

// interface CryptoKeyRsaKeyAlgorithm {
//   name: string;
//   modulusLength: number;
//   publicExponent: ArrayBuffer;
//   hash?: CryptoKeyKeyAlgorithm;
// }

// interface CryptoKeyEllipticKeyAlgorithm {
//   name: string;
//   namedCurve: string;
// }

// interface CryptoKeyVoprfKeyAlgorithm {
//   name: string;
//   hash: CryptoKeyKeyAlgorithm;
//   namedCurve: string;
// }

// interface CryptoKeyOprfKeyAlgorithm {
//   name: string;
//   namedCurve: string;
// }
