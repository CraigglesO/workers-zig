const jsFree = @import("common.zig").jsFree;

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1758
pub const URL = struct {
  id: u32,

  pub fn init (ptr: u32) URL {
    return URL{ .id = ptr };
  }

  pub fn free (self: *const URL) void {
    jsFree(self.id);
  }
};

// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1776
pub const URLPattern = struct {
  id: u32,

  pub fn init (ptr: u32) URLPattern {
    return URLPattern{ .id = ptr };
  }

  pub fn free (self: *const URLPattern) void {
    jsFree(self.id);
  }
};


// https://github.com/cloudflare/workers-types/blob/master/index.d.ts#L1822
pub const URLSearchParams = struct {
  id: u32,

  pub fn init (ptr: u32) URLSearchParams {
    return URLSearchParams{ .id = ptr };
  }

  pub fn free (self: *const URLSearchParams) void {
    jsFree(self.id);
  }
};
