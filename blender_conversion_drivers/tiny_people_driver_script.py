import os
import shutil
import bpy

allowed_extensions = ['FBX', 'tga']

ACTION_STASH_NAME = '[Action Stash]'

def main():
    print('Starting Tiny Toony People conversion driver')
    print('cwd = ' + os.getcwd())

    import_scene('models/units/TT_RTS_Character_customizable.FBX')
    import_scene('animation/TwoHanded/twohanded_03_run_rm.FBX')
    import_scene('animation/Infantry/infantry_04_attack_A.FBX')
    import_scene('animation/Spear/spear_06_death_B.FBX')

    
    append_animation_to(
        'models/units/TT_RTS_Character_customizable.blend'.lower(),
        'animation/Infantry/infantry_04_attack_A.blend'.lower()
    )

    append_animation_to(
        'models/units/TT_RTS_Character_customizable.blend'.lower(),
        'animation/TwoHanded/twohanded_03_run_rm.blend'.lower()
    )
    
    append_animation_to(
        'models/units/TT_RTS_Character_customizable.blend'.lower(),
        'animation/Spear/spear_06_death_B.blend'.lower()
    )

    export_scene('models/units/TT_RTS_Character_customizable.blend'.lower())


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

def import_scene(path):
    _flush_current_document()

    bpy.ops.import_scene.fbx(filepath = resolve_import_path(path))

    for index in range(len(bpy.data.actions)):
        _rename_action(bpy.data.actions[index], path, index)

    temp_path = (os.path.splitext(path)[0] + '.blend').lower()
    bpy.ops.wm.save_mainfile(filepath = resolve_temp_path(temp_path))

def _flush_current_document():
    bpy.ops.wm.read_homefile(app_template="")
    _remove_default_screen_objects()

def _remove_default_screen_objects():
    bpy.ops.object.select_all(action='DESELECT')

    for crap in ['Camera', 'Cube', 'Light']:
        if crap in bpy.data.objects:
            bpy.data.objects[crap].select_set(True)
    
    bpy.ops.object.delete()

def _rename_action(action, filepath, index):
    anim_name = os.path.split(os.path.splitext(filepath)[0])[1]
    
    if index > 0:
        anim_name += '_' + str(index)

    action.name = anim_name

def append_animation_to(model_path, animation_path):
    _flush_current_document()
    bpy.ops.wm.open_mainfile(filepath = resolve_temp_path(model_path))
    
    with bpy.data.libraries.load(resolve_temp_path(animation_path)) as (data_from, data_to):
        data_to.actions = data_from.actions    

    target_object = bpy.data.objects[0]

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

def export_scene(path):
    _flush_current_document()
    bpy.ops.wm.open_mainfile(filepath = resolve_temp_path(path))

    temp_path = (os.path.splitext(path)[0] + '.gltf').lower()

    bpy.ops.export_scene.gltf(export_format = 'GLTF_EMBEDDED', filepath = resolve_export_path(temp_path))


main()