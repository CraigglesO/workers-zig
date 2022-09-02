# Schedule

[Learn more via the developer docs](https://developers.cloudflare.com/workers/runtime-apis/scheduled-event/)

## **Example**:

## ZIG

```zig
// NOTE:
// https://github.com/ziglang/zig/issues/3160
// until @asyncCall WASM support is implemented we use a double-up function
export fn scheduledEvent (ctxID: u32) void {
  // build the fetchContext
  const ctx = ScheduledContext.init(ctxID) catch {
    String.new("Unable to prepare a ScheduledContext.").throw();
    return;
  };
  // Build the async frame:
  const frame = allocator.create(@Frame(scheduledHandler)) catch {
      ctx.throw("Unable to prepare a frame.");
      return undefined;
  };
  frame.* = async scheduledHandler(ctx);
  // tell the context about the frame for later destruction
  ctx.frame.* = frame;
}

pub fn scheduledHandler (ctx: *ScheduledContext) callconv(.Async) void {
  // get the kvinstance from env
  const kvNamespace = ctx.env.kv("TEST_NAMESPACE") orelse {
    ctx.throw("Could not find \"TEST_NAMESPACE\"");
    return;
  };
  defer kvNamespace.free();

  // prep an object to store
  const obj = Object.new();
  defer obj.free();

  // get ctx cron string
  const cron = ctx.event.cron();
  defer allocator.free(cron);
  obj.setText("cron", cron);

  // get scheduled time
  const scheduledTime = ctx.event.scheduledTime();
  obj.setNum("scheduledTime", u64, scheduledTime);

  // store obj in kv
  kvNamespace.put("obj", .{ .object = &obj }, .{});

  ctx.resolve();
}
```

## JS / TS

```ts
import { zigSchedule } from '../src/index'

export default {
  scheduled: zigSchedule
}
```
