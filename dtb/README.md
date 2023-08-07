## linux device tree for the nanopc-t6

<br/>

**build device the tree for the nanopc-t6**
```
sh make_dtb.sh
```

<i>the build will produce the target file rk3588-nanopc-t6.dtb</i>

<br/>

**optional: create symbolic links**
```
sh make_dtb.sh links
```

<i>convenience link to rk3588-nanopc-t6.dts and other relevant device tree files will be created in the project directory</i>

<br/>

**optional: clean target**
```
sh make_dtb.sh clean
```

