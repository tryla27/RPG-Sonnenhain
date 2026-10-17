"""Einfaches Bedienfenster für denselben Runner wie die JSON-CLI."""
import json
import os
import queue
import threading
import tkinter as tk
from tkinter import ttk

import hub


def main(config):
    root = tk.Tk()
    root.title("Sonnenhain · Werkzeugzentrale v2")
    root.geometry("1080x760")
    root.configure(bg="#142b32")
    style = ttk.Style(root)
    style.theme_use("clam")
    style.configure("TFrame", background="#142b32")
    style.configure("TLabel", background="#142b32", foreground="#f2e6c7", font=("Segoe UI", 11))
    style.configure("Title.TLabel", font=("Segoe UI", 23, "bold"), foreground="#edcf8b")
    style.configure("TButton", padding=9, font=("Segoe UI", 10))
    style.configure("TCombobox", padding=7)
    frame = ttk.Frame(root, padding=24)
    frame.pack(fill="both", expand=True)
    ttk.Label(frame, text="SONNENHAIN · WERKZEUGZENTRALE", style="Title.TLabel").pack(anchor="w")
    ttk.Label(frame, text="Godot  /  Blender  /  Krita  /  Inkscape  /  ComfyUI").pack(anchor="w", pady=(4, 14))
    ttk.Label(frame, text="Projekt: " + config["project"], wraplength=1010).pack(anchor="w")
    ttk.Label(frame, text="v2 · Externe KI gesperrt · Netzwerk nicht isoliert · Chat-Token nicht messbar").pack(anchor="w", pady=(4, 8))
    ttk.Label(frame, text="Dauerprozesse und KI-Generierung bis zur geprüften Dienst-/Queueverwaltung gesperrt.", wraplength=1000).pack(anchor="w", pady=(0, 14))
    registry = hub.actions(config)
    choices = {f"{value['title']}  [{key}]": key for key, value in registry.items()}
    choices["Gesamtes Grafikpaket bauen und prüfen  [grafikpaket]"] = "grafikpaket"
    selection = tk.StringVar(value=next(iter(choices)))
    chooser = ttk.Combobox(frame, textvariable=selection, values=list(choices), state="readonly")
    chooser.pack(fill="x", pady=(0, 12))
    explanation = ttk.Label(frame, text="", wraplength=1000)
    explanation.pack(anchor="w", pady=(0, 10))
    row = ttk.Frame(frame)
    row.pack(fill="x", pady=(0, 12))
    output = tk.Text(frame, bg="#0c1e24", fg="#dce9df", insertbackground="#edcf8b",
                     font=("Consolas", 10), wrap="word", relief="flat", padx=14, pady=14)
    output.pack(fill="both", expand=True)
    output.configure(state="disabled")
    state = tk.StringVar(value="Bereit. Auswahl prüfen und bei Bedarf ausführen.")
    ttk.Label(frame, textvariable=state, wraplength=1000).pack(anchor="w", pady=(10, 0))
    events = queue.Queue()
    buttons = []
    busy = False
    active_job = None

    def show(value):
        output.configure(state="normal")
        output.delete("1.0", "end")
        output.insert("1.0", json.dumps(value, ensure_ascii=False, indent=2))
        output.configure(state="disabled")

    def describe(event=None):
        recipe = hub.plan(config, choices[selection.get()])
        explanation.configure(text=" → ".join(step["title"] for step in recipe["steps"]) + "\n" +
                              f"Gesamtlimit: {recipe['timeout']} s · maximal 12 Befehle · 0 Wiederholungen. " +
                              " ".join(dict.fromkeys(step["effect"] for step in recipe["steps"] if step["effect"])))

    def background(function, label):
        nonlocal busy
        if busy:
            return
        busy = True
        state.set(label)
        chooser.configure(state="disabled")
        for button in buttons:
            button.configure(state="disabled")

        def work():
            try:
                events.put(("done", function()))
            except Exception as error:
                events.put(("done", {"status": "error", "error": str(error)[:600]}))
        threading.Thread(target=work, daemon=True).start()

    def poll():
        nonlocal busy, active_job
        try:
            kind, result = events.get_nowait()
        except queue.Empty:
            pass
        else:
            show(result)
            if kind == "started":
                active_job = result["id"]
                stop_button.configure(state="normal")
                state.set("Auftrag " + active_job + " läuft. Stop beendet den eigenen Prozessbaum.")
            else:
                busy = False
                active_job = None
                stop_button.configure(state="disabled")
                chooser.configure(state="readonly")
                for button in buttons:
                    button.configure(state="normal")
                state.set("Ergebnis: " + (result.get("status", "Abfrage abgeschlossen") if isinstance(result, dict) else "Verlauf geladen"))
        root.after(150, poll)

    def add_button(text, command):
        button = ttk.Button(row, text=text, command=command)
        button.pack(side="left", padx=(0, 8))
        buttons.append(button)

    def execute_selected():
        action = choices[selection.get()]
        background(lambda: hub.runner.summary(hub.run(config, action, lambda value: events.put(("started", value)))), "Auftrag wird geprüft …")

    def stop_active():
        if active_job:
            try:
                hub.runner.cancel(hub.HOME, active_job)
                state.set("Abbruch angefordert. Prozessbaum wird beendet …")
                stop_button.configure(state="disabled")
            except Exception as error:
                state.set(str(error)[:300])

    add_button("Status prüfen", lambda: background(lambda: hub.status(config), "Werkzeuge und lokale ComfyUI-API prüfen …"))
    add_button("Ablauf ansehen", lambda: show(hub.plan_summary(hub.plan(config, choices[selection.get()]))))
    add_button("Ausführen", execute_selected)
    add_button("Auftragsverlauf", lambda: show(hub.history()))
    add_button("Protokollordner", lambda: (hub.HOME.joinpath("jobs").mkdir(exist_ok=True), os.startfile(hub.HOME / "jobs")))
    stop_button = ttk.Button(row, text="STOP", command=stop_active, state="disabled")
    stop_button.pack(side="left")
    chooser.bind("<<ComboboxSelected>>", describe)

    def close():
        if busy:
            state.set("Bitte den laufenden Auftrag abschließen lassen. Das Fenster bleibt bis dahin offen.")
        else:
            root.destroy()
    root.protocol("WM_DELETE_WINDOW", close)
    describe()
    root.after(150, poll)
    background(lambda: hub.status(config), "Werkzeugstatus wird geprüft …")
    root.mainloop()
