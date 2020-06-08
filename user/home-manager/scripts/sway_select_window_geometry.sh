#/bin/sh

# Returns the rectangle of the currently focused window using Slurp's format

swaymsg -t get_tree |
  jq -r '.nodes[].nodes[] |
    recurse(.nodes[]?), recurse(.floating_nodes[]?) |
      select(.focused) |
        .rect |
        "\(.x),\(.y) \(.width)x\(.height)"'

