
# Nexus Linux

**Give old computers a new life.**

Nexus Linux is an open-source Linux distribution based on Debian. Its goal is to make everyday computing practical on both older and modern computers through a lightweight system, sensible defaults, and a clean desktop experience.

> The project is under active development. No installable ISO is available yet.

## Project Principles

- **Lightweight:** Keep memory, storage, and background resource usage low.
- **Balanced:** Remove unnecessary weight without sacrificing essential functionality.
- **Usable:** Provide a graphical desktop, networking, file management, and a web browser.
- **Open Source:** Keep the project transparent and community-driven.
- **Honest Performance:** Publish real hardware requirements and test results.

## Planned Editions

| Edition | Desktop | Target |
|---|---|---|
| Nexus Lite | IceWM | Older computers and limited memory |
| Nexus Balanced | XFCE | Computers seeking a balance between performance and usability |

The initial development target is **Nexus Lite**.

## Base System

- Debian Stable
- Debian Live / live-build
- 64-bit x86 (amd64) initially
- IceWM desktop
- Firefox ESR as the planned default browser

## Project Structure

```text
Nexus-Linux/
├── .github/
│   └── workflows/
├── config/
│   └── package-lists/
├── docs/
├── scripts/
├── .gitignore
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Development Status

Nexus Linux is currently in its foundation stage. We are preparing the repository structure, package selection, build configuration, and automated validation before producing the first ISO.

## Contributing

Contributions, bug reports, documentation improvements, and hardware test reports are welcome.

## License

Nexus Linux is distributed under the GNU General Public License v3.0. See [LICENSE](LICENSE).
