# Configs

Directory for configuration files that shouldn't be commited with git. These are
imported via `builtins.readFile`. Keep in mind, you *must* trim each config that
lives within here. As of now, this nixos-configuration expects the following
structure:

```bash
> tree config
config
├── device-uuid
├── host-id
├── jrpotter
│   └── authorized-keys
└── README.md

1 directory, 4 files
```
