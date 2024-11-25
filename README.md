# Dotfiles Repository

This repository contains configuration files for a personalized development environment. It includes `.vimrc` for Vim configuration and `.bashrc` for shell customization.

---

## **Included Files**

### `.vimrc`
The `.vimrc` file is configured to provide a powerful Vim experience with plugin management using [vim-plug](https://github.com/junegunn/vim-plug). It supports easy plugin installation, updates, and management.

### `.bashrc`
The `.bashrc` file contains custom shell configurations, aliases, environment variables, and other enhancements for productivity in the terminal.

---

## **Getting Started**

### **1. Clone the Repository**
Clone the repository to your home directory (or a desired location):
```bash
git clone https://your-repo-url.git ~/dotfiles
```

### **2. Symlink the Files**
To use the configurations, create symbolic links to these dotfiles in your home directory:
```bash
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.bashrc ~/.bashrc
```

### **3. Reload Configurations**
- For `.bashrc`: Reload the shell configuration:
  ```bash
  source ~/.bashrc
  ```
- For `.vimrc`: Open Vim and run:
  ```vim
  :source ~/.vimrc
  ```

---

## **Using vim-plug**

This setup uses `vim-plug` as the plugin manager. If `vim-plug` is not installed, it will automatically download and set it up when you start Vim for the first time.

### **vim-plug Commands**

- **Install Plugins:** Run the following command in Vim:
  ```vim
  :PlugInstall
  ```
  This installs all the plugins listed in your `.vimrc`.

- **Update Plugins:**
  ```vim
  :PlugUpdate
  ```
  Installs any new plugins and updates existing ones.

- **Review Changes:**
  ```vim
  :PlugDiff
  ```
  Displays changes made since the last update.

- **Clean Unused Plugins:**
  ```vim
  :PlugClean
  ```
  Removes any plugins no longer listed in `.vimrc`.

---

## **Customization**

Feel free to modify `.vimrc` and `.bashrc` to suit your preferences:
- Add new plugins in the `vim-plug` section of `.vimrc`.
- Define custom aliases and environment variables in `.bashrc`.

---

## **Contributing**

If you'd like to contribute improvements to these dotfiles, feel free to submit a pull request or open an issue.

---

## **License**

These dotfiles are open source and available under the [MIT License](LICENSE).

---

## **Credits**

- [vim-plug](https://github.com/junegunn/vim-plug)
- Inspiration from various dotfiles repositories.

---

Enjoy your enhanced development environment! 🚀
