#ifndef __PLANE_INCLUDE__
#define __PLANE_INCLUDE__
    struct Capsule
    {
        float3 direction;
        float3 position;
        float radius;
    };
    struct Cone
    {
        float3 vertex;
        float height;
        float3 direction;
        float radius;
    };
inline float4 GetPlane(float3 normal, float3 inPoint)
{
    return float4(normal, -dot(normal, inPoint));
}
inline float4 GetPlane(float3 a, float3 b, float3 c)
{
    float3 normal = normalize(cross(b - a, c - a));
    return float4(normal, -dot(normal, a));
}

inline float4 GetPlane(float4 a, float4 b, float4 c)
{
    a /= a.w;
    b /= b.w;
    c /= c.w;
    float3 normal = normalize(cross(b.xyz - a.xyz, c.xyz - a.xyz));
    return float4(normal, -dot(normal, a.xyz));
}

inline float GetDistanceToPlane(float4 plane, float3 inPoint)
{
    return dot(plane.xyz, inPoint) + plane.w;
}

float BoxIntersect(float3 extent, float3 position, float4 planes[6]){
    float result = 1;
    for(uint i = 0; i < 6; ++i)
    {
        float4 plane = planes[i];
        float3 absNormal = abs(plane.xyz);
        result *= ((dot(position, plane.xyz) - dot(absNormal, extent)) < -plane.w) ? 1.0 : 0.0;
    }
    return result;
}

float SphereIntersect(float4 sphere, float4 planes[2])
{
    float result = 1;
    for(uint i = 0; i < 2; ++i)
    {
        result *= (GetDistanceToPlane(planes[i], sphere.xyz) < sphere.w) ? 1.0 : 0.0;
    }
    return result;
}

float SphereIntersect(float4 sphere, float4 planes[4])
{
    float result = 1;
    for(uint i = 0; i < 4; ++i)
    {
        result *= (GetDistanceToPlane(planes[i], sphere.xyz) < sphere.w) ? 1.0 : 0.0;
    }
    return result;
}


float BoxIntersect(float3 extent, float3 position, RWTexture3D<float4> tex, uint2 uv, const uint count){
    float result = 1;
    [unroll]
    for(uint i = 0; i < count; ++i)
    {
        float4 plane = tex[uint3(uv, i)];
        float3 absNormal = abs(plane.xyz);
        result *= ((dot(position, plane.xyz) - dot(absNormal, extent)) < -plane.w) ? 1.0 : 0.0;
    }
    return result;
}

float SphereIntersect(float4 sphere, RWTexture3D<float4> tex, uint2 uv, const uint count)
{
    float result = 1;
    [unroll]
    for(uint i = 0; i < count; ++i)
    {
        result *= (GetDistanceToPlane(tex[uint3(uv, i)], sphere.xyz) < sphere.w) ? 1.0 : 0.0;
    }
    return result;
}

    inline float PointInsidePlane(float3 vertex, float4 plane)
    {
        return (dot(plane.xyz, vertex) + plane.w) < 0;
    }

    inline float SphereInsidePlane(float4 sphere, float4 plane)
    {
        return (dot(plane.xyz, sphere.xyz) + plane.w) < sphere.w;
    }

    inline float ConeInsidePlane(Cone cone, float4 plane)
    {
        float3 m = cross(cross(plane.xyz, cone.direction), cone.direction);
        float3 Q = cone.vertex + cone.direction * cone.height + normalize(m) * cone.radius;
        return PointInsidePlane(cone.vertex, plane) + PointInsidePlane(Q, plane);
    }

    inline float CapsuleInsidePlane(Capsule cap, float4 plane)
    {
        float4 sphere0 = float4(cap.position + cap.direction, cap.radius);
        float4 sphere1 = float4(cap.position - cap.direction, cap.radius);
        return SphereInsidePlane(sphere0, plane) + SphereInsidePlane(sphere1, plane);
    }

    float ConeIntersect(Cone cone, RWTexture3D<float4> tex, uint2 uv, const uint count)
{
    float result = 1;
    [unroll]
    for(uint i = 0; i < count; ++i)
    {
        result *= ConeInsidePlane(cone, tex[uint3(uv, i)]);
    }
    return result;
}


    float ConeIntersect(Cone cone, float4 planes[2])
{
    float result = 1;
    [unroll]
    for(uint i = 0; i < 2; ++i)
    {
        result *= ConeInsidePlane(cone, planes[i]);
    }
    return result;
}

#endif