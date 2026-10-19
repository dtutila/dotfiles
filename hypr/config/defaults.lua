-- Hyprland default apps

TERMINAL = "kitty"
FILE_MANAGER = "nautilus"
BROWSER = "firefox"
EDITOR = "subl"
CALCULATOR = "gnome-calculator"
MUSIC = "flatpak run com.spotify.Client"
CHROMIUM = 'chromium --password-store="gnome-libsecret"'
CHROME = 'google-chrome --password-store="gnome-libsecret"'
W_A_CHROMIUM =
	'chromium  --new-window --password-store="gnome-libsecret" --user-data-dir="$HOME/.config/chromium" --profile-directory="Profile 1" --app'
WEB_APP =
	'google-chrome --new-window --password-store="gnome-libsecret" --user-data-dir="$HOME/.config/google-chrome" --profile-directory="Default" --app'
