# Cache Node Modules and Install Dependencies

A GitHub Action that efficiently manages Node.js dependencies by caching node_modules and installing dependencies only when necessary.

## Features

- Intelligently detects changes in package.json and package-lock.json
- Restores cached node_modules when possible
- Installs dependencies only when necessary
- Supports authentication for private GitHub packages
- Works with monorepos via configurable working directory
- Validates dependency installation and provides status outputs
- Handles errors gracefully with helpful messages

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `appVersion` | Version of the app for caching | No | `1.0.0` |
| `registryToken` | GitHub token for authentication with private package registries | No | - |
| `targetBranch` | Target branch for comparison. If not provided, automatically detects repository default branch | No | `` |
| `workingDir` | Directory containing package.json and where node_modules should be installed. Useful for monorepos | No | `.` |

## Outputs

| Output | Description |
|--------|-------------|
| `success` | Whether dependencies were successfully prepared (true/false) |
| `source` | Source of dependencies: "cache", "install", or "none" |

## Usage

```yaml
steps:
  - uses: actions/checkout@v3
    with:
      fetch-depth: 0  # Required for comparing against target branch

  - name: Cache dependencies
    id: deps
    uses: marxa-digital/actions/cache-dependencies@main
    with:
      appVersion: "1.2.3"              # Optional: Version for cache key
      registryToken: ${{ secrets.GITHUB_TOKEN }}  # Optional: For private packages
      targetBranch: "main"             # Optional: Branch to compare against
      workingDir: "./packages/app"     # Optional: For monorepos

  - name: Build
    if: steps.deps.outputs.success == 'true'
    run: npm run build
```

## Private Package Registry Authentication
If your project depends on packages from private registries (like GitHub Packages), provide a registryToken with appropriate read permissions:

```yml
    - name: Cache and install dependencies
      uses: marxa-digital/actions/cache-dependencies@main
      with:
        registryToken: ${{ secrets.GITHUB_TOKEN }}
```

## Monorepo Support
For monorepos or projects with non-standard directory structures, use the workingDir parameter:

```yml
    - name: Cache and install dependencies
      uses: marxa-digital/actions/cache-dependencies@main
      with:
        workingDir: "./packages/frontend"
```

## License

MIT
