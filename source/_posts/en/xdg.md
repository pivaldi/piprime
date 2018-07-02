title: Default application management on Linux with xdg-open & xdg-mime
date: 2018-05-07 15:39:30
id: cqqw2cq47idtd7i
categories:
- [Tech, Linux]
tags:
- Linux-howto
---

# The MIME Database

https://www.linuxtopia.org/online_books/linux_desktop_guides/gnome_2.14_admin_guide/mimetypes-database.html

# xdg-mime

```txt
$ xdg-mime query default image/png
xdg-mime query default image/png
wine-extension-png.desktop
```

Fixed with the command :

```txt
xdg-mime default display.desktop image/png
```


```txt
$ xdg-mime query default inode/directory
easytag.desktop
```

Fixed with the command :

```txt
xdg-mime default nemo.desktop inode/directory
```

To set your preferred _pdf_ reader :

```txt
xdg-mime default evince.desktop application/pdf
```
