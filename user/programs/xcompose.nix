{ config, lib, pkgs, ... }:

{
  home.file.".XCompose".text = ''
    include "%L"

    # ''${lib.concatMapStringsSep "\n" (makeMultiCombi) [ { inf = "∞"; } ] }

    <Multi_key> <i> <n> <f>          : "∞"
    <Multi_key> <i> <n> <t>          : "∫"
    <Multi_key> <i> <n>              : "∈"
    <Multi_key> <*> <o>              : "°"
    <Multi_key> <o> <*>              : "°"
    # Emojis and whatnot
    <Multi_key> <s> <h> <r> <u> <g>  : "¯\\_(ツ)_/¯"
    <Multi_key> <s> <a> <d>          : "😿"


    # Greek letters
    <Multi_key> <g> <a>       : "α"        U03B1                # GREEK SMALL LETTER ALPHA
    <Multi_key> <g> <b>       : "β"        U03B2                # GREEK SMALL LETTER BETA
    <Multi_key> <g> <c>       : "ξ"        U03BE                # GREEK SMALL LETTER XI
    <Multi_key> <g> <d>       : "δ"        U03B4                # GREEK SMALL LETTER DELTA
    <Multi_key> <g> <e>       : "ε"        U03B5                # GREEK SMALL LETTER EPSILON
    <Multi_key> <g> <f>       : "φ"        U03C6                # GREEK SMALL LETTER PHI
    <Multi_key> <g> <g>       : "γ"        U03B3                # GREEK SMALL LETTER GAMMA
    <Multi_key> <g> <h>       : "θ"        U03B8                # GREEK SMALL LETTER THETA
    <Multi_key> <g> <i>       : "ι"        U03B9                # GREEK SMALL LETTER ΙΟΤΑ
    <Multi_key> <g> <k>       : "κ"        U03BA                # GREEK SMALL LETTER KAPPA
    <Multi_key> <g> <l>       : "λ"        U03BB                # GREEK SMALL LETTER LAMBDA
    <Multi_key> <g> <m>       : "μ"        U03BC                # GREEK SMALL LETTER MU
    <Multi_key> <g> <n>       : "ν"        U03BD                # GREEK SMALL LETTER NU
    <Multi_key> <g> <o>       : "ο"        U03BF                # GREEK SMALL LETTER OMICRON
    <Multi_key> <g> <p>       : "π"        U03C0                # GREEK SMALL LETTER PI
    <Multi_key> <g> <q>       : "ψ"        U03C8                # GREEK SMALL LETTER PSI
    <Multi_key> <g> <r>       : "ρ"        U03C1                # GREEK SMALL LETTER RHO
    <Multi_key> <g> <s>       : "σ"        U03C3                # GREEK SMALL LETTER SIGMA
    <Multi_key> <g> <t>       : "τ"        U03C4                # GREEK SMALL LETTER TAU
    <Multi_key> <g> <u>       : "υ"        U03C5                # GREEK SMALL LETTER UPSILON
    <Multi_key> <g> <v>       : "ς"        U03C2                # GREEK SMALL LETTER FINAL SIGMA
    <Multi_key> <g> <w>       : "ω"        U03C9                # GREEK SMALL LETTER OMEGA
    <Multi_key> <g> <x>       : "χ"        U03C7                # GREEK SMALL LETTER CHI
    <Multi_key> <g> <y>       : "η"        U03B7                # GREEK SMALL LETTER ΕΤΑ
    <Multi_key> <g> <z>       : "ζ"        U03B6                # GREEK SMALL LETTER ZETA
    # Capital greek letters.
    <Multi_key> <g> <A>       : "Α"        U0391                # GREEK CAPITAL LETTER ALPHA
    <Multi_key> <g> <B>       : "Β"        U0392                # GREEK CAPITAL LETTER BETA
    <Multi_key> <g> <C>       : "Ξ"        U039E                # GREEK CAPITAL LETTER XI
    <Multi_key> <g> <D>       : "Δ"        U0394                # GREEK CAPITAL LETTER DELTA
    <Multi_key> <g> <E>       : "Ε"        U0395                # GREEK CAPITAL LETTER EPSILON
    <Multi_key> <g> <F>       : "Φ"        U03A6                # GREEK CAPITAL LETTER PHI
    <Multi_key> <g> <G>       : "Γ"        U0393                # GREEK CAPITAL LETTER GAMMA
    <Multi_key> <g> <H>       : "Θ"        U0398                # GREEK CAPITAL LETTER THETA
    <Multi_key> <g> <I>       : "Ι"        U0399                # GREEK CAPITAL LETTER ΙΟΤΑ
    <Multi_key> <g> <K>       : "Κ"        U039A                # GREEK CAPITAL LETTER KAPPA
    <Multi_key> <g> <L>       : "Λ"        U039B                # GREEK CAPITAL LETTER LAMBDA
    <Multi_key> <g> <M>       : "Μ"        U039C                # GREEK CAPITAL LETTER MU
    <Multi_key> <g> <N>       : "Ν"        U039D                # GREEK CAPITAL LETTER NU
    <Multi_key> <g> <O>       : "Ο"        U039F                # GREEK CAPITAL LETTER OMICRON
    <Multi_key> <g> <P>       : "Π"        U03A0                # GREEK CAPITAL LETTER PI
    <Multi_key> <g> <Q>       : "Ψ"        U03A8                # GREEK CAPITAL LETTER PSI
    <Multi_key> <g> <R>       : "Ρ"        U03A1                # GREEK CAPITAL LETTER RHO
    <Multi_key> <g> <S>       : "Σ"        U03A3                # GREEK CAPITAL LETTER SIGMA
    <Multi_key> <g> <T>       : "Τ"        U03A4                # GREEK CAPITAL LETTER TAU
    <Multi_key> <g> <U>       : "Υ"        U03A5                # GREEK CAPITAL LETTER UPSILON
    <Multi_key> <g> <V>       : "Σ"        U03A3                # GREEK CAPITAL LETTER SIGMA
    <Multi_key> <g> <W>       : "Ω"        U03A9                # GREEK CAPITAL LETTER OMEGA
    <Multi_key> <g> <X>       : "Χ"        U03A7                # GREEK CAPITAL LETTER CHI
    <Multi_key> <g> <Y>       : "Η"        U0397                # GREEK CAPITAL LETTER ΕΤΑ
    <Multi_key> <g> <Z>       : "Ζ"        U0396                # GREEK CAPITAL LETTER ZETA
  '';
}
