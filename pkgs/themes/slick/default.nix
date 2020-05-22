{ fetchpatch, runCommand }:

runCommand "hugo-theme-slick" {
  pinned = builtins.fetchTarball {
    name = "hugo-theme-slick";
    url = "https://github.com/spookey/slick/archive/84de72f58daf69ecaa758809b9ede30644cef3b1.tar.gz";
    sha256 = "16brn3dd01kf2n52rixpq7x2sskd8hv12hi4v4x9gfara7saldqh";
  };

  patches = [];

  preferLocalBuild = true;
} ''
    cp -r $pinned $out
    chmod -R u+w $out

    for p in $patches; do
      echo "Applying patch $p"
      patch -d $out -p1 < "$p"
    done
''
