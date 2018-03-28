# Search & Sample Return Project

Project was completed in the basic form, existing algorithm does mapping with approximately 60% accuracy. 

## Supporting Materials

- Jupyter Notebook: [Rover_Lab_Notebook.ipynb](code/Rover_Lab_Notebook.ipynb)
- Output video: [test_mapping.mp4](output/test_mapping.mp4)
- Autonomous navigation scripts
    - [drive_rover.py](code/drive_rover.py)
    - [decision.py](code/decision.py)
    - [perception.py](code/perception.py)
    - [supporting_functions.py](code/supporting_functions.py)
- writeup report (this file)

## How to setup environment

In order to simplify environment setup I had to prepared a ```Dockerfile``` and ```docker-compose.yml``` files.

Use following commands to build docker image:

```
$ docker-compose build
```

Run following command to start:

```
$ docker-compose run robond
# python drive_rover.py 
```

## Notebook Analysis

There are several things had to be changed in Jupyter Notebook in order to complete the example. First I tried to implement my own approach, but due to lack of experience with OpenCV library API and time constraints decided to follow common approach explained in the video.

### Changes in Perspective Transformation

In order to identify valid pixels of the area after warp perspective transformation we change return values of ```perspect_transform``` function and return ```mask``` together with ```warp``` image result.

Mask will be used to exclude areas of the image which happen to be visible after warp transformation due to difference in boundaries, but has no valid information.

### Changes in Processing Image

Function ```process_image``` has been modified to build world map using previously defined transformations.

World map uses 2 out of 3 channels to mark navigable terrain(blue), obstacles(red) and rocks are marked as white (255,255,255).

In order to create map of navigable terrain ```process_image``` first does following:

1) Perspective warp transformation,
2) Then does thresholding to leave only bright road areas.
3) Then does transformation to local rover coordinates.
3) Then does transformation from local rover coordinates to global map coordinates.

In order to create map of obstacles ```process_image``` is doing very similar things:

1) Use the result of the same perspective warp transformation,
2) But uses the part which did not pass threshold.
3) Applies the mask before converting to local rover coordinates.
4) Then does transformation to local rover coordinates.
5) Then does transformation from local rover coordinates to global map coordinates.

Global map of navigatable terrain is masked by global map of obstacles. Meaning the places which are marked as navigatable and as obstacles at the same time are considered as obstacles.

Rocks are detected the same way as navigatable terrain, except before after warp transformation thresholding is done to separate "yellow" rock color from the rest of the image. It is done in function ```find_rocks```.

All 3 global maps are merged together, first navigatable terrain, then obstacles then rocks, one on top of another.

### Video example

Video output has been saved in [output/test_mapping.mp4](output/test_mapping.mp4) file.


## Autonomous Navigation and Mapping

Following files were updated to make rover moves autonomously [percetion.py](code/perception.py) and [decision.py](code/decision.py).

### Changes related to perception

Similar image transformations were done as in __Jupyter__ notebook. Function ```perception_step()``` was updated to apply perspective transformation first, then color thresholding to detect navigable terrain, obstacles were detected using inverse thresholding with the mask to eliminate falsely detected navigable terrain.

After overlaying navigable terrain and obstacles, image has been converted to local rover coordinates and represented in polar coordinates. Polar coordinates allows us to operate in terms of ```rays``` of clear path. List of ```ray``` angles with distances are saved to ```Rover.nav_angles``` and ```Rover.nav_dists``` accordingly to make future decisions about Rover steering wheel angle.

### Changes related to decision making

There were no special changes necessary in ```decision_step()```, since it was already doing quite well in controlling the __Rover__.  At each moment ```decision_step()``` function analyzes whether ```Rover.nav_angles``` is defined or not.

If angles are present, then depending on the current __Rover__'s state decision is made:

* ```forward``` state means that ```Rover.nav_angles``` should be used to move forward when there is enough navigable terrain in front of the __Rover__.
  - If there is enough space, calculating a mean of all angles and assume that is a steering angle for current step. Increasing velocity till allowed maximum value.
  - In cases when there is not enough navigable terrain, __Rover__ changes a state to ```stop```, sets throttle to zero and apply breaks.

* ```stop``` state means that __Rover__ will keep applying breaks till velocity drops to enough low number (in our case less than 0.2)
  - After velocity became low, __Rover__ will start rotating with using -15 degree steering angle. Till ```Rover.nav_angles``` will meet the criteria for moving forward.
  - When ```Rover.nav_angles``` are high enough, rover will switch state back to ```forward```.

  This simple behavior allows __Rover__ to navigate across the map. In my experience it stuck only a couple of times between rocks when obstacle was not visible to the camera.

  __Rover__ was able to navigate more then 40% of the map with fidelity around 68%


### Pickup and Return challenge

I tried to modify ```perception_step()``` function and change state of the rover to ```chasing``` when rocks are detect. In this case ```Rover.nav_angles``` represented angles of the detected rock.

In ```chasing``` state ```decision_step()``` was using similar approach for selecting steering wheel angle as in ```forward```, but switched to ```stop``` state when ```Rover.nav_dists``` became less then threshold. I tried to invoke ```Rover.send_pickup()``` but that was not always reliable. Meaning that sometimes rover was not properly positioned to pickup the sample.


## Results

Please review video created by __Jupytor__ notebook in the [output](output/) folder, it should demonstrate how world map is created.

Please build and run docker container to verify that __Rover__ is able to update required percentage of the map with accuracy higher then 60%.

Pickup and Return challenge was not completed and I'll most probably complete that work later.


