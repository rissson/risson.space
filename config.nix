{ baseURL, isProduction ? true, theme ? "slick", themesDir, ... }:

{
  inherit baseURL theme themesDir;

  title = "YABOB";
  author = {
    name = "Marc 'risson' Schmitt";
    email = "marc.schmitt@risson.space";
  };
  copyright = "risson — All rights reserved";

  params = {
    css = null;
    dateFmt = null;
    description = "risson's blog. Mainly about Ops and some other stuff.";
    errorPageText = "Woops! Looks like you got lost :/";
    favicon = "favicon.png";
    opengraph = true;
    schema = true;
    showEmptyPagination = false;
    showFullContent = false;
    showMetaDates = true;
    showMetaLinks = true;
    showNavHeader = true;
    subtitle = "Yet Another Boring Ops Blog";
    twitter_cards = true;
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
        url = "irc://risson@irc.freenode.net";
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
        title = "marc.schmitt@risson.space";
        url = "mailto:marc.schmitt@risson.space";
        weight = 7;
      }
    ];
  };
}
