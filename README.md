Abyss OS "official" packages
======

[![Build Status](https://drone.abyss.run/api/badges/abyss-os/phase1/status.svg)](https://drone.abyss.run/abyss-os/phase1) [![Docker Pulls](https://img.shields.io/docker/pulls/abyssos/abyss.svg)](https://hub.docker.com/r/abyssos/abyss)

To contribute:
1. If you haven't contributed before, add yourself to the list of AUTHORS.
  This should be done with a separate commit, the title being `AUTHORS: add [name]`.
  By doing this you acknowledge that your current and future contributions will be licensed the same as the repository.
2. Create a commit (one per package). The commit message should be `<path>: action`.
  For example, `core/zsh: upgrade to <version>`.

Dependencies:
 * *core* should be installable on its own
 * *core* can depend on *devel* to build itself
 * nothing may depend on *extra*
