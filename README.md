# 📋 Personal Task Manager with Weather

A modern **Flutter application** for managing daily tasks, tracking productivity, and keeping an eye on the **current weather** ☀️🌧️❄️.  
The app is designed to help you stay organized and boost productivity with reminders, deadlines, and clean UI.

---

## ✨ Features

- 📝 **Add new tasks** with:
  - Title
  - Optional description
  - Deadline
- 📅 **Task list management**:
  - Sorted by deadline
  - Mark tasks as completed (moved to "done" section)
- ✏️ **Edit and delete tasks**
- 🔔 **Local notifications** for upcoming deadlines
- 📊 **Statistics dashboard**:
  - Total completed tasks
  - Most productive day of the week
- 🌍 **Weather widget** above the task list  
  Shows current weather based on user’s location (powered by [WeatherAPI](https://www.weatherapi.com/)).

---

## 🛠️ Requirements

- ✅ Flutter SDK
- ✅ Local database for storing tasks (e.g., `sqflite`)
- ✅ Intuitive, user-friendly UI
- ✅ Strict typing – no usage of `dynamic`

---

## ⚡ Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Gregikkps/personal-task-manager.git
   cd personal-task-manager

## 🛠️ Environment Setup

To use the weather widget, configure the API key with `envied`.

1. **Create** `.env` in the project root:

   ```
   WEATHER_API_KEY=your_api_key
   ```

   Replace `your_api_key` with your WeatherAPI.com key (no spaces).

2. Ensure `.gitignore` includes `.env`.

3. Generate code:

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:

   ```bash
   flutter run
   ```

**Notes**:

- Use `.env.example` as a template.
- Test the key: `curl "https://api.weatherapi.com/v1/current.json?key=YOUR_KEY&q=London"`.
- Masked key in logs (e.g., `****`) is normal due to obfuscation.

See envied docs for more.

## ⚡ APP

<img width="1080" height="2220" alt="Screenshot_1759199083" src="https://github.com/user-attachments/assets/ff941290-ed6e-47b8-844f-0ba6748069d7" />
<img width="1080" height="2220" alt="Screenshot_1759198983" src="https://github.com/user-attachments/assets/afa22a56-49dd-4dbd-a69a-173b6508fae3" />
<img width="1080" height="2220" alt="Screenshot_1759199128" src="https://github.com/user-attachments/assets/f6ef9e75-a5f3-4e37-b653-954cf106c26a" />
<img width="1080" height="2220" alt="Screenshot_1759198976" src="https://github.com/user-attachments/assets/70e66056-c945-4af8-9121-54a23d3a1f64" />
<img width="1080" height="2220" alt="Screenshot_1759198964" src="https://github.com/user-attachments/assets/7614cd65-4279-44c8-874b-3d1526366dd9" />
<img width="1080" height="2220" alt="Screenshot_1759199556" src="https://github.com/user-attachments/assets/3b7a20d6-0019-4cfa-ade2-526d8f23c4c3" />
<img width="1080" height="2220" alt="Screenshot_1759199428" src="https://github.com/user-attachments/assets/7cc00bfc-9de7-4dec-8c6e-af8ed1f18fc0" />
<img width="1080" height="2220" alt="Screenshot_1759199142" src="https://github.com/user-attachments/assets/c2e7119c-a70b-4784-a473-84312f7e1b13" />
