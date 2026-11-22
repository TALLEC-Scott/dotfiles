#!/bin/sh
# Prints Spotify status for fastfetch by reading the Windows Spotify window title.
# Playing: title is "Artist - Song". Paused: title is "Spotify Premium"/"Spotify Free".
command -v powershell.exe >/dev/null 2>&1 || { echo "unavailable"; exit 0; }
t=$(timeout 3 powershell.exe -NoProfile -NonInteractive -Command \
  "[Console]::OutputEncoding=[Text.Encoding]::UTF8; (Get-Process Spotify -ErrorAction SilentlyContinue | Where-Object MainWindowTitle | Select-Object -First 1).MainWindowTitle" \
  2>/dev/null | tr -d '\r')
case "$t" in
  "")        echo "not running" ;;
  Spotify*)  echo "⏸ paused" ;;
  *)         echo "▶ $t" ;;
esac
