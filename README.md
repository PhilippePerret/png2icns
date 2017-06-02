# PNG Image To ICNS Icon

![Illustration](./assets/img/illustration.png)

A Alfred's workflow and a bash script to convert a 1024x1024 PNG image to a ICNS icon (`.icns`) for your app.

## Usage

### Alfred Workflow

* Import the workflow (*) in [Alfred](https://www.alfredapp.com/),
* make the 1024x1024 PNG Image,
* choose it in Finder,
* hit CMD+ALT+CTRL+i

Et voilà!

> (*) PNGImage_2_ICNSIcon.alfredworkflow

### Bash Script

        # Go to the png2icns folder
        > cd /path/to/png2icns/folder/

        # Make `png2icns.sh` script exectable if necessary
        > chmod +x ./png2icns.sh

        # Convert PNG image
        > png2icns -v path/to/your/image.png

        # Any help?
        > png2icns --help

Et voilà!

## Keybord Shortcut

The shortcut `CMD+ALT+CTRL+I` can be modify in the workflow. Open it in Alfred, double-click on the first element, set your own kb shortcut.
