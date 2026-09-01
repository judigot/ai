#!/bin/sh

# Install official skills.sh finder + Matt Pocock skills globally.
# Do not copy those files into this overlay; they update on their own.

PROJECT_DIRECTORY=$(cd "$(dirname "$0")/.." || exit 1; pwd)
readonly PROJECT_DIRECTORY

main() {
	cd "$PROJECT_DIRECTORY" || exit 1
	install_find_skills
	install_matt_pocock
	print_next_steps
}

install_find_skills() {
	npx --yes skills@latest add vercel-labs/skills --skill find-skills -g -y
}

install_matt_pocock() {
	npx --yes skills@latest add mattpocock/skills --skill '*' -g -y
}

print_next_steps() {
	printf '%s\n' "Installed globally for this user."
	printf '%s\n' "In each app repo, run /setup-matt-pocock-skills once."
	printf '%s\n' "Do not also claude-plugin-install mattpocock-skills unless you uninstall this copy."
}

main "$@"
