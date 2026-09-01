#!/bin/sh

# Idempotent bootstrap for Cloud Agents.
# Ensures the shell tooling used to develop and lint this plugin is present.

PROJECT_DIRECTORY=$(cd "$(dirname "$0")/.." && pwd) # Repository root
readonly PROJECT_DIRECTORY

main() {
	ensure_shellcheck
	report_toolchain
}

ensure_shellcheck() {
	if command -v shellcheck >/dev/null 2>&1; then
		return 0
	fi

	as_root apt-get update -qq
	as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq shellcheck
}

report_toolchain() {
	cd "$PROJECT_DIRECTORY" || exit 1
	printf 'git:        %s\n' "$(git --version)"
	printf 'jq:         %s\n' "$(jq --version)"
	printf 'node:       %s\n' "$(node --version)"
	printf 'shellcheck: %s\n' "$(shellcheck --version | awk '/^version:/ {print $2}')"
}

as_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	else
		sudo "$@"
	fi
}

main "$@"
