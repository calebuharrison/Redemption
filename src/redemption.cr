require "./redemption/**"

module Redemption
  angle = 90_f32 * (Math::PI / 180_f32)
  m1 = Matrix4x4f32.scaling(Vector3f32.new(0.5, 0.5, 0.5))
  m2 = Matrix4x4f32.rotation(angle, Vector3f32.new(0, 0, 1))
  puts m1
  puts m2
  puts m1 * m2
  puts m2 * m1
end
