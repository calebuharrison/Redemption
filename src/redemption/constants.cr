module Redemption
  TYPE_HASH = {
    Float32 => f32,
    Float64 => f64,
    Int8    => i8,
    Int16   => i16,
    Int32   => i32,
    Int64   => i64,
    UInt8   => u8,
    UInt16  => u16,
    UInt32  => u32,
    UInt64  => u64
  }
  UNSIGNED_TYPE_ARRAY = [UInt8, UInt16, UInt32, UInt64]
  DIM_ARRAY = [2, 3, 4]
  SWIZZLE_ARRAY = [ [x, y, z, w], [r, g, b, a], [s, t, p, q] ]
  OPERATORS = [:+, :-, :*, :/]
  ORTH_ARGS = [left, right, bottom, top, near, far]
end