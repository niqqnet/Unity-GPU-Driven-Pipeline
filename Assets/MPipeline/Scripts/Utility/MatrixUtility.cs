﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Mathematics;
using System.Runtime.CompilerServices;
using static Unity.Mathematics.math;
namespace MPipeline {
    public static class MatrixUtility
    {
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static Matrix4x4 toMatrix4x4(ref this double4x4 db)
        {
            return new Matrix4x4((float4)db.c0, (float4)db.c1, (float4)db.c2, (float4)db.c3);
        }
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static double4x4 toDouble4x4(ref this Matrix4x4 db)
        {
            return new double4x4((float4)db.GetColumn(0), (float4)db.GetColumn(1), (float4)db.GetColumn(2), (float4)db.GetColumn(3));
        }
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static float4x4 GetWorldToLocal(float4x4 localToWorld)
        {
            float4x4 rotation = float4x4(float4(localToWorld.c0.xyz, 0), float4(localToWorld.c1.xyz, 0), float4(localToWorld.c2.xyz, 0), float4(0, 0, 0, 1));
            rotation = transpose(rotation);
            float3 localPos = mul(rotation, localToWorld.c3).xyz;
            localPos = -localPos;
            rotation.c3 = float4(localPos.xyz, 1);
            return rotation;
        }
    }

    public static unsafe class VectorUtility
    {
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static float4 GetPlane(float3 normal, float3 inPoint)
        {
            return new float4(normal, -dot(normal, inPoint));
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static float4 GetPlane(float3 a, float3 b, float3 c)
        {
            float3 normal = normalize(cross(b - a, c - a));
            return float4(normal, -dot(normal, a));
        }
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static float GetDistanceToPlane(float4 plane, float3 inPoint)
        {
            return dot(plane.xyz, inPoint) + plane.w;
        }

        public static bool BoxIntersect(float3x3 boxLocalToWorld, float3 position, float4* planes, int len)
        {
            for (uint i = 0; i < len; ++i)
            {
                float4 plane = planes[i];
                float3 absNormal = abs(mul(plane.xyz, boxLocalToWorld));
                if ((dot(position, plane.xyz) - dot(absNormal, float3(0.5f, 0.5f, 0.5f))) > -plane.w) return false;
            }
            return true;
        }
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static bool PointInsidePlane(float3 vertex, float4 plane)
        {
            return (dot(plane.xyz, vertex) + plane.w) < 0;
        }
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static bool ConeIntersect(Cone cone, float4 plane)
        {
            float3 m = cross(cross(plane.xyz, cone.direction), cone.direction);
            float3 Q = cone.vertex + cone.direction * cone.height + normalize(m) * cone.radius;
            return PointInsidePlane(cone.vertex, plane) || PointInsidePlane(Q, plane);
        }
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static bool SphereIntersect(float4 sphere, float4 plane)
        {
            return (GetDistanceToPlane(plane, sphere.xyz) < sphere.w);
        }
    }
}