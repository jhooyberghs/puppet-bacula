define pxe::menu::entry (
  $order    ='10',
  $kernel   = "menu.c32",
  $append,
  $file,
  $template = "pxe/menuentry.erb") {

  $tftp_root = $::pxe::tftp_root
  $fullpath  = "$tftp_root/pxelinux.cfg"

  concat::fragment { "$target-menu-entry-$title":
    order   => $order,
    target  => "$fullpath/$file",
    content => template("pxe/menuentry.erb"),
  }


}

