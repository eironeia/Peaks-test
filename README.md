# Peaks-test

## Test description

Build a simple app with a single screen where the user can drag two rectangles.
If the two rectangles overlap the app will calculate the overlapping area and display it in a label.

The first time that the app is open, you have to get the initial position and size of the rectangles from an API.
For simplicity you can mock this API with the following response:

```JSON
{
 "rectangles": [
 	{
 		"x": 0.5,
 		"y": 0.5,
 		"size": 0.2
 	},
 	{
 		"x": 0.7,
 		"y": 0.7,
 		"size": 0.2
 	}
 ]
}

```

**rectangles:** list of rectangles (for simplicity you will always receive two, no need to do it generic).

**x and y:** position of the rectangle relative to the screen. E.g. x:0.5, y:0.5 means a rectangle in the center of the screen.

**size:** the size of the rectangle in percentage relative to the screen. E.g. size:0.1 means a width of 10% of the width of the screen and a height of 10% of the height of the screen.

Every time the user finishes dragging a rectangle, you have to save locally the last position of the rectangle. If you close the app, the next time you open it you have to display the rectangles in their last positions but you still have to get the sizes from the API as they may change.

**We are going to evaluate:**
* Code quality
* Architecture
* Testing

The code has to be submitted in a private repository in GitHub, GitLab or Bitbucket. Grant access to the repository to david.miguel@peaks.com and adrian.ortuzar@peaks.com. 


## Implementation details

Due to limitation of time test has not been added. 
Nonetheless, every component is abstracted and using dependency inversion in order to be fully testable.

How I would do the tests and implementations details can be discussed during the post-code interview.

As discussed on the first interview, to show the potential of RxSwift, I have decided to use the framework to show how does it work.
I am not sure if it's the best approach, but you can see its potential.

About storing lcoally, I didn't want to overkill the app, due to limitation of time, so I chosen the option of UserDefaults.

![](https://media.giphy.com/media/YoPJykBQ3pXbbUR57A/giphy.gif)
