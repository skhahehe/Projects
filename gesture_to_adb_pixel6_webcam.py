import cv2
import mediapipe as mp
import os

# Use laptop's webcam
cap = cv2.VideoCapture(0)

# Gesture recognition setup
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1)
mp_draw = mp.solutions.drawing_utils

# Corrected ADB tap coordinates for Pixel 6 (landscape)
GAS_X, GAS_Y = 2100, 950
BRAKE_X, BRAKE_Y = 300, 950

def press_gas():
    os.system(f"adb shell input swipe {GAS_X} {GAS_Y} {GAS_X} {GAS_Y} 500")

def press_brake():
    os.system(f"adb shell input swipe {BRAKE_X} {BRAKE_Y} {BRAKE_X} {BRAKE_Y} 500")

def is_palm_open(landmarks):
    fingers = []
    fingers.append(landmarks[4].x < landmarks[3].x)  # Check thumb
    for tip in [8, 12, 16, 20]:
        fingers.append(landmarks[tip].y < landmarks[tip - 2].y)  # Check other fingers
    return fingers.count(True) >= 4

# Function to add text with a white background and black outline at the top center
def add_text_with_background(frame, text, font_scale=1.5, color=(0, 255, 0), thickness=3):
    # Get the frame dimensions
    height, width, _ = frame.shape

    # Calculate text size and position for top center alignment
    (w, h), _ = cv2.getTextSize(text, cv2.FONT_HERSHEY_SIMPLEX, font_scale, thickness)
    position = ((width - w) // 2, 50)  # Position at the top center

    # White background rectangle with some padding for the text
    rect_position = (position[0] - 10, position[1] - 10)
    cv2.rectangle(frame, rect_position, (position[0] + w + 10, position[1] + h + 10), (255, 255, 255), -1)

    # Adding black outline for text (first draw in black)
    cv2.putText(frame, text, (position[0] - 2, position[1] - 2), cv2.FONT_HERSHEY_SIMPLEX, font_scale, (0, 0, 0), thickness + 2, cv2.LINE_AA)

    # Now add the actual text in the desired color
    cv2.putText(frame, text, position, cv2.FONT_HERSHEY_SIMPLEX, font_scale, color, thickness, cv2.LINE_AA)

while cap.isOpened():
    success, frame = cap.read()
    if not success:
        continue

    # Convert frame to RGB for MediaPipe processing
    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(frame_rgb)

    # Add text dialog for Brake or Gas
    action_text = ""
    text_color = (0, 255, 0)  # Default to green for Gas

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)
            landmarks = hand_landmarks.landmark

            if is_palm_open(landmarks):
                press_gas()  # Continuously press gas as long as the palm is open
                action_text = "Gas Pressed"
            else:
                press_brake()  # Continuously press brake as long as the palm is closed
                action_text = "Brake Pressed"
                text_color = (0, 0, 255)  # Change text color to red for Brake

    # Add the action text with improved visuals
    add_text_with_background(frame, action_text, font_scale=1.5, color=text_color, thickness=3)

    # Display the frame with the action text
    cv2.imshow("Gesture Control", frame)

    # Break loop on 'Esc' key press
    if cv2.waitKey(1) & 0xFF == 27:
        break

cap.release()
cv2.destroyAllWindows()
