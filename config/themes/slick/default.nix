{ config, lib, ... }:

with lib;

{
  options = {
    author = {
      name = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      email = mkOption {
        type = with types; nullOr str;
        default = null;
      };
    };

    menu = {
      meta = mkOption {
        type = with types; nullOr (listOf attrs);
        default = [];
      };
    };

    params = {
      subtitle = mkOption {
        type = with types; nullOr str;
        default = null;
      };

      description = mkOption {
        type = with types; nullOr str;
        default = null;
      };

      favicon = mkOption {
        type = with types; nullOr str;
        default = "favicon.png";
      };

      css = mkOption {
        type = with types; nullOr str;
        default = null;
      };

      dateFmt = mkOption {
        type = with types; nullOr str;
        default = null;
      };

      errorPageText = mkOption {
        type = with types; nullOr str;
        default = null;
      };

      showNavHeader = mkOption {
        type = types.bool;
        default = true;
      };

      showFullContent = mkOption {
        type = types.bool;
        default = true;
      };

      showEmptyPagination = mkOption {
        type = types.bool;
        default = false;
      };

      showMetaDates = mkOption {
        type = types.bool;
        default = false;
      };

      showMetaLinks = mkOption {
        type = types.bool;
        default = false;
      };

      opengraph = mkOption {
        type = types.bool;
        default = false;
      };

      schema = mkOption {
        type = types.bool;
        default = false;
      };

      twitter_cards = mkOption {
        type = types.bool;
        default = false;
      };
    };

    preserveTaxonomyNames = mkOption {
      type = types.bool;
      default = true;
    };

    services = {
      rss = {
        limit = mkOption {
          type = types.int;
          default = 0; # Unlimited
        };
      };
    };
  };

  config = mkIf (config.theme == "slick") {
    canonifyURLs = true;

    markup = {
      goldmark = {
        renderer = {
          unsafe = true;
        };
      };
      highlight = {
        codeFences = true;
        guessSyntax = true;
        noClasses = true;
      };
    };

    paginate = 10;
    paginatePath = "page";

    taxonomies= {
      categories = "categories";
      series = "series";
      tags = "tags";
    };
  };
}
