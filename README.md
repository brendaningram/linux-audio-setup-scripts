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
  - [Debian 11 (bullseye) JACK](debian/11-bullseye/install-audio-jack.sh)
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
  - [20.04 (focal) JACK](ubuntu/focal/install-audio.sh)
  - [22.04 (jammy) JACK](ubuntu/jammy/install-audio-jack.sh)
  - [22.04 (jammy) PIPEWIRE](ubuntu/jammy/install-audio-pipewire.sh)
- **Zorin OS**
  - [16](zorinos/16/install-audio.sh)

## You can find me at:

### Personal

- [brendaningram.com](https://brendaningram.com)
- [Reddit](https://www.reddit.com/user/brendaningram)
- [Discord](https://discord.com/channels/901735226554851418/901735227565682739)

### Air Audio (audio news and tutorials)

- [Air Audio](https://airaudiohq.com)
- [Patreon](https://www.patreon.com/airaudiohq)
- [YouTube](https://www.youtube.com/channel/UCypNYnOtbvtSXEsDWqAEcdA)
- [Facebook](https://www.facebook.com/airaudiohq)
- [Instagram](https://www.instagram.com/airaudiohq)

### Feathernator (my music)

- [Feathernator (my music)](https://feathernator.com)
- [Bandcamp](https://feathernator.bandcamp.com)
- [Soundcloud](https://soundcloud.com/feathernator)
- [YouTube](https://www.youtube.com/channel/UCypNYnOtbvtSXEsDWqAEcdA)
- [Facebook](https://www.facebook.com/feathernator)
- [Instagram](https://www.instagram.com/feathernator)
- [Twitter](https://www.twitter.com/feathernator)

## Notes:

#### SSH clone this repository
`git clone git@github.com:brendaningram/linux-audio-setup-scripts.git`

#### To add yourself as a sudo user with no password

`su -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/$USER"`
