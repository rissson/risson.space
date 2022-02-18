{ baseURL, isProduction, theme, themesDir, ... }:

{
  inherit baseURL theme themesDir;

  title = "YABOB";
  author = {
    name = "Marc 'risson' Schmitt";
    email = "marc.schmitt@risson.space";
  };
  copyright = "risson — All rights reserved";

  params = {
    dateFmt = "2006-01-02 15:04:05 -0700";
    description = "risson's blog. Mainly about Ops and some other stuff.";
    subtitle = "Yet Another Boring Ops Blog";
  };

  enableRobotsTXT = true;
  footnoteReturnLinkContents = "↩";

  markup = {
    highlight = {
      guessSyntax = true;
    };
  };

  permalinks = {
    posts = "/:year/:month/:title/";
  };

  taxonomies = {
    categories = "categories";
    series = "series";
    tags = "tags";
  };

  buildDrafts = isProduction;
  buildExpired = isProduction;
  buildFuture = isProduction;

  layoutDir = ./layouts;

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
        weight = 3;
      }
      {
        identifier = "series";
        name = "Series";
        title = "All series";
        url = "/series/";
        weight = 4;
      }
    ];
    meta = [
      {
        identifier = "categories";
        name = "Categories";
        weight = 1;
      }
      {
        identifier = "tags";
        name = "tags";
        weight = 2;
      }
      {
        identifier = "series";
        name = "Series";
        weight = 3;
      }
    ];
    footer = [
      {
        name = "GitLab";
        url = "https://gitlab.com/risson";
        weight = 1;
      }
      {
        name = "GitHub";
        url = "https://github.com/rissson";
        weight = 2;
      }
      {
        name = "Twitter";
        url = "https://twitter.com/marcerisson";
        weight = 3;
      }
      {
        name = "LinkedIn";
        url = "https://www.linkedin.com/in/risson/";
        weight = 4;
      }
      {
        name = "IRC risson @ irc.freenode.net";
        url = "#";
        weight = 5;
      }
      {
        name = "PGP Key";
        title = "PGP Key";
        url = "https://keys.openpgp.org/vks/v1/by-fingerprint/8A0E6A7C08ABB9DE67DE2A13F6FD87B15C263EC9";
        weight = 6;
      }
      {
        name = "Email";
        url = "mailto:marc.schmitt@risson.space";
        weight = 7;
      }
    ];
  };
}
