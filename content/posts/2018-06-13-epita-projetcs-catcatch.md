---
title: "EPITA projects: CatCatch"
categories:
  - EPITA
series:
  - EPITA projects
date: 2018-06-13T09:00:00+02:00
---

This project was my first long project, at EPITA or otherwise, IT-related or
otherwise. It was about making a game, how exciting!

### About the project

The project happens during the second semester of the first year at EPITA. The
subject is very free, with only a few constraints: it has to be in C# or OCaml.
We were allowed to use a game engine, Unity3D. It lasts about 5 months, with a
few intermediary steps:

* a project specification has to be submitted at the beginning of the project;
* two intermediary defenses, where we had to submit the current state of our
  project and a report of said state;
* a final defense, with a demonstration of the project.

As this is a long project, and there are no specific requirements, we were
widely advised to make a game using Unity.

I forgot to mention, we were a team of four.

### Our idea

Our very original idea was to make a game where the player would be a cat,
trying to catch other cats, or avoid being caught. We named it __CatCatch__.

The cats trying to catch other cats would be modeled after our teachers, and the
cats avoiding being caught after the students. The map where the game would take
place would be our school campus.

So that's what we did! The multiplayer version of the game was what you would
expect, the solo version was against some bots.

You can read all about it in the specification and reports we had to submit[^1].

[^1]: [Submitted documents](https://gitlab.com/risson-epita/prepa/42-2/CatCatch/CatCatch-docs/-/tags)

### The result

We ended up with a game without a huge map, _okay_ graphics, and a hell of a lot
of fun, probably because we made it though. The game was just working, on
Windows, OS X (at the time), Linux and we even exported a WebGL version that we
put on our website! Of course, we made some goodies, such as a 3D printed cat, a
lighter, a customized CD installer and a printed user manual.

All the executables are still available[^2], however the multiplayer mode won't
work.

[^2]: [Executables](https://gitlab.com/risson-epita/prepa/42-2/CatCatch/CatCatch/-/tags)

### Experience gained

#### Git

You would think that a project by four people is pretty easy to manage using
git, and you would be right! If only, those four people weren't first year
students and didn't have to deal with Unity garbage files and meta files
impossible to read and merge manually. As I was the most experienced group
member with git (I knew how to create a GitHub repository), I was put in charge
of managing that aspect of the project. It taught me __a lot__ about branches,
using pull/merge requests as part of my workflow, and some other stuff I had to
do to repair my teammates' broken repositories. We also had to migrate to GitLab
mid-project because of size limitations of GitHub.

#### Adaptability

A long project is bound to have some of its requirements change during
development. A team member leaves the school, a new team member joins, some
aspect of the game has to change, …, all of those we had to adapt to. It wasn't
always easy, but we didn't have a choice. It taught me to be flexible in the way
I work, and be open to change.

### In retrospect

This project was a great introduction to collaboration with other people. I
think it was a great way to start with something fun!

The source of this project is available
[here](https://gitlab.com/risson-epita/prepa/42-2/CatCatch), such as the source
for the submitted reports and the source of the website.
