# Releasing Guide

This guide is intended for maintainers who want to make a new release of the deployKF project.

1. For a new minor or major release, create a `release-*` branch first.
    - For example, for the `v0.2.0` release, create a new branch called `release-0.2`. 
    - This allows for the continued release of bug fixes to older versions.
2. Create a new tag on the appropriate release branch for the version you are releasing.
    - For instance, you might create `v0.1.1` or `v0.1.1-alpha.1` on the `release-0.1` branch.
    - Ensure you ONLY create tags on the `release-*` branches, not on the `main` branch.
    - Remember to sign the tag with your GPG key. 
       - You can do this by running `git tag -s v0.1.1 -m "v0.1.1"`.
       - You can verify the tag signature by running `git verify-tag v0.1.1`.
    - Ensure you ONLY push the specific tag you want to release. 
       - For example, if you want to release `v0.1.1`, you should run `git push origin v0.1.1`.
       - Do NOT run `git push origin --tags` or `git push origin main`. 
    - When a new semver tag is created, a workflow will automatically create a GitHub draft release.
       - The release will include the generator `.zip` and corresponding SHA256 checksum file.
3. Generate the changelog using the "generate release notes" feature of GitHub and set it as the release description.
4. When ready to ship, manually publish the draft release.
5. Update the website:
    - Update the changelog pages using the [`update_changelogs.sh`](https://github.com/deployKF/website/blob/main/update_changelogs.sh) script.
    - Update the values page using the [`update_values_reference.sh`](https://github.com/deployKF/website/blob/main/update_values_reference.sh) script. 
       - Ensure you update `VALUES_GIT_REF` to point to the latest release tag.
       - If new a "top level" values section was created, you will need to update the script and [`/reference/deploykf-values.md`](https://github.com/deployKF/website/blob/main/content/reference/deploykf-values.md) content.
    - If you are releasing a new minor or major version, ensure you update the [`/releases/version-matrix.md`](https://github.com/deployKF/website/blob/main/content/releases/version-matrix.md) content.
    - If a new tool was added, ensure you update the [`/reference/tools.md`](https://github.com/deployKF/website/blob/main/content/reference/tools.md) content.