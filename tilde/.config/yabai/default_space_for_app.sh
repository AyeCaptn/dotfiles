#!/usr/bin/env sh

# Print the home space for apps with a persistent workspace. Unlisted utility
# apps intentionally stay on the space where they are opened.
case "${1:-}" in
  Ghostty)
    printf '%s\n' terminal
    ;;
  Zen|Safari|Helium)
    printf '%s\n' web
    ;;
  Mail|Messages|"Microsoft Outlook"|MSTeams|"Microsoft Teams"|*WhatsApp*|FaceTime)
    printf '%s\n' comms
    ;;
  Obsidian|Notes|Reminders|Freeform|Journal|Stickies)
    printf '%s\n' notes
    ;;
  Spotify|Music|VLC|TV|Podcasts|Books|News|VoiceMemos|"Voice Memos"|Chess|Games)
    printf '%s\n' media
    ;;
  Calendar|Contacts|Clock)
    printf '%s\n' calendar
    ;;
  "Visual Studio Code"|Code|Xcode|Zed|Docker|Emdash|Poedit|"SF Symbols"*|"Syntax Highlight"|react-tailwind-vite-canary)
    printf '%s\n' development
    ;;
  Affinity*|Canva|"DaVinci Resolve"|"Logic Pro"|HandBrake|Blackmagic*|Photos|PowerPhotos|"Image Capture"|"Image Playground"|"Photo Booth"|"QuickTime Player")
    printf '%s\n' creative
    ;;
  Pages|Numbers|Keynote|TextEdit)
    printf '%s\n' office
    ;;
  *)
    exit 1
    ;;
esac
