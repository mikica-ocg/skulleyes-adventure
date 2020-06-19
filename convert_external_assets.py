from pathlib import Path
import shutil
import sys
import subprocess

EXTERNAL_DIR = './external_assets'
CONVERTED_DIR = './converted_assets'
TEMP_DIR = './temp_assets'

BLENDER_DRIVER_SCRIPTS_DIR = './blender_conversion_drivers'

DEFAULT_BLENDER_PATH = '/Applications/Blender.app/Contents/MacOS/Blender'

def main():
    print('Starting conversion')
    print('cwd: ' + str(Path.cwd()))
    
    print('Clearing old converted assets')
    clear_converted_assets()

    print('Clearing temp assets')
    clear_temp_assets()

    print('Using Blener path: ' + get_blender_path())

    for script_path in get_blender_driver_scripts():
        run_blender_driver(DEFAULT_BLENDER_PATH, str(script_path))

    print("Done, clearing temp assets")
    clear_temp_assets()
    
    pass

def clear_converted_assets():
    p = Path(CONVERTED_DIR)
    
    if p.exists():
        shutil.rmtree(p)

    p.mkdir()

def clear_temp_assets():
    p = Path(TEMP_DIR)

    if p.exists():
        shutil.rmtree(p)

    p.mkdir()

    with open(Path.joinpath(p, '.gdignore'), 'wb') as temp:
        pass
    
def get_blender_path():
    if len(sys.argv) < 2:
        return DEFAULT_BLENDER_PATH
    
    return sys.argv[1]

def get_blender_driver_scripts():
    return Path(BLENDER_DRIVER_SCRIPTS_DIR).glob('**/*.py')

def run_blender_driver(blender_path, script_name):
    subprocess.check_call([blender_path + ' --background --python ' + script_name], shell=True)
    pass

main()
