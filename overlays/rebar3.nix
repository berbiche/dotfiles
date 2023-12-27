final: prev: {
  rebar3 = prev.rebar3.overrideAttrs (_drv: {
    # The test suite does not run in parallel and is very slow
    doCheck = false;
  });
}
