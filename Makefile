USER := andrew
HOST := arrakis
HOME := $(PREFIX)/home/$(USER)

NIXOS_VERSION := 20.03
NIXOS_PREFIX  := $(PREFIX)/etc/nixos
COMMAND       := test
FLAGS         := -I "config=$$(pwd)/config" \
				 -I "modules=$$(pwd)/modules" \
				 -I "bin=$$(pwd)/bin" \
				 $(FLAGS)

# Targets
all: channels
	@sudo nixos-rebuild $(FLAGS) $(COMMAND)

install: channels update config move_to_home
	@sudo nixos-install --no-root-passwd --root "$(PREFIX)" $(FLAGS)
	# TODO use nix-enter here
	#@echo "Set the user password!\n"
	#@sudo passwd $(USER)

upgrade: update switch

update: channels
	@sudo nix-channel --update

switch:
	@sudo nixos-rebuild $(FLAGS) switch

build:
	@sudo nixos-rebuild $(FLAGS) build

boot:
	@sudo nixos-rebuild $(FLAGS) boot

rollback:
	@sudo nixos-rebuild $(FLAGS) --rollback $(COMMAND)

dry:
	@sudo nixos-rebuild $(FLAGS) dry-build

gc:
	@nix-collect-garbage -d

vm:
	@sudo nixos-rebuild $(FLAGS) build-vm

clean:
	@rm -f result


# Parts
config: $(NIXOS_PREFIX)/configuration.nix
move_to_home: $(HOME)/dots

channels:
	@sudo nix-channel --add "https://nixos.org/channels/nixos-${NIXOS_VERSION}" nixos
	@sudo nix-channel --add "https://github.com/rycee/home-manager/archive/release-${NIXOS_VERSION}.tar.gz" home-manager

$(NIXOS_PREFIX)/configuration.nix:
	# @sudo nixos-generate-config --root "$(PREFIX)"
	# @echo "import ./default.nix" | sudo tee "$(NIXOS_PREFIX)/configuration.nix"
	@[ -f hosts/$(HOST)/default.nix ] || echo "WARNING: hosts/$(HOST)/default.nix does not exist"

$(HOME)/dots:
	@mkdir -p $(HOME)/{doc/pres,dl,mus,pic/vid,.local/{temp,share},dev/src}
	@[ -e $(HOME)/dots ] || sudo ln -s $(NIXOS_PREFIX) $(HOME)/dots
	# @[ -e $(PREFIX)/etc/dots ] || sudo ln -s $(HOME)/dots $(PREFIX)/etc/dots
	# TODO Use nix-enter here?
	# @chown $(USER):users -R $(HOME) $(HOME)/dots

# Convenience aliases
i: install
s: switch
up: upgrade


.PHONY: config
