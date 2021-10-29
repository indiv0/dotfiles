# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  sources = import ../../nix/sources.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # home-manager module
      "${sources.home-manager-master}/nixos"
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lab-ca-vm-02"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s5.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
boot.kernelPackages = pkgs.linuxPackages_latest;
 		boot.kernelParams = ["root=/dev/sda1"];
 		services.openssh.enable = true;
 		services.openssh.passwordAuthentication = true;
 		services.openssh.permitRootLogin = "yes";
 		users.users.root.initialPassword = "root";
		nix.nixPath = [
			"nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
			"nixos-config=/etc/nixos/hosts/lab-ca-vm-02/configuration.nix"
		];
 	

  # Don't allow mutation of users outside of the config.
  users.mutableUsers = false;
  # Add a non-root user.
  users.users.npekin.isNormalUser = true;
  # Set a user password, consider using initialHashedPassword instead.
  #
  # To generate a hash to put in initialHashedPassword you can do this:
  # $ nix-shell --run 'mkpasswd -m SHA-512 -s' -p mkpasswd
  users.users.npekin.initialPassword = "hunter2";
  users.users.npekin.extraGroups = [
    # Add the user to the wheel group so that they have sudo permissions.
    "wheel"
    # Add the user to the docker group so that they can interact with the
    # docker daemon.
    "docker"
  ];

  # Home manager configuration for the non-root user.
  home-manager.users.npekin = { pkgs, ... }: {
    programs.home-manager.enable = true;

    # Enable & configure git.
    programs.git.enable = true;
    programs.git.userEmail = "nikita.pekin@kandy.io";
    programs.git.userName = "indiv0";
    programs.git.lfs.enable = true;
  };

  # Enables docker, a daemon that manages linux containers.
  #
  # Users in the "docker" group can interact with the daemon (e.g. to start
  # or stop containers) using the `docker` command line tool.
  virtualisation.docker.enable = true;
  # Start dockerd on boot.
  #
  # This is required for containers which are created with the
  # `--restart=always` flag to work.
  virtualisation.docker.enableOnBoot = true;
  # Periodically prune Docker resources.
  #
  # If enabled, a systemd timer will run `docker system prune -f` as
  # specified by the `dates` option.
  virtualisation.docker.autoPrune.enable = true;
}

