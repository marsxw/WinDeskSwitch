import os
from pynput import keyboard
import time

# Define key combinations, e.g., Ctrl + Alt + A, Ctrl + Alt + S, Ctrl + Alt + Z
COMBINATIONS = {
    frozenset([keyboard.Key.ctrl, keyboard.Key.alt, keyboard.KeyCode(char='a')]): "SWITCH_DESKTOP_A",
    frozenset([keyboard.Key.ctrl, keyboard.Key.alt, keyboard.KeyCode(char='s')]): "SWITCH_DESKTOP_S",
    frozenset([keyboard.Key.ctrl, keyboard.Key.alt, keyboard.KeyCode(char='z')]): "SWITCH_DESKTOP_Z"
}
current_keys = set()
triggered = False  # Prevents repeated triggering


def on_press(key):
    global triggered
    current_keys.add(key)
    for combination, command in COMBINATIONS.items():
        if combination.issubset(current_keys) and not triggered:
            # Write a different command to the shared file based on the key combination
            with open("/home/vm/Desktop-win11/switch_command.txt", "w") as f:
                f.write(command)
            triggered = True  # Set the flag to prevent repeated triggers
            break


def on_release(key):
    global triggered
    if key in current_keys:
        current_keys.remove(key)
    # Reset the flag if no keys are held down
    if not current_keys:
        triggered = False


with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
    listener.join()
