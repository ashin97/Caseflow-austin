---
nav_order: 1
---

# README

Welcome to the [GitHub Pages](https://pages.github.com/) for [Caseflow](https://github.com/department-of-veterans-affairs/caseflow)!
The webpage can be viewed at [http://department-of-veterans-affairs.github.io/caseflow/](http://department-of-veterans-affairs.github.io/caseflow/).

## Making changes

For small changes, most pages can be modified by clicking on the `Edit this page` link at the bottom of the page, modifying the `md` file, and committing the change.

For larger changes, checkout the `main-gh-pages` branch, make local modifications, and push your changes. This will trigger an update to the `gh-pages` branch used by GitHub Pages.

## Purpose of the `gh-pages` and `main-gh-pages` branches

The ([`gh-pages` branch](https://github.com/department-of-veterans-affairs/caseflow/tree/gh-pages)) contains the `html` and asset files displayed by GitHub Pages. The branch is not intended to be merged in the `master` branch. Note that it has a completely separate commit history from the Caseflow application `master` branch. For more info, see the [FAQ](#how-was-the-gh-pages-branch-created-without-a-commit-history).

The `gh-pages` branch is updated by a `build-gh-pages` GitHub Action that uses files from the `main-gh-pages` branch to generate `html` and asset files, which are pushed to the `gh-pages` branch. You should not modify the `gh-pages` branch directly, so you don't need to `git checkout` the branch. Any commit to the `main-gh-pages` branch will trigger the GitHub Action, which can be seen [here](https://github.com/department-of-veterans-affairs/caseflow/actions/workflows/build-gh-pages.yml). See [Committing changes](committing-changes) for how to make changes.

{% blockdiag %}
blockdiag {
  class branch [color=lightblue, shape=note];
  main-gh-pages [class=branch, label="main-gh-pages branch"]
  gh-pages [class=branch, label="gh-pages branch"]

  class ghAction [shape=ellipse]
  build-gh-pages [class=ghAction]
  website [shape=cloud]

  main-gh-pages -> build-gh-pages -> gh-pages -> website;

  any-branch [class=branch, label="any branch"]
  any-action [class=ghAction, label="some Action"]
  any-branch -> any-action -> gh-pages;
}
{% endblockdiag %}

Note that there may be some other GitHub Action that updates the `gh-pages` branch, so make sure to not cause folder or file name collisions when updating `main-gh-pages`.

## The `main-gh-pages` branch

The `main-gh-pages` branch has files for documentation. Some are automatically generated (e.g., [Caseflow DB schema](schema/html/index.html) by a GitHub Action); others are manually created (e.g., [Bat Team Remedies](batteam/index.html)).

## Checking out the branch

Even though `main-gh-pages` is another branch in the Caseflow repo, it is highly encouraged to check out the `main-gh-pages` branch in a separate directory because it has no common files with Caseflow's `master` branch to avoid accidentally deleting git-ignored files in your development branches.

To checkout to a `caseflow-gh-pages` directory as a sibling of your `caseflow` directory:
```
cd YOUR_PATH_TO/caseflow
cd ..
git clone -b gh-pages --single-branch https://github.com/department-of-veterans-affairs/caseflow.git caseflow-gh-pages
```

## Committing changes

Treat the `main-gh-pages` branch like Caseflow's `master` branch. A difference is that anyone can commit to `main-gh-pages` without a peer-review (just like the Caseflow wiki page). However for significant changes, it is encouraged to create a development branch and do a squash-merge when you are satisfied with the changes, just like what is done in Caseflow's `master` branch.

```
cd caseflow-gh-pages
git checkout -b my/add-amazing-new-page
# Make modifications, preview changes, and commit
git add .
git commit

# Once ready to merge
git checkout main-gh-pages
git merge --squash my/add-amazing-new-page
git commit

# Push to GitHub repo
git push
```

## Previewing changes

To preview changes locally, run the website generators locally as follows:
```
make run
```

If it's the first time running it, install some tools:
```
bundle install
make install_jekyll_diagram_dependencies # only needed to view diagrams locally
```

## Subsites

A *subsite* is useful for presenting documentation using a different theme or layout.

To create a new Jekyll subsite called SUBSITE:
1. Create subdirectory `__SUBSITE` (prefixed with 2 underscores)
2. Create a new `__SUBSITE/_config.yml` to override the defaults set in `__subsite_config.yml`
3. Add a new entry in `Makefile` to build the `html` files into destination directory `_site/SUBSITE`

Refer to the `__help` directory as an example.

Note that any [static site generator](https://www.netlify.com/blog/2020/04/14/what-is-a-static-site-generator-and-3-ways-to-find-the-best-one/) besides Jekyll can be used, such as Hugo, Gatsby, and Pelican -- adapt the instructions accordingly.

## Jekyll

This site uses the Jekyll theme [Just the Docs](https://pmarsceill.github.io/just-the-docs/).
The [help/jekyll.md](help/jekyll) subsite uses a different Jekyll theme, specified in `__help/_config.yml`.

Jekyll can be [configured](https://jekyllrb.com/docs/configuration/) to use [plugins](https://jekyllrb.com/docs/plugins/). Each `md` file can define [front matter](https://jekyllrb.com/docs/front-matter/) to specify how the corresponding page should be treated or visualized by the Jekyll theme.

## FAQ

### How was the `gh-pages` branch created without a commit history?

```
git checkout --orphan gh-pages
git reset --hard
git commit --allow-empty -m "Initializing gh-pages branch"
git push origin gh-pages
git checkout master
```
([reference](https://jiafulow.github.io/blog/2020/07/09/create-gh-pages-branch-in-existing-repo/))

Also see [GitHub's "Creating your site" instructions](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll#creating-your-site).

### Why not use the GitHub Wiki?

GitHub Wiki has the following limitations:
- Cannot serve up `html` content or files, along with referenced `css` files
- No table of content generation
- No built-in diagramming markup language
- While the wiki context can be organized into folder, the wiki presentation doesn't reflect the organization

GitHub Pages provides more control over web page organization and presentation -- see next section.

### Why not use the basic GitHub Pages (without GitHub Actions)?

GitHub Pages employs the Jekyll static site generator to convert `md` files into `html` files, all without any additional configuration -- see [GitHub Pages setup documentation](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll).

To enable additional website features and documentation presentation capabilities, a GitHub Action runs Jekyll and potentially other tools to generate the `html` files for GitHub Pages. The additional capabilities include:
- incorporating sets of generated `html` files, like [Caseflow DB schema](schema/html/index.html) created via [Jailer](https://github.com/Wisser/Jailer)
- generating table of contents and site navigation menu
- using markup syntax to generate diagrams, like [diagrams.md](diagrams.md)
- enabling subsites with different website themes/layouts, like [help/jekyll.md](help/jekyll)
- quick text search (provided by the [Just the Docs theme](https://pmarsceill.github.io/just-the-docs/))

These capabilities open up opportunities for enhanced presentation of Caseflow documentation, which aims to make information easier to find and understand.
