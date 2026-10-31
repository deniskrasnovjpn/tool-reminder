#!/bin/bash
# Opens files in the user's default app for .md, falling back to a plain text editor.
# Windows: the .md association, else Notepad. macOS: open, else TextEdit.
# Linux: xdg-open, else $VISUAL / $EDITOR (only GUI editors work: there is no terminal here).
# Prints the paths it could not open.
status=0
for f in "$@"; do
  [ -e "$f" ] || { echo "not found: $f"; status=1; continue; }
  case "$(uname -s)" in
    MINGW* | MSYS* | CYGWIN*)
      w=$(cygpath -w "$f")
      if reg query 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.md\UserChoice' >/dev/null 2>&1 ||
        cmd.exe //c "assoc .md" >/dev/null 2>&1; then
        cmd.exe //c start "" "$w" || { echo "could not open: $f"; status=1; }
      else
        (notepad.exe "$w" >/dev/null 2>&1 &)
      fi
      ;;
    Darwin)
      open "$f" 2>/dev/null || open -e "$f" || { echo "could not open: $f"; status=1; }
      ;;
    *)
      if command -v xdg-open >/dev/null 2>&1 && xdg-open "$f" >/dev/null 2>&1; then
        :
      elif [ -n "${VISUAL:-$EDITOR}" ]; then
        (nohup ${VISUAL:-$EDITOR} "$f" >/dev/null 2>&1 &)
      else
        echo "could not open: $f"
        status=1
      fi
      ;;
  esac
done
exit "$status"
