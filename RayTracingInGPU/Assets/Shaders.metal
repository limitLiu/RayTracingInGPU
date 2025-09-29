#include <metal_stdlib>

#define let const auto
#define var auto

using namespace metal;

using vec2f = float2;
using vec3f = float3;
using vec4f = float4;

using u8 = uchar;
using i8 = char;
using u16 = ushort;
using i16 = short;
using i32 = int;
using u32 = uint;
using f16 = half;
using f32 = float;
using usize = size_t;

struct VertexIn {
  vec2f position;
};

struct Vertex {
  vec4f position [[position]];
};

struct Uniforms {
  u32 width;
  u32 height;
};

struct Ray {
  vec3f origin;
  vec3f direction;
};

struct Sphere {
  vec3f center;
  f32 radius;
};

f32 intersect_sphere(const Ray ray, const Sphere sphere) {
  let v = ray.origin - sphere.center;
  let a = dot(ray.direction, ray.direction);
  let b = dot(v, ray.direction);
  let c = dot(v, v) - sphere.radius * sphere.radius;
  let d = b * b - a * c;
  if (d < 0.) {
    return -1.;
  }
  let sqrt_d = sqrt(d);
  let recip_a = 1. / a;
  let mb = -b;
  let t = (mb - sqrt_d) * recip_a;
  if (t > 0.) {
    return t;
  }
  return (mb + sqrt_d) * recip_a;
}

vec3f sky_color(Ray ray) {
  let a = 0.5 * (normalize(ray.direction).y + 1);
  return (1 - a) * vec3f(1) + a * vec3f(0.5, 0.7, 1);
}

vertex Vertex vertexFn(constant VertexIn *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
  return Vertex { vec4f(vertices[vid].position, 0, 1) };
}

fragment vec4f fragmentFn(Vertex in [[stage_in]], constant Uniforms &uniforms [[buffer(1)]]) {
  let origin = vec3f(0);
  let focus_distance = 1.0;
  let aspect_ratio = f32(uniforms.width) / f32(uniforms.height);
  var uv = in.position.xy / vec2f(f32(uniforms.width - 1), f32(uniforms.height - 1));
  uv = (2 * uv - vec2f(1)) * vec2f(aspect_ratio, -1);
  let direction = vec3f(uv, -focus_distance);
  let ray = Ray { origin, direction };
  let sphere = Sphere { .center = vec3f(0, 0, -1), .radius = 0.5 };
  if (intersect_sphere(ray, sphere) > 0) {
    return vec4f(1, 0.76, 0.03, 1);
  }
  return vec4f(sky_color(ray), 1);
}
