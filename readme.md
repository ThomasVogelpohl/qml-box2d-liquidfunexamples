
## Premade Qt project to quickly test qml-box2d together with Googles LiquidFun on desktop and mobile

### Overview:
This project is intended to allow you to quickly try out the examples provided by the qml-box plugin together with Googles LiquidFun without installing the lib and without using qmlscene.
Instead, qml-box2d gets compiled as a static plugin, so that the qml-box2d-examples can also be tested on Apple iPad and Android tablets without hassle.

The project is similar to the project:
https://github.com/ThomasVogelpohl/qml-box2d-examples
only this project also incorporates Googles LiquidFun C++ libary.
The qml-box2d code has been adapted to support LiquidFun.
You can check out the example 'Wavemachine'.

### Warning:
Both Box2D sources and qml-box2d sources have been changed during the merge of the LiquidFun libary. Also qml-box2d plugin needs new code to display the LiquidFun particles. So this software is work in progress and not production ready !!!<br>
The code should be used as fast way of testing further LiquidFun integrations.

### LiquidFun libary:
LiquidFun is an extension of Box2D. It adds a particle based fluid and soft body simulation to the rigid body functionality of Box2D.<br>
http://google.github.io/liquidfun/

### Caveats:
* The iPads Retina display does still use 1024x768 pixels and therefore the examples are full screen. Android tablets address the full resolution and therefore the examples are currently shown half size on android tablets.
* Included the qml-box2d in this repo instead of just adding the qml-box2d repo as submodule. Reason: As the plugin/plugin has been linked statically, to avoid collision with existing qml-box2d libaries on your system, the static version has been called Box2DStatic. Therefore I changed the includes  to pull in Box2DStatic.
* The qml-box2d and Box2D code are not changed, but I changed the examples to be better displayed on 1024x768 iPad screen.

### The qml-box2d plugin:
qml-box2d is a full-featured Qt plugin allowing access to the powerful C++ Box2D physics libary from Qt-QML. Use simple QML commands to create Box2D bodies, joints, sensors etc.
The qml-box2d plugin is very user friendly, just try it out !

Find the qml-box2d plugin here:
https://github.com/qml-box2d/qml-box2d

### Build the project:
Just load the qml-box2d-example.pro file into QtCreator and compile for desktop, iOS or Android.
start the examples with clicking RUN in QtCreator.

### iPad screenshots:
![Output sample](./screenshots/LiquidFunElasticParticle.gif)
<img src="./screenshots/IMG_0739.PNG" width="800" height="600">
<img src="./screenshots/IMG_0645.PNG" width="800" height="600">
<img src="./screenshots/IMG_0647.PNG" width="800" height="600">
<img src="./screenshots/IMG_0648.PNG" width="800" height="600">
<img src="./screenshots/IMG_0653.PNG" width="800" height="600">
<img src="./screenshots/IMG_0656.PNG" width="800" height="600">
<img src="./screenshots/IMG_0657.PNG" width="800" height="600">
<img src="./screenshots/IMG_0658.PNG" width="800" height="600">
<img src="./screenshots/IMG_0661.PNG" width="800" height="600">
<img src="./screenshots/IMG_0666.PNG" width="800" height="600">
<img src="./screenshots/IMG_0669.PNG" width="800" height="600">
<img src="./screenshots/IMG_0675.PNG" width="800" height="600">