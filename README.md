# 🐳 Docker Development Environment Template

A plug-and-play Docker template that quickly sets up a development environment and automatically mounts your project into the container.

## 📦 Installation to Project

Install this repo into your project:

```bash
# 1. Clone to docker folder from project root
git clone <this-repo-url> docker

# 2. Remove git history from docker folder
rm -rf docker/.git
```

After installation, your project structure will be:

```text
your-project/
├── docker/
│   ├── dockerfile
│   ├── docker.sh
│   ├── requirements/
│   └── ...
└── .gitignore
```

## ⚙️ Customize Installation Packages

### 🐋 Choose Docker Base Image

You can modify the `FROM` source in `dockerfile` according to your needs:

```dockerfile
# Default uses PyTorch + CUDA
FROM pytorch/pytorch:2.5.1-cuda12.1-cudnn9-devel

# Or use other base images, for example:
# FROM nvidia/cuda:12.1.0-cudnn9-devel-ubuntu22.04
# FROM python:3.11
# FROM tensorflow/tensorflow:latest-gpu
```

### 📝 Python Packages

Edit `docker/requirements/requirements.txt`:

```txt
numpy
pandas
torch
...
```

### 🔧 Development Tools & Custom Installation Scripts

You can create your own installation scripts in the `requirements/` folder and reference them in `install.sh`.

**Existing example scripts:**

- `requirements/agents.sh` - Install npm CLI tools
- `requirements/neovim.sh` - Install Neovim
- `requirements/lazyvim.sh` - Install LazyVim

**Create custom installation script example:**

1. Create your installation script at `docker/requirements/your-installation-script.sh`:

   ```bash
   #!/bin/bash
   # Add your installation commands here
   # For example: install tools, set environment variables, etc.
   ```

2. Add the reference in `docker/install.sh`:

   ```bash
   ./requirements/your-installation-script.sh
   ```

When building the image, all installation scripts you created in `requirements/` will be automatically executed!

## 🚀 Using docker.sh

**Note:** Make sure to make `docker.sh` executable first:

```bash
chmod +x docker/docker.sh
```

Execute the following commands from the project root:

```bash
# Start and enter container (will auto-build on first run)
bash docker/docker.sh start

# Stop container
bash docker/docker.sh stop

# Restart container
bash docker/docker.sh restart

# Remove container and image (will prompt for confirmation)
bash docker/docker.sh remove

# Rebuild container and image (will prompt for confirmation)
bash docker/docker.sh rebuild
```

### 📌 Quick Command Reference

| Command | Description |
|------|------|
| `start` | 🏗️ Build (if needed) and start container, enter interactive shell |
| `stop` | ⏹️ Stop running container |
| `restart` | 🔄 Stop and restart container |
| `remove` | 🗑️ Remove container, image, and build cache |
| `rebuild` | 🔨 Completely rebuild and start container |

## 💡 Tips

- Image and container names are automatically derived from your project name:
  - Image: `<project-name-lowercase>-image`
  - Container: `<project-name-lowercase>-container`
  - For example, if your project folder is `MyApp`, the image will be `myapp-image` and container will be `myapp-container`
- Project root directory is automatically mounted into the container
- Container automatically matches your UID/GID to avoid permission issues
- First `start` execution will automatically build the image (may take some time)
- If you need to customize Docker commands (e.g., add volumes, ports, environment variables), modify `docker.sh`

---

### 📄 License Information

Modified from ACAL Playlab (NCKU) by Mian-Heng Shan (@samynhn), 2024
