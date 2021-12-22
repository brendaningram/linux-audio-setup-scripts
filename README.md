# Linux Audio Installation Scripts

*By Brendan Ingram*

This repository contains scripts and guides to get you running with a Linux system capable of professional audio engineering and music production.

## How do I use this?

Find your distribution in the list below, click the link, and run the **SINGLE** command - easy!

## Supported distributions:

- **Arch**
  - [JACK](arch/install-audio-jack.sh)
  - [Pipewire](arch/install-audio-pipewire.sh)
- **Debian**
  - [Debian 11 (bullseye)](debian/11-bullseye/install-audio.sh)
  - [Debian 12 (bookworm) JACK](debian/12-bookworm/install-audio-jack.sh)
  - [Debian 12 (bookworm) Pipewire](debian/12-bookworm/install-audio-pipewire.sh)
- **Fedora**
  - coming soon
- **KDE Neon**
  - [20.04 (based on focal)](neon/focal/install-audio.sh)
- **Manjaro**
  - [Pipewire](manjaro/install-audio-pipewire.sh)
- **Mint**
  - [20 (uma)](mint/uma/install-audio.sh)
- **Ubuntu**
  - [20.04 (focal)](ubuntu/focal/install-audio.sh)
  - [21.10 (impish) JACK](ubuntu/impish/install-audio-jack.sh)
- **Zorin OS**
  - [16](zorinos/16/install-audio.sh)

## You can find me at:
- [Air Audio (Post Production) Studio](https://airaudiostudio.com)
- [brendaningram.com](https://brendaningram.com)
- [Patreon](https://www.patreon.com/airaudiostudio)
- [YouTube](https://www.youtube.com/channel/UCypNYnOtbvtSXEsDWqAEcdA)
- [Facebook](https://www.facebook.com/airaudiostudio)
- [Instagram](https://www.instagram.com/airaudiostudio)
- [Reddit](https://www.reddit.com/user/brendaningram)
- [Discord](https://discord.com/channels/901735226554851418/901735227565682739)
- [Bandcamp](https://berzgernden.bandcamp.com)
- [Soundcloud](https://soundcloud.com/berzgernden)

## Notes:

#### SSH clone this repository
`git clone git@github.com:brendaningram/install-scripts.git`

#### To add yourself as a sudo user with no password

`su -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$USER"`
