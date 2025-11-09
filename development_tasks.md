# 🧩 Development Tasks Guide – Raku SLES15 Container Project

**Project:** `raku-sles15-container`  
**Platform:** macOS + Podman (local builds for SLES15)

This guide explains how to:
- Add new Raku modules,
- Test them locally,
- And prepare for Git (CI/CD) checks.

---

## 1️⃣ Add a new module to `modules.conf`

Edit the file at the root of your repository:

```bash
cd ~/repos/github.com/raku-sles15-container
nano modules.conf

# Core Raku modules to include in runtime
JSON::Fast
Cro
Cro::HTTP

```bash


Rules:
	•	Lines starting with # are comments.
	•	Blank lines are ignored.
	•	Each valid line is a Raku module name that will be installed with zef.

Each time you change modules.conf, rebuild the image so that new modules are installed:

```bash
podman build --no-cache --arch amd64 -t raku-sles15sp6:dev -f Containerfile.
```bash

Use --no-cache if you want to force Podman to reinstall modules and not reuse layers.

During the build you should see a line like:

Installing Raku modules from modules.conf:
JSON::Fast
Cro
Cro::HTTP

Verify that modules are installed and load correctly

After the build, test each module individually inside the container.

Option A: Single module test

podman run --rm -it raku-sles15sp6:dev raku -e "use JSON::Fast; say 'OK: JSON::Fast loaded';"
podman run --rm -it raku-sles15sp6:dev \
  raku -e "use JSON::Fast; say 'OK: JSON::Fast loaded';"


Option B: Loop test for all modules in modules.conf

while IFS= read -r module; do
  case "$module" in
    ''|\#*) continue ;;
  esac
  echo "Testing $module ..."
  podman run --rm -it raku-sles15sp6:dev raku -e "use $module; say qq[OK: $module];"
done < modules.conf

Expected output:

Testing JSON::Fast ...
OK: JSON::Fast
Testing Cro ...
OK: Cro
Testing Cro::HTTP ...
OK: Cro::HTTP

If any module fails, note the error (e.g. missing dependencies, native libs) and adjust the Dockerfile accordingly (e.g. zypper in ...).

ommit your changes to Git

Once your local tests succeed, commit your modules.conf changes so CI/CD can use them:

git add modules.conf
git commit -m "Add/Update modules in modules.conf (e.g. JSON::Fast, Cro, Cro::HTTP)"
git push

Check GitHub Actions (CI/CD)

After pushing, GitHub automatically:
	•	Rebuilds the container using your updated modules.conf
	•	Runs raku -v test
	•	(Later we’ll add a step that also runs the same module loop automatically in CI)

You can see the progress in:
https://github.com/fjk/raku-sles15-container/actions


Select the latest “Build and Test Raku Image” run →
Open the “Test Raku inside the image” step to see the logs.

(Optional) Tag and release a new runtime build
Once CI is green, create a tagged release to produce a runtime tarball:

git tag v0.0.2
git push origin v0.0.2

GitHub Actions will:
	•	Build a release image with your modules
	•	Create:
	•	raku-sles15sp6-0.0.2.tar
	•	raku-runtime-0.0.2.tar.gz
	•	Publish both under Releases￼


SUMMARY

Step
Command
Purpose
1
edit modules.conf
Declare new modules
2
podman build …
Build image with modules
3
podman run … raku -e "use …"
Verify module installation
4
git commit / push
Push configuration changes
5
CI on GitHub
Automated build/test
6
git tag + push
Trigger runtime release


Notes
	•	The image is built for linux/amd64 (matching SLES15).
	•	modules.conf defines the exact module set embedded in the runtime.
	•	Later, CI will automatically loop through each module and run use <Module> as part of the build test.

## Create a new Release 

Only with git push origin eg. v0.0.1 we start a release release.yml-Workflow.

This will then happen automatically:
	1.	Image-Build: raku-sles15sp6:0.0.1
	2.	raku -v-Test
	3.	Image as raku-sles15sp6-0.0.1.tar in build/
	4.	Runtime as raku-runtime-0.0.1.tar.gz in build/
	5.	GitHub-Release v0.0.1 with both Files as Assets

This is the process: 

cd ~/repos/github.com/raku-sles15-container

# check commits (and remember to to local podman builds and checks before
git status

# if there are changes to commit then commit
# git add ...
# git commit -m "Prepare for new release x.x.x"

# set new Tag
git tag v0.0.2

# Tag nach GitHub pushen
git push origin v0.0.2