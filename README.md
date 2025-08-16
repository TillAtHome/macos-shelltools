# macOS Setup Scripts

Minimal, system-focused shell scripts for configuration, recovery, and customization of macOS (Zsh, Terminal, Finder, Launchd, Homebrew).

## Structure

```
.
├── zsh/                    # Zsh configuration files
│   ├── zprofile.txt        # Content of .zprofile
│   └── zshrc.txt           # Content of .zshrc
├── scripts/                # Shell scripts (setup, reset, customization)
│   ├── macsetup.sh         # Main setup script for fresh macOS installs
│   ├── finder-reset.sh     # Finder, Dock, and defaults reset with cache cleanup
│   ├── terminalprofile.sh  # Imports and applies Terminal profile
│   ├── goto_folder.sh      # Clears Finder's "Go to folder" history
│   ├── snap.sh             # Deletes local Time Machine snapshots
│   └── trash.sh            # Finds app leftovers after deletion
```

## Notes

- Tested on macOS 14 (Sonoma) and 15 (Sequoia)
- No frameworks, no dependencies
- Homebrew recommended for recent `bash`, `nano`, `grep`, etc.
- Scripts are fully commented, customizable, and portable
- No telemetry, no automatic network access (except during Homebrew install)

## License

MIT License – free use with attribution.  
Author: **TilliAtHome**
