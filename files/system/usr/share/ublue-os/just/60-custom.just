# @recipe
init-sys-core:
    @echo "⚠️  WARNING: This will DELETE and RECREATE the 'sys-core' container."
    @echo "All system packages inside the container will be lost."
    @echo "Files in your Home directory will be safe."
    @read -p "Are you sure you want to proceed? [y/N] " -n 1 -r; \
    echo ""; \
    if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
        echo "❌ Aborted."; \
        exit 1; \
    fi
    @echo "🚀 Creating System Core..."
    -distrobox stop sys-core --yes
    -distrobox rm sys-core --yes
    distrobox create --name sys-core --image registry.fedoraproject.org/fedora-toolbox:latest --hostname sys-core --yes
    @echo "📦 Provisioning Packages..."
    # This trick reads the script from the HOST and runs it INSIDE the container
    distrobox enter sys-core -- bash -c "$$(cat /usr/bin/provision_sys_core.sh)"
    @echo "✅ System Core Ready."

# @recipe
new-project name:
    @echo "🏗️  Creating Project: {{name}}..."
    distrobox create --name {{name}} --image registry.fedoraproject.org/fedora-toolbox:latest --hostname {{name}} --yes
    @echo "🔧 Provisioning..."
    # This trick reads the script from the HOST and runs it INSIDE the container
    distrobox enter {{name}} -- bash -c "$$(cat /usr/bin/provision_project.sh)"
    @echo "✅ Project '{{name}}' ready."

# @recipe
enter-sys:
    distrobox enter sys-core
