#!/usr/bin/env python3
import tkinter as tk
from PIL import Image, ImageTk, ImageSequence
import sys
import os

def show_image_overlay():
    image_path = "asset/lock.gif"
    root = tk.Tk()
    root.withdraw()
    root.overrideredirect(True)

    try:
        pil_image = Image.open(image_path)
    except Exception as e:
        print(f"Error loading image: {e}")
        sys.exit(1)

    frames = []
    duration = 100
    is_animated = getattr(pil_image, 'is_animated', False)

    if is_animated:
        duration = pil_image.info.get('duration', 100)
        for frame in ImageSequence.Iterator(pil_image):
            frames.append(ImageTk.PhotoImage(frame.convert("RGBA")))
    else:
        frames.append(ImageTk.PhotoImage(pil_image.convert("RGBA")))

    first_frame = frames[0]
    w = first_frame.width()
    h = first_frame.height()
    
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    x = (screen_width // 2) - (w // 2)
    y = (screen_height // 2) - (h // 2)
    root.geometry(f"{w}x{h}+{x}+{y}")

    label = tk.Label(root, borderwidth=0, highlightthickness=0)
    label.pack()

    def update_frame(ind):
        frame = frames[ind]
        label.configure(image=frame)
        if len(frames) > 1:
            ind += 1
            if ind == len(frames):
                ind = 0
            # Schedule the next update
            root.after(duration, update_frame, ind)

    # Start the loop
    update_frame(0)

    # 5. Bindings to Close
    root.bind("<Escape>", lambda e: root.destroy())
    label.bind("<Button-1>", lambda e: root.destroy())

    root.deiconify()
    root.mainloop()

if __name__ == "__main__":
    show_image_overlay()
