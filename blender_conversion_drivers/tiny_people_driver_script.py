import os
import sys
import shutil
import bpy

allowed_extensions = ['FBX', 'tga']

ACTION_STASH_NAME = '[Action Stash]'

ERRORS = []

def main():
    print('Starting Toony Tiny People conversion driver')
    print('cwd = ' + os.getcwd())

    units_model = import_scene('models/units/TT_RTS_Character_customizable.FBX')
    cavalry_model = import_scene('models/units/TT_RTS_Cavalry_customizable.FBX')

    models = import_directory('models')
    models = [elem for elem in models if elem != units_model and elem != cavalry_model]

    fx = import_directory('fx')

    cavalry_animations = import_directory('animation_cavalry')

    units_animations = import_directory('animation')

    append_animations_to(units_model, units_animations)
    append_animations_to(cavalry_model, cavalry_animations)

    export_scene(units_model)
    export_scenes(models)
    export_scene(cavalry_model)

    copy_assets(files_in_directory_with_extension(".tga", "", resolve_import_path("")))

    print('ERRORS: ' + str(len(ERRORS)))

    for err in ERRORS:
        print(str(err[0]) + ': ' + str(err[1]))

def files_in_directory_with_extension(extension, directory, base):
    paths = []

    for root, dirs, files in os.walk(os.path.join(base, directory)):
        for file in files:
            if file.endswith(extension):
                paths.append(os.path.join(root, file))

    if len(base) > 0:
        for index in range(len(paths)):
            p = paths[index]
            
            if p.startswith(base):
                paths[index] = p[len(base) : len(p)]

    return paths

def import_directory(directory):
    return import_scenes(
        files_in_directory_with_extension('.FBX', directory, resolve_import_path(""))
    )

def import_scenes(paths):
    result = []

    for p in paths:
        import_path = import_scene(p)

        if import_path != None:
            result.append(import_path)

        try:
            result.append(import_scene(p))
        except Exception as e:
            ERRORS.append((p, e))

    return result

def import_scene(path):
    try:
        return _do_import_scene(path)
    except Exception as e:
        ERRORS.append((path, e))

    return None

def _do_import_scene(path):
    _flush_current_document()

    bpy.ops.import_scene.fbx(filepath = resolve_import_path(path))

    for index in range(len(bpy.data.actions)):
        _rename_action(bpy.data.actions[index], path, index)

    temp_path = (os.path.splitext(path)[0] + '.blend').lower()

    bpy.ops.wm.save_mainfile(filepath = resolve_temp_path(temp_path))

    return temp_path

def _rename_action(action, filepath, index):
    anim_name = os.path.split(os.path.splitext(filepath)[0])[1]
    
    if index > 0:
        anim_name += '_' + str(index)

    action.name = anim_name

def append_animation_to(model_path, animation_path):
    append_animations_to(model_path, [animation_path])

def append_animations_to(model_path, animation_paths):
    if model_path == None:
        ERRORS.append((model_path, "Model Path is None"))
        return

    _flush_current_document()
    bpy.ops.wm.open_mainfile(filepath = resolve_temp_path(model_path))

    target_object = bpy.data.objects[0]

    for animation_path in animation_paths:
        if animation_paths == None:
            ERRORS.append((animation_path, "Animation Path is None"))
            continue

        with bpy.data.libraries.load(resolve_temp_path(animation_path)) as (data_from, data_to):
            data_to.actions = data_from.actions    

        for action in data_to.actions:
            _add_action_to_stash_on(target_object, action)
    
    bpy.ops.wm.save_mainfile(filepath = resolve_temp_path(model_path))

def _add_action_to_stash_on(target_object, action):
    stash = _create_action_stash(target_object)
    stash.strips.new(name = action.name, start = 0, action = action)

def _create_action_stash(target_object):
    if not target_object.animation_data:
        target_object.animation_data_create()

    stashes_count = 0

    for track in target_object.animation_data.nla_tracks:
        if track.name.startswith(ACTION_STASH_NAME):
            stashes_count += 1

    stash_name = ACTION_STASH_NAME

    if stashes_count > 0:
        stash_name += '.' + format(stashes_count, '03d')
    
    stash = target_object.animation_data.nla_tracks.new(prev = None)
    stash.name = stash_name
    stash.mute = True
    stash.lock = True

    return stash

def export_scenes(paths):
    result = []

    for p in paths:
        export_path = export_scene(p)
        
        if export_path != None:
            result.append(export_path)

    return result

def export_scene(path):
    try:
        return _do_export_scene(path)
    except Exception as e:
        ERRORS.append((path, e))

    return None

def _do_export_scene(path):
    _flush_current_document()
    bpy.ops.wm.open_mainfile(filepath = resolve_temp_path(path))

    temp_path = (os.path.splitext(path)[0] + '.gltf').lower()

    bpy.ops.export_scene.gltf(export_format = 'GLTF_EMBEDDED', filepath = resolve_export_path(temp_path))

    return temp_path

def resolve_import_path(path):
    return 'external_assets/ToonyTinyPeople/TT_RTS/TT_RTS_Standard/' + path

def resolve_temp_path(path):
    return _create_dirs_decorator('temp_assets/' + path)

def resolve_export_path(path):
    return _create_dirs_decorator('converted_assets/tt_rts/' + path)

def _create_dirs_decorator(path):
    directory = os.path.dirname(path)

    if not os.path.exists(directory):
        os.makedirs(directory)
    
    return path

def _flush_current_document():
    bpy.ops.wm.read_homefile(app_template="")
    _remove_default_screen_objects()

def _remove_default_screen_objects():
    bpy.ops.object.select_all(action='DESELECT')

    for crap in ['Camera', 'Cube', 'Light']:
        if crap in bpy.data.objects:
            bpy.data.objects[crap].select_set(True)
    
    bpy.ops.object.delete()

def copy_assets(assets):
    for asset in assets:
        copy_asset(asset)

def copy_asset(asset):
    import_path = resolve_import_path(asset)
    export_path = resolve_export_path(asset)

    print("Copying " + asset)

    try:
        shutil.copyfile(import_path, export_path)
    except Exception as e:
        ERRORS.append((asset, e))

main()