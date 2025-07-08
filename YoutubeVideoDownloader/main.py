import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext, ttk
from yt_dlp import YoutubeDL
import threading
import os
import re
import sys

class YouTubeDownloaderApp:
    def __init__(self, root):
        self.root = root
        self.root.title("🎬 YouTube Downloader GUI")
        self.root.geometry("700x620")
        self.root.resizable(False, False)

        self.cookies_path = ""
        self.output_path = ""

        # Progress bar
        self.progress = ttk.Progressbar(root, orient="horizontal", length=680, mode="determinate")
        self.progress.pack(padx=10, pady=(10, 0))

        # URLs input
        ttk.Label(root, text="Enter YouTube URLs (one per line):").pack(anchor='w', padx=10, pady=(10, 0))
        self.urls_box = scrolledtext.ScrolledText(root, height=8, wrap=tk.WORD)
        self.urls_box.pack(fill=tk.X, padx=10, pady=5)

        # Output folder
        ttk.Button(root, text="📁 Select Output Folder", command=self.select_output_folder).pack(pady=5)
        self.output_label = ttk.Label(root, text="No folder selected", foreground="gray")
        self.output_label.pack()

        # Cookies file
        ttk.Button(root, text="🍪 Select cookies.txt (optional)", command=self.select_cookies_file).pack(pady=5)
        self.cookies_label = ttk.Label(root, text="No cookies file selected", foreground="gray")
        self.cookies_label.pack()

        # Start button
        ttk.Button(root, text="⬇️ Start Download", command=self.start_download).pack(pady=15)

        # Output log
        ttk.Label(root, text="Output Log:").pack(anchor='w', padx=10, pady=(10, 0))
        self.log_output = scrolledtext.ScrolledText(root, height=18, wrap=tk.WORD, bg="black", fg="white", insertbackground="white")
        self.log_output.pack(fill=tk.BOTH, padx=10, pady=5, expand=True)

        self.log_output.tag_config("info", foreground="white")
        self.log_output.tag_config("progress", foreground="gray")
        self.log_output.tag_config("error", foreground="red")

    def log(self, text, tag="info"):
        self.log_output.config(state='normal')
        self.log_output.insert(tk.END, text + '\n', tag)
        self.log_output.see(tk.END)
        self.log_output.config(state='disabled')

    def update_last_log_line(self, new_text, tag="progress"):
        self.log_output.config(state='normal')
        lines = self.log_output.get("1.0", tk.END).splitlines()
        if lines:
            self.log_output.delete("end-2l", "end-1l")
        self.log_output.insert(tk.END, new_text + '\n', tag)
        self.log_output.see(tk.END)
        self.log_output.config(state='disabled')

    def update_progress_bar(self, percent):
        try:
            self.progress["value"] = float(percent)
            self.root.update_idletasks()
        except:
            pass

    def select_output_folder(self):
        folder = filedialog.askdirectory()
        if folder:
            self.output_path = folder
            self.output_label.config(text=folder, foreground="black")
    def get_ffmpeg_path(self):
        if getattr(sys, 'frozen', False):
        # Inside the .app bundle: go to ../Resources/ffmpeg
         app_dir = os.path.dirname(sys.executable)
         return os.path.abspath(os.path.join(app_dir, '..', 'Resources', 'ffmpeg'))
        return "ffmpeg"

    def select_cookies_file(self):
        file = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
        if file:
            self.cookies_path = file
            self.cookies_label.config(text=file, foreground="black")

    def start_download(self):
        thread = threading.Thread(target=self.download_videos)
        thread.start()

    def download_videos(self):
        urls = self.urls_box.get("1.0", tk.END).strip().splitlines()
        urls = list(dict.fromkeys(u.strip() for u in urls if u.strip()))

        if not urls:
            messagebox.showerror("Error", "No URLs entered.")
            return
        if not self.output_path:
            messagebox.showerror("Error", "No output folder selected.")
            return

        for idx, url in enumerate(urls, start=1):
            self.progress["value"] = 0
            self.progress["maximum"] = 100

            self.log(f"\n➡️ [{idx}/{len(urls)}] Downloading: {url}")
            self.log(f"🔧 Using yt_dlp library for: {url}", "info")

        ydl_opts = {
    'format': 'bestvideo[height<=720]+bestaudio/best[height<=720]/best[height<=480]',
    'outtmpl': os.path.join(self.output_path, '%(title)s.%(ext)s'),
    'merge_output_format': 'mp4',
    'nooverwrites': True,
    'progress_hooks': [self.hook],
    'quiet': True,
    'noprogress': True,
    'no_color': True,
    'ignoreerrors': True,
    'logger': YTDLogger(self),
    'ffmpeg_location': self.get_ffmpeg_path(),

}


        if self.cookies_path:
                ydl_opts['cookiefile'] = self.cookies_path

        try:
                with YoutubeDL(ydl_opts) as ydl:
                    ydl.download([url])
                self.log(f"✅ Finished: {url}", "info")
        except Exception as e:
                self.log(f"❌ Error downloading {url}: {e}", "error")

        self.progress["value"] = 0
        self.log("\n🎉 All downloads complete.", "info")

    def hook(self, d):
     if d['status'] == 'downloading':
        percent = d.get('_percent_str', '0.0%').strip()
        speed = d.get('_speed_str', '0 KB/s').strip()
        eta = d.get('_eta_str', 'N/A').strip()
        self.update_progress_bar(float(percent.replace('%', '')))
        self.update_last_log_line(f"⬇️ {percent} at {speed} ETA {eta}", "progress")
     elif d['status'] == 'finished':
        self.update_progress_bar(100)
        self.update_last_log_line("✅ Download finished. Processing...", "info")


class YTDLogger:
    def __init__(self, app):
        self.app = app

    def debug(self, msg):
        msg = msg.strip()
        if msg:
            self.app.log(msg, "info")

    def warning(self, msg):
        self.app.log("⚠️ " + msg.strip(), "error")

    def error(self, msg):
        self.app.log("❌ " + msg.strip(), "error")

if __name__ == "__main__":
    root = tk.Tk()
    app = YouTubeDownloaderApp(root)
    root.mainloop()
