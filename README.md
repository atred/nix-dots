[![Made with Doom Emacs](https://img.shields.io/badge/Made_with-Doom_Emacs-blueviolet.svg?style=flat-square&logo=GNU%20Emacs&logoColor=white)](https://github.com/hlissner/doom-emacs)
[![NixOS 20.03](https://img.shields.io/badge/NixOS-v20.03-blue.svg?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)

![Me looking busy](/../screenshots/fluorescence/fakebusy.png?raw=true)

<p align="center">
<span><img src="/../screenshots/fluorescence/desktop.png?raw=true" height="188" /></span>
<span><img src="/../screenshots/fluorescence/rofi.png?raw=true" height="188" /></span>
<span><img src="/../screenshots/fluorescence/tiling.png?raw=true" height="188" /></span>
</p>

# My dotfiles

+ **Operating System:** NixOS
+ **Shell:** oh-my-zsh
+ **DM:** lightdm + lightdm-mini-greeter
+ **WM:** bspwm + polybar
+ **Editor:** Doom Emacs (and occasionally neovim)
+ **Terminal:** st
+ **Launcher:** rofi
+ **Browser:** firefox
+ **GTK Theme:** [Ant Dracula](https://github.com/EliverLara/Ant-Dracula)
+ **Icon Theme:** [Paper Mono Dark](https://github.com/snwh/paper-icon-theme)

*Works on my machine* ¯\\\_(ツ)_/¯

## Quick start

```
# Assumes your partitions are set up and root is mounted on /mnt
nix-env -iA nixos.git
git clone https://github.com/atred/new-dots /etc/dots
make -C /etc/dots install
```

Which is equivalent to:

```
USER=${USER:-atred}
HOST=${HOST:-arrakis}
NIXOS_VERSION=20.03
DOTFILES=/home/$USER/dots

git clone https://github.com/atred/new-dots /etc/dots
ln -s /etc/dots $DOTFILES
chown -R $USER:users $DOTFILES

# make channels
nix-channel --add "https://nixos.org/channels/nixos-${NIXOS_VERSION}" nixos
nix-channel --add "https://github.com/rycee/home-manager/archive/release-${NIXOS_VERSION}.tar.gz" home-manager

# make /etc/nixos/configuration.nix
nixos-generate-config --root /mnt
echo "import /etc/dots \"$$HOST\" \"$$USER\"" >/mnt/etc/nixos/configuration.nix

# make install
nixos-install --root /mnt -I "my=/etc/dots"
passwd $USER
```

### Management

+ `make` = `nixos-rebuild test`
+ `make switch` = `nixos-rebuild switch`
+ `make upgrade` = `nix-channel --update && nixos-rebuild switch`
+ `make install` = `nixos-generate-config --root $PREFIX && nixos-install --root $PREFIX`
+ `make gc` = `nix-collect-garbage -d` (use sudo to clear system profile)

### Partitioning

Here is what I run for 20.03 on my T480 (assuming/dev/sda1 is boot, /dev/sda2 is swap, and /dev/sda3 is root)
```
sudo su
cfdisk
mkfs.fat -F 32 -n boot /dev/sda1
mkswap -L swap /dev/sda2
mkfs.ext4 -L nixos /dev/sda3

mount /dev/sda3 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
```

#### Note for QMK
To install qmk (once you've booted into your new system),
1. Clone your fork. `~/dev/qmk` is where I like to put it.
2. In the cloned directory, run `nix-shell` and wait for it to build everything it needs.
3. Run `make git-submodule` to pull the rest of the prereqs.
4. Run `sudo make planck/rev6:atred` to test config and `make planck/rev6:atred:flash` to flash.