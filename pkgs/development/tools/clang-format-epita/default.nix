{ lib
, clang-tools
, findutils
, git
, writeShellScriptBin
}:

writeShellScriptBin "clang-format-epita" ''
  # This script checks a git repository has a clang-format configuration and runs
  # clang-format with the given parameters.

  die() {
      printf "\033[0;31m''${@}\033[0m\n"
      exit 1
  }
  
  repo="$(${git}/bin/git rev-parse --show-toplevel 2>/dev/null)"
  
  if test "$?" -ne 0; then
      die "You must run this script from the work tree of a git repository"
  fi
  
  clang_format_file="''${repo}/.clang-format"
  
  if ! test -f "''${clang_format_file}"; then
      die "Failed to find clang-format configuration at ''${clang_format_file}"
  fi
  
  ${findutils}/bin/find "$repo" -type f -name '*.[ch]' -exec ${clang-tools}/bin/clang-format --style=file -i {} ';'

'' // {
  meta = with lib; {
    platforms = platforms.linux;
  };
}
