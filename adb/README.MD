
#  Gesture-Controlled Hill Climb Racing (Pixel 6)

This project uses **hand gestures** via your webcam to control the **gas** and **brake** in *Hill Climb Racing* using **ADB commands**. Designed specifically for the **Google Pixel 6** in landscape orientation. 📱🏁

---

## ⚙️ Prerequisites

Make sure the following are set up before running the script:

1.  **Python 3.x**
2.  Python packages:
   - `opencv-python`
   - `mediapipe`
3.  **ADB (Android Debug Bridge)** installed and added to your system path
4.  Your **Pixel 6** connected via USB with:
   - USB Debugging enabled
   - Authorized for ADB access
5.  *Hill Climb Racing* running on your **Pixel 6** in **landscape mode**

> **Note:** This script is calibrated **only for the Pixel 6**, as the screen tap coordinates are hardcoded. It may not work correctly on other devices unless you adjust the coordinates.

---
## How It Works

-  **Open Palm** → Presses the **Gas** continuously.
-  **Closed Fist** → Presses the **Brake** continuously.
- Your webcam captures your hand, and the script sends ADB commands to simulate touch input.

---



##  How to Run

1. Clone or download this repo.
2. Install dependencies:

   ```bash
   pip install opencv-python mediapipe
   ```

3. Run the script:

   ```bash
   python gesture_control.py
   ```

4. Make sure the game is open and ready on your Pixel 6, then wave your hand and start driving!

---

##  Customization

To adapt this for other devices:

- Replace the tap coordinates in the script:

  ```python
  GAS_X, GAS_Y = your_new_x, your_new_y
  BRAKE_X, BRAKE_Y = your_new_x, your_new_y
  ```

- Use a screen touch visualizer app on your Android phone to determine the correct touch points.
 (I personally used online mic test services)

---



-
Happy driving! 
Created with ❤️ by **Sarmad Durrani**
