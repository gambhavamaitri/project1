# project1
** convert any screen to touch screen**

The goal is to convert any standard display into a touch screen by integrating an IR or capacitive touch sensor. The system will process touch inputs and display them as visual interactions on the screen.


BLOCK DIAGRAM:-
+--------------------+
       |  Touch Sensor (IR) |
       +---------|----------+
                 |
                 | (Sensor Data)
                 |
       +---------v----------+
       |   Sensor Interface  |
       +---------|----------+
                 |
                 | (Raw Coordinates)
                 |
       +---------v----------+
       |   Coordinate Mapper |
       +---------|----------+
                 |
                 | (Mapped (x,y))
                 |
       +---------v----------+
       |  Gesture Recognition|
       +---------|----------+
                 |
                 | (Touch Events)
                 |
       +---------v----------+
       |  Display Controller |
       +---------|----------+
                 |
                 | (VGA/HDMI)
                 |
       +---------v----------+
       |      Display        |
       +---------------------+
