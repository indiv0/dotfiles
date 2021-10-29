# Connectivity info for Linux VM
NIXADDR ?= unset
# Configuration info for Linux VM
HOST ?= unset
USER ?= unset

NIXBLOCKDEVICE ?= sda

default:
	echo "Read the README"

nixos.iso:
	./build.sh

vm/bootstrap:
	ssh root@$(NIXADDR) " \
		parted /dev/$(NIXBLOCKDEVICE) -- mklabel gpt; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart primary 512MiB -8GiB; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart primary linux-swap -8GiB 100\%; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart ESP fat32 1MiB 512MiB; \
		parted /dev/$(NIXBLOCKDEVICE) -- set 3 esp on; \
		mkfs.ext4 -L nixos /dev/$(NIXBLOCKDEVICE)1; \
		mkswap -L swap /dev/$(NIXBLOCKDEVICE)2; \
		mkfs.fat -F 32 -n boot /dev/$(NIXBLOCKDEVICE)3; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			boot.kernelPackages = pkgs.linuxPackages_latest;\n \
			boot.kernelParams = [\"root=/dev/$(NIXBLOCKDEVICE)1\"];\n \
			services.openssh.enable = true;\n \
			services.openssh.passwordAuthentication = true;\n \
			services.openssh.permitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd; \
		reboot; \
	"

vm/bootstrap-dotfiles:
	ssh root@$(NIXADDR) " \
		nix-shell -p git --command 'git clone https://github.com/indiv0/dotfiles /etc/nixos-new'; \
		cp /etc/nixos/hardware-configuration.nix /etc/nixos-new/hosts/$(HOST)/hardware-configuration.nix; \
		NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos-new/hosts/$(HOST)/configuration.nix nixos-rebuild switch; \
		rm -r /etc/nixos; \
		mv /etc/nixos-new /etc/nixos; \
		NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/hosts/$(HOST)/configuration.nix nixos-rebuild switch; \
		chown -R $(USER):users /etc/nixos; \
		nix-shell -p git --command 'cd /etc/nixos && git remote set-url origin git@github.com:indiv0/dotfiles'; \
		reboot; \
	"
