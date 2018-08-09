CnO Versioning
===

### Versioning System

We are using [Semantic Versioning 2.0](http://semver.org) adapted in the 
following way:

1. MAJOR version changes make old model incompatible and requires a full 
migration.
2. MINOR version when you add set of functionality (one iteration worth) in a 
backwards-compatible manner.
3. PATCH version when you make backwards-compatible hot fixes.


### Tool

For reading and bumping up the version numbers we use the [autoversion gem](https://github.com/jpettersson/autoversion)

And we provide a _Versionfile_ configuration file that looks like this:

```ruby
GLOBAL_VERSION_FILE = 'version.txt'
VERSION_PATTERN = /^\s*VERSION = \"(.+)\"$/

matcher = proc { |line| (m = VERSION_PATTERN.match(line)) ? m[1] : nil }

read_version do
  parse_file GLOBAL_VERSION_FILE, matcher
end

write_version do |oldVersion, newVersion|
  version_files = Dir.glob('{RailsApp,Workers}/**/version.rb')
  version_files << GLOBAL_VERSION_FILE
  update_files version_files, matcher, oldVersion, newVersion
end
```

The gem has the ability to read version number from a file and to write it to 
multiple files. And we are taking the advantage of this for updating the 
version number inside our _RailsApp_ and _Workers_ modules all at once.

So, the version number is stored at 3 places:

1. `CnO/version.txt`
2. `CnO/RailsApp/config/initializers/version.rb`
3. `CnO/Workers/config/version.rb`

And it MUST NOT be manually modified in any of them.

The following section explains how the version is bumped up using the tool.


### Workflow

#### Branches

Based on [Vincent Driessen's model](http://nvie.com/posts/a-successful-git-branching-model/)  

1. **master**: Main branch with production-ready code. Tags are made at this
branch.
2. **develop**: Source code of HEAD reflects a state with the latest delivered
development changes.
3. **feature**: Created for each specific feature. Exists only during the 
feature development lifetime.
4. **release**: Created when **develop** reflects the desired state of the new 
release (at the end of an iteration). It is also at this point when MAJOR or 
MINOR version numbers are bumped up.
5. **hotfix**: They branch off from master and are the ones that bump up the
PATCH section of the version number.


#### Steps

##### _Normal development workflow (bugs or features):_

1) Branch off from develop
```
$ git checkout -b my-feature develop
```

2) Work on the feature. Commit frequently.

3) Push to origin when need to work in collaboration with someone else or at
the end of the day (to save a backup of your work)
```
$ git push -u origin my-feature
```

4) Pull with rebase if working in collaboration and want to merge your 
co-worker's changes
```
$ git pull --rebase
```

5) When finished with the feature, create a pull-request for having the rest of 
the team test and review the changes. The _base_ branch is **develop** and the 
_compare_ branch is **my-feature**.

6) Work on what's suggested by the people who reviewed the pull request. 

7) Once the pull request was accepted and merged into `develop`, clean-up local 
and remote branches
```
$ git branch -d my-feature
$ git push origin --delete my-feature
```


##### _End of iteration workflow:_

1) At the **develop** branch, bump up the version number
```
$ autoversion major
# or
$ autoversion minor
```

2) Create the release branch
```
$ git checkout -b release-`autoversion`
```

3) Commit the version number change
```
$ git commit -a -m "Bumped version number to `autoversion`"
```

4) Apply bug fixes to this branch if they were found after the creation of the 
branch but before merging into *master*.

5) Merge into **master**
```
$ git checkout master
$ git merge --no-ff release-x.x.x
```

6) Push the updated **master**
```
$ git push -u origin master
```

7) Remove the release branch locally and remotely (if was pushed at some point
for collaboration)
```
$ git branch -d release-`autoversion`
$ git push origin --delete release-`autoversion`
```

8) Create and push the tag
```
$ git tag -a `autoversion`
$ git push origin `autoversion`
```


##### _Hotfix workflow:_

1) At the master branch, bump up the version number
```
$ autoversion patch
```

2) Create the hot-fix branch
```
$ git checkout -b hotfix-`autoversion`
```

3) Commit the version number change
```
$ git commit -a -m "Bumped version number to `autoversion`"
```

4) Fix the bug and make the commit(s)

5) Merge into **master**
```
$ git checkout master
$ git merge --no-ff hotfix-x.x.x
```

6) Push the updated **master**
```
$ git push -u origin master
```

7) Merge into develop or into a release branch
7.a) If a release branch exists:
```
$ git checkout release-y.y.y
$ git merge --no-ff hotfix-x.x.x
$ git push -u origin release-y.y.y
```

7.b) If a release branch does not exist or the hotfix is required for a current work 
in **develop**
```
$ git checkout develop
$ git merge --no-ff hotfix-x.x.x
$ git push -u origin develop
```

8) Remove the hotfix branch locally and remotely (if was pushed at some point
for collaboration)
```
$ git branch -d hotfix-`autoversion`
$ git push origin --delete hotfix-`autoversion`
```
