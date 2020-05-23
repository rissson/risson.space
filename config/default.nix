{ config, pkgs, theme, prod ? true, baseURL ? "https://risson.space/" }:

with pkgs;
with lib;

let
  themeList = builtins.removeAttrs (callPackage ../pkgs {}).themes [ "override" "overrideDerivation" ];

  themesDir = runCommand "hugo-themes" {
    preferLocalBuild = true;
  } ''
    mkdir $out
    ${builtins.concatStringsSep
      ";"
      (mapAttrsToList (name: value: "ln -s ${value} $out/${name}") themeList)
    }
  '';

  # Hugo default options
  # https://gohugo.io/getting-started/configuration/
  default.options = {
    baseURL = mkOption {
      type = types.str;
      default = "";
    };

    build = {
      useResourceCacheWhen = mkOption {
        type = types.str;
        default = "fallback";
      };
      writeStats = mkOption {
        type = types.bool;
        default = false;
      };
    };

    buildDrafts = mkOption {
      type = types.bool;
      default = false;
    };

    buildExpired = mkOption {
      type = types.bool;
      default = false;
    };

    buildFuture = mkOption {
      type = types.bool;
      default = false;
    };

    /*caches = {
      # TODO
    };*/

    canonifyURLs = mkOption {
      type = types.bool;
      default = true;
    };

    copyright = mkOption {
      type = types.str;
      default = "";
    };

    disableAliases = mkOption {
      type = types.bool;
      default = false;
    };

    disableKinds = mkOption {
      type = with types; listOf str;
      default = [];
    };

    disableLiveReload = mkOption {
      type = types.bool;
      default = false;
    };

    disablePathToLower = mkOption {
      type = types.bool;
      default = false;
    };

    enableEmoji = mkOption {
      type = types.bool;
      default = false;
    };

    enableGitInfo = mkOption {
      type = types.bool;
      default = false;
    };

    enableInlineShortcodes = mkOption {
      type = types.bool;
      default = false;
    };

    enableMissingTranslationPlaceholders = mkOption {
      type = types.bool;
      default = false;
    };

    enableRobotsTXT = mkOption {
      type = types.bool;
      default = false;
    };

    frontmatter = {
      date = mkOption {
        type = with types; listOf str;
        default = [ "date" "publishDate" "lastmod" ];
      };
      lastmod = mkOption {
        type = with types; listOf str;
        default = [ ":git" "lastmod" "date" "publishDate" ];
      };
      publishDate = mkOption {
        type = with types; listOf str;
        default = [ "publishDate" "date" ];
      };
      expiryDate = mkOption {
        type = with types; listOf str;
        default = [ "expiryDate" ];
      };
    };

    footnoteAnchorPrefix = mkOption {
      type = types.str;
      default = "";
    };

    footnoteReturnLinkContents = mkOption {
      type = types.str;
      default = "";
    };

    googleAnalytics = mkOption {
      type = types.str;
      default = "";
    };

    hasCJKLanguage = mkOption {
      type = types.bool;
      default = false;
    };

    imaging = {
      resampleFilter = mkOption {
        type = types.str;
        default = "box";
      };
      quality = mkOption {
        type = types.int;
        default = 75;
      };
      anchor = mkOption {
        type = types.str;
        default = "smart";
      };
      bgColor = mkOption {
        type = types.str;
        default = "#ffffff";
      };
      exif = {
        includeFields = mkOption {
          type = types.str;
          default = "";
        };
        excludeFields = mkOption {
          type = types.str;
          default = "";
        };
        disableDate = mkOption {
          type = types.bool;
          default = false;
        };
        disableLatLong = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };

    layoutDir = mkOption {
      type = with types; listOf path;
      default = [ ../layouts ];
      apply = paths: pkgs.symlinkJoin { name = "layouts"; inherit paths; };
    };

    log = mkOption {
      type = types.bool;
      default = false;
    };

    logFile = mkOption {
      type = types.str;
      default = "";
    };

    markup = {
      # blackfriday is deprecated
      defaultMarkdownHandler = mkOption {
        type = types.str;
        default = "goldmark";
      };

      goldmark = {
        extensions = {
          definitionList = mkOption {
            type = types.bool;
            default = true;
          };
          footnote = mkOption {
            type = types.bool;
            default = true;
          };
          linkify = mkOption {
            type = types.bool;
            default = true;
          };
          strikethrough = mkOption {
            type = types.bool;
            default = true;
          };
          table = mkOption {
            type = types.bool;
            default = true;
          };
          taskList = mkOption {
            type = types.bool;
            default = true;
          };
          typographer = mkOption {
            type = types.bool;
            default = true;
          };
        };
        parser = {
          attribute = mkOption {
            type = types.bool;
            default = true;
          };
          autoHeadingID = mkOption {
            type = types.bool;
            default = true;
          };
          autoHeadingIDType = mkOption {
            type = types.str;
            default = "github";
          };
        };
        renderer = {
          hardWraps = mkOption {
            type = types.bool;
            default = false;
          };
          unsafe = mkOption {
            type = types.bool;
            default = false;
          };
          xhtml = mkOption {
            type = types.bool;
            default = false;
          };
        };
      };

      highlight = {
        codeFences = mkOption {
          type = types.bool;
          default = true;
        };
        guessSyntax = mkOption {
          type = types.bool;
          default = false;
        };
        hl_Lines = mkOption {
          type = types.str;
          default = "";
        };
        lineNoStart = mkOption {
          type = types.int;
          default = 1;
        };
        lineNos = mkOption {
          type = types.bool;
          default = false;
        };
        lineNumbersInTable = mkOption {
          type = types.bool;
          default = true;
        };
        noClasses = mkOption {
          type = types.bool;
          default = true;
        };
        style = mkOption {
          type = types.str;
          default = "monokai";
        };
        tabWidth = mkOption {
          type = types.int;
          default = 4;
        };
      };

      tableOfContents = {
        endLevel = mkOption {
          type = types.int;
          default = 3;
        };
        ordered = mkOption {
          type = types.bool;
          default = false;
        };
        startLevel = mkOption {
          type = types.int;
          default = 2;
        };
      };
    };

    menu = {
      main = mkOption {
        type = with types; nullOr (listOf attrs);
        default = [];
      };
      footer = mkOption {
        type = with types; nullOr (listOf attrs);
        default = [];
      };
    };

    /*minify = {
      # TODO
    };*/

    newContentEditor = mkOption {
      type = types.str;
      default = "";
    };

    noChmod = mkOption {
      type = types.bool;
      default = false;
    };

    noTimes = mkOption {
      type = types.bool;
      default = false;
    };

    paginate = mkOption {
      type = types.int;
      default = 10;
    };

    paginatePath = mkOption {
      type = types.str;
      default = "page";
    };

    permalinks = mkOption {
      type = with types; nullOr attrs;
      default = {
        posts = "/:year/:month/:title/";
      };
    };

    pluralizeListTitles = mkOption {
      type = types.bool;
      default = true;
    };

    related = {
      threshold = mkOption {
        type = types.int;
        default = 80;
      };
      includeNewer = mkOption {
        type = types.bool;
        default = false;
      };
      toLower = mkOption {
        type = types.bool;
        default = false;
      };
      indices = mkOption {
        type = with types; listOf attrs;
        default = [
          { name = "keywords"; weight = 100; }
          { name = "date"; weight = 10; }
        ];
      };
    };

    relativeURLS = mkOption {
      type = types.bool;
      default = false;
    };

    refLinksErrorLevel = mkOption {
      type = types.str;
      default = "ERROR";
    };

    refLinksNotFoundURL = mkOption {
      type = types.str;
      default = "";
    };

    rssLimit = mkOption {
      type = types.int;
      default = 0; # Unlimited
    };

    sectionPagesMenu = mkOption {
      type = types.str;
      default = "";
    };

    sitemap = {
      changefreq = mkOption {
        type = types.str;
        default = "monthly";
      };
      filename = mkOption {
        type = types.str;
        default = "sitemap.xml";
      };
      priority = mkOption {
        type = types.float;
        default = 0.5;
      };
    };

    summaryLength = mkOption {
      type = types.int;
      default = 70;
    };

    taxonomies = mkOption {
      type = with types; nullOr attrs;
      default = {
        categories = "categories";
        tags = "tags";
      };
    };

    theme = mkOption {
      type = types.str;
      default = theme;
    };

    themesDir = mkOption {
      type = types.path;
      default = themesDir;
    };

    timeout = mkOption {
      type = types.int;
      default = 10000;
    };

    title = mkOption {
      type = types.str;
      default = "";
    };

    titleCaseStyle = mkOption {
      type = types.str;
      default = "AP";
    };

    uglyURLs = mkOption {
      type = types.bool;
      default = false;
    };

    verbose = mkOption {
      type = types.bool;
      default = false;
    };

    verboseLog = mkOption {
      type = types.bool;
      default = false;
    };

    watch = mkOption {
      type = types.bool;
      default = false;
    };
  } // (optionalAttrs prod {
    archetypeDir = mkOption {
      type = with types; listOf path;
      default = [ ../archetypes ];
      apply = paths: pkgs.symlinkJoin { name = "archetypes"; inherit paths; };
    };

    assetDir = mkOption {
      type = with types; listOf path;
      default = [ ../assets ];
      apply = paths: pkgs.symlinkJoin { name = "assets"; inherit paths; };
    };

    contentDir = mkOption {
      type = with types; listOf path;
      default = [ ../content ];
      apply = paths: pkgs.symlinkJoin { name = "contents"; inherit paths; };
    };

    dataDir = mkOption {
      type = with types; listOf path;
      default = [ ../data ];
      apply = paths: pkgs.symlinkJoin { name = "data"; inherit paths; };
    };

    publishDir = mkOption {
      type = types.str;
      default = "public";
    };

    staticDir = mkOption {
      type = with types; listOf path;
      default = [ ../static ];
      apply = paths: pkgs.symlinkJoin { name = "static"; inherit paths; };
    };
  });

  themes = {
    imports = [ ./themes ];
  };

  personal.config = {
    inherit baseURL;
    title = "YABOB";
    copyright = "risson — All rights reserved";

    enableRobotsTXT = true;
    footnoteReturnLinkContents = "↩";

    enableGitInfo = true;
  } // (optionalAttrs (theme == "slick") {
    author = {
      name = "Marc 'risson' Schmitt";
      email = "marc.schmitt@risson.space";
    };

    params = {
      subtitle = "Yet Another Boring Ops Blog";
      description = "risson's blog. Mainly about Ops and some other stuff.";
      errorPageText = "Woops! Looks like you got lost :/";

      showFullContent = false;
      showMetaDates = true;
      showMetaLinks = true;

      opengraph = true;
      schema = true;
      twitter_cards = true;
    };

    menu = {
      main = [
        {
          identifier = "post";
          name = "Posts";
          title = "All posts";
          url = "/posts/";
          weight = 1;
        }
        {
          identifier = "categories";
          name = "Categories";
          title = "All categories";
          url = "/categories/";
          weight = 2;
        }
        {
          identifier = "tags";
          name = "Tags";
          title = "All tags";
          url = "/tags/";
          weight = 2;
        }
        {
          identifier = "series";
          name = "Series";
          title = "All series";
          url = "/series/";
          weight = 2;
        }
      ];
      meta = [
        {
          identifier = "categories";
          name = "Categories";
          weight = 1;
        }
        {
          identifier = "series";
          name = "Series";
          weight = 2;
        }
        {
          identifier = "tags";
          name = "Tags";
          weight = 3;
        }
      ];
      footer = [
        {
          name = "GitLab";
          title = "GitLab profile";
          url = "https://gitlab.com/risson";
          weight = 1;
        }
        {
          name = "GitHub";
          title = "GitHub profile";
          url = "https://github.com/rissson";
          weight = 2;
        }
        {
          name = "Twitter";
          title = "Twitter profile";
          url = "https://twitter.com/marcerisson";
          weight = 3;
        }
        {
          name = "LinkedIn";
          title = "LinkedIn profile";
          url = "https://www.linkedin.com/in/marc-schmitt-9134a6150";
          weight = 4;
        }
        {
          name = "IRC";
          title = "risson @ irc.freenode.net";
          weight = 5;
        }
        {
          name = "PGP Key";
          title = "PGP Key";
          url = "https://keys.openpgp.org/vks/v1/by-fingerprint/8A0E6A7C08ABB9DE67DE2A13F6FD87B15C263EC9";
          weight = 6;
        }
        {
          name = "GitHub";
          title = "GitHub profile";
          url = "https://github.com/rissson";
          weight = 7;
        }
        {
          name = "Email";
          title = "marc [dot] schmitt [at] risson [dot] space";
          weight = 8;
        }
      ];
    };
  });

in evalModules {
  modules = [
    # Hugo default options and configuration
    default
    # Themes default options and configuration
    themes
    # Our configuration
    personal
  ];
}
