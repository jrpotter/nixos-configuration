# Configs

Directory for configuration files that shouldn't be commited with git. These are
imported via `builtins.readFile`. Keep in mind, you *must* trim each config that
lives within here. As of now, this nixos-configuration expects the following
structure:

```bash
[root@nixos:/etc/nixos]# tree config
config
├── device-uuid
├── jrpotter
│   └── authorized-keys
└── README.md

1 directory, 3 files
```
