# Ball-E Game
 Created by AntoineC in 2018-02-04 
 https://www.shadertoy.com/user/AntoineC/

 shader original
 https://www.shadertoy.com/view/llBfRK

Try to match the top/left pattern using paint and masks! The game has 25 levels. Use the X ball to restart a level. Read tutorial at the top of Image code. Updated to 1.05!

Current limitations:
 - No win screen (game restart)!
 - Level number not show

 / ----------------------------------------------------------------------------------------
//	"Ball-E Game" by Antoine Clappier - Feb 2018
//
//	Licensed under:
//  A Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
//	http://creativecommons.org/licenses/by-nc-sa/4.0/
// ----------------------------------------------------------------------------------------

// Game mechanics inspired by "Factory Ball" by Bart Bonte. 

// Tutorial:

// Level 1:
//   - Use "eyes" mask    (click top/right sphere)
//   - Paint in blue      (click blue ball)
//   - Remove "eyes" mask (click again top/right sphere)
//   - Done!

// Level 2:
//   - Paint in black    (click black ball)
//   - Use "pupils" mask (click middle/right sphere)
//   - Paint in white
//   - Remove "pupils" mask
//   - Add eyes mask
//   - ...