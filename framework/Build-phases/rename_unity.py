import os

extensions=('.js')
extensionWrap = '.unity_ignore'
resourcesDir = os.environ['TARGET_BUILD_DIR']

def rename_unity_unsafe_files():
    for root, dirs, files in os.walk(resourcesDir):
        for file in files:
            if file.lower().endswith(extensions):
                 filePath = os.path.join(root, file)
                 pre, ext = os.path.splitext(file)
                 os.rename(filePath, filePath + extensionWrap)