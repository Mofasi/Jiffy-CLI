# JIFFY CLI

*A framework-agnostic, lightweight CLI tool for developers to scaffold, manage, and optimize static web projects with ease.*

---

## 🚀 Features

- **Project Management** – Quickly scaffold and configure web projects  
- **SPA Router** – Modern routing with metadata injection  
- **CLI Commands** – Create routes, manage layouts, optimize performance  
- **Zero Dependencies** – No Composer, no npm—pure PHP  

---

## 🛠 Installation

### Windows

1. Download `install_jiify.cmd`  
2. Run in Command Prompt:  
   ```cmd
   install_jiify.cmd
   ```
3. Verify installation:  
   ```cmd
   jiify -v
   ```

### Linux/macOS

1. Download `jiify.php` manually.  
2. Move it to `/usr/local/bin/jiify`.  
3. Grant execute permissions:  
   ```bash
   chmod +x /usr/local/bin/jiify
   ```
4. Verify installation:  
   ```bash
   jiify -v
   ```

---

## 🔹 CLI Commands

### Project Management

- `jiify new projectName` → Scaffold a new project  
- `jiify serve` → Start a local PHP development server  
- `jiify list-project` → Show project structure  

### Routing & Page Management

- `jiify add routeName` → Create a new route/page  
- `jiify list-routes` → Show all registered routes  

### Layouts & Templates

- `jiify set-layout layoutName` → Assign layout to route  
- `jiify list-layouts` → Show available layouts  

### Metadata Management

- `jiify set-meta routeName title "Page Title"` → Inject `<head>` tags  
- `jiify list-meta routeName` → Show metadata of a route  

### Performance & Optimization

- `jiify cache-clear` → Clear cached pages  
- `jiify list-cache` → Show cached views  
- `jiify assets-update` → Refresh Tailwind CSS & jQuery  

### Debugging & Logs

- `jiify list-logs` → View system logs  
- `jiify debug` → Run diagnostics on project setup  

---

## 📌 License

JIFFY CLI is an open-source project designed for simplicity and efficiency.
