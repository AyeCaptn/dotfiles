#!/usr/bin/env sh

# Print the home space for apps with a persistent workspace. Unlisted utility
# apps intentionally stay on the space where they are opened.
case "${1:-}" in
  Ghostty)
    printf '%s\n' terminal
    ;;
  Zen|Safari|"Brave Browser Nightly"|Helium)
    printf '%s\n' web
    ;;
  Mail|Messages|"Microsoft Outlook"|MSTeams|"Microsoft Teams"|*WhatsApp*|FaceTime|MeetingBar)
    printf '%s\n' comms
    ;;
  Obsidian|Notes|Reminders|Freeform|Journal|Stickies)
    printf '%s\n' notes
    ;;
  Spotify|Music|VLC|TV|Podcasts|Books|News|VoiceMemos|"Voice Memos"|"Plex Media Server"|Chess|Games)
    printf '%s\n' media
    ;;
  Calendar|Contacts|Clock)
    printf '%s\n' calendar
    ;;
  "Visual Studio Code"|Code|Xcode|Zed|"T3 Code"*|Bruno|Docker|Emdash|Poedit|"SF Symbols"*|"Syntax Highlight"|react-tailwind-vite-canary)
    printf '%s\n' development
    ;;
  Affinity*|Canva|CapCut|"DaVinci Resolve"|"Logic Pro"|HandBrake|Blackmagic*|Photos|PowerPhotos|"Image Capture"|"Image Playground"|"Photo Booth"|"QuickTime Player")
    printf '%s\n' creative
    ;;
  Pages|Numbers|Keynote|TextEdit)
    printf '%s\n' office
    ;;
  *)
    exit 1
    ;;
esac
