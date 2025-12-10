# Jumping Polygons

![Godot Engine](https://img.shields.io/badge/Godot-v4.x-%23478cbf?logo=godot-engine&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-brightgreen)
![Status](https://img.shields.io/badge/Status-Beta%20v0.9-orange)

A rhythm-based auto-runner platformer inspired by *Geometry Dash*, built with **Godot Engine 4**. Navigate through synchronized obstacles, control gravity, and master different vehicle modes in a neon-retro aesthetic world.

---

## Gallery

> **Note:** Screenshots reflect the current build.

### Main Menu & UI
*Minimalist menu with dynamic background and Options submenu.*
<img width="2553" height="1352" alt="Captura de pantalla 2025-12-09 202650" src="https://github.com/user-attachments/assets/6da57fe0-b317-4d19-bef1-2d0dd5fa4655" />
<img width="2552" height="1351" alt="Captura de pantalla 2025-12-09 203047" src="https://github.com/user-attachments/assets/a1165342-b2bc-4e9f-932a-733a164d50c8" />
<img width="2555" height="1346" alt="Captura de pantalla 2025-12-09 203339" src="https://github.com/user-attachments/assets/a12552b2-aafb-41c0-9978-ab9b4b51fc80" />
<img width="2551" height="1346" alt="Captura de pantalla 2025-12-09 203401" src="https://github.com/user-attachments/assets/d939dc09-9e93-4573-aba6-3ff3fb9fc6a4" />
<img width="2554" height="1354" alt="Captura de pantalla 2025-12-09 203426" src="https://github.com/user-attachments/assets/6884a097-ebad-4e05-a9c6-4d63f740f238" />
<img width="2555" height="1349" alt="Captura de pantalla 2025-12-09 202709" src="https://github.com/user-attachments/assets/ea6e218a-b917-419c-9065-b7954ebf5153" />
<img width="2555" height="1349" alt="Captura de pantalla 2025-12-09 202709" src="https://github.com/user-attachments/assets/db340a49-17d6-451f-b635-1719e8b03f2e" />
<img width="2550" height="1342" alt="Captura de pantalla 2025-12-09 203651" src="https://github.com/user-attachments/assets/fd964632-ac1b-4810-9b9f-bf780c61cb78" />


### Core Gameplay
*High-speed platforming action with spikes, blocks, and orbs.*




## Key Features

### Gameplay
* **Rhythmic Action:** Obstacles are synced to the beat of the music.
* **Dual Modes:**
    * **Cube:** Standard platforming with rotational physics.
    * **Ship:** Fly mechanics (Hold to fly, release to fall).
* **Advanced Mechanics:**
    * **Jump Orbs:** Mid-air double jumps with visual pulse effects.
    * **Gravity Portals:** Inverts the player's gravity and rotates the view.
    * **Input Buffering:** "Coyote time" and input queuing for responsive controls.

### Technical Implementation
* **Singleton Architecture:**
    * `GameManager`: Handles global stats (attempts, deaths).
    * `AudioManager`: "Fire-and-forget" system ensuring SFX (death/victory) play smoothly across scene reloads.
    * `TransitionLayer`: Global CanvasLayer handling shader-based transitions.
* **Shaders:** Custom GLSL shader for progressive screen pixelation during scene changes.
* **Cross-Platform Input:** Unified input map supporting Keyboard (Space/Up), Mouse (Click), and Android Touchscreen.

---

## Controls

| Action | PC (Keyboard/Mouse) | Mobile (Android) |
| :--- | :--- | :--- |
| **Jump** | `Spacebar`, `Up Arrow`, or `Left Click` | `Tap Screen` |
| **Fly (Ship)** | `Hold` Key/Click to go up | `Hold` Screen to go up |
| **Pause** | `UI Button` (Top Right) | `UI Button` (Top Right) |

---

## Installation & Setup

### To Play (Binaries)
1.  Go to the [Releases](../../releases) page.
2.  Download the `.zip` for your platform (Windows or Android APK).
3.  Extract and run `JumpingPolygons.exe` or install the APK.

### To Edit (Source Code)
1.  Ensure you have **Godot 4.x** installed.
2.  Clone this repository:
    ```bash
    git clone [https://github.com/your-username/jumping-polygons.git](https://github.com/your-username/jumping-polygons.git)
    ```
3.  Open Godot, click **Import**, and select the `project.godot` file.

---

## Project Structure

- `assets/`: Sprites, Audio files (WAV), and Fonts.
- `scenes/`:
    - `levels/`: Level design scenes (Level 1, 2, 3).
    - `objects/`: Prefabs like Player, Spikes, Orbs, Portals.
    - `ui/`: HUD, Main Menu, Options, Game Over.
- `scripts/`: GDScript files separated by logic (Global, Objects, UI).

---

## Credits

**Development**
* Created by **Edgar Herrera** for Creación de Videojuegos class.

**Music**
* *Spacebrain* by Caro
* *BitByBit* by 8-BiTek
* *Epilogue* by Creo

**Assets**
* Tilesets by TotusLotus
* Spikes by Omniclause
* Backgrounds by Trixie

---

*Educational Project - Not for commercial distribution.*
