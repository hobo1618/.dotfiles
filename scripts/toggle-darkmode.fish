#!/usr/bin/env fish

function toggle-darkmode
  set current (gsettings get org.gnome.desktop.interface color-scheme)
  if test "$current" = "'prefer-dark'"
    gsettings set org.gnome.desktop.interface color-scheme 'default'
    echo "Switched to Light Mode"
  else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    echo "Switched to Dark Mode"
  end
end
