#!/usr/bin/env python3
"""
Конвертация GLB → OBJ через Blender Python API
"""
import bpy
import sys
import os

# Очистка сцены
bpy.ops.wm.read_factory_settings(use_empty=True)

# Путь к GLB файлу
glb_path = sys.argv[-2]
obj_path = sys.argv[-1]

print(f"Конвертация: {glb_path} → {obj_path}")

# Импорт GLB
bpy.ops.import_scene.gltf(filepath=glb_path)

# Экспорт в OBJ
bpy.ops.wm.obj_export(
    filepath=obj_path,
    export_selected_objects=False,
    export_materials=True,
    export_triangulated_mesh=True
)

print(f"✅ Готово: {obj_path}")
