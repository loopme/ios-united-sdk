# Build Instruction

`pod install`
`./build.sh`

if fuild failed, then:
open ISLoopMeCustomAdapter.xcworkspace
Select ISLoopMeCustomAdapter target
Select 'General'
Select 'Pods_ISLoopMeCustomAdapter.framework' and remove it
Repeat `./build.sh` 