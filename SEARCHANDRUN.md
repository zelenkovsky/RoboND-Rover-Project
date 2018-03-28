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

Global map of navigatable terrain is masked by global map of obstacals. Meaning the places which are marked as navigatable and as obstacale at the same time are considered as obstacals.

Rocks are detected the same way as navigatable terrain, except before after warp transformation thresholding is done to separate "yellow" rock color from the rest of the image. It is done in function ```find_rocks```.

