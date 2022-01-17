# Package is currently broken due to dependency `python39.capstone`
final: prev: {
  pwndbg = prev.runCommandLocal "fake-pwndbg" { } "mkdir \"$out\"";
}
