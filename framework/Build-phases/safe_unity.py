import os
from rename_unity import *

if os.environ['UNITY_BUILD'] == 'YES':
	rename_unity_unsafe_files()	