#1/bin/bash

from=$1
to=$2
if [ -z "$from" -o -z "$to" ]; then
  echo "usage: $0 <from> <to>"
  exit 1
fi
temp="$(mktemp /tmp/make-changelog.XXXXXX)"

git --no-pager log --oneline ${from}..${to} | grep -v -e "Update submodule" -e "Update frida" | sed -e "s/^/frida\/frida\@/"
for module in frida-gum frida-core frida-python frida-node frida-qml frida-clr frida-swift; do
  git --no-pager diff ${from}..${to} $module > "$temp"
  if grep -q "Subproject commit" "$temp"; then
    from_rev=$(egrep "^-Subproject" "$temp" | cut -f3 -d" ")
    to_rev=$(egrep "^\+Subproject" "$temp" | cut -f3 -d" ")
    pushd $module >/dev/null
    git --no-pager log --oneline ${from_rev}..${to_rev} | sed -e "s/^/frida\/$module\@/"
    popd >/dev/null
    echo ""
  fi
done
