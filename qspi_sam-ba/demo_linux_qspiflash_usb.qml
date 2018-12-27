import SAMBA 3.2
import SAMBA.Connection.Serial 3.2
import SAMBA.Device.SAMA5D2 3.2

SerialConnection {

	device: SAMA5D2Xplained {
		// to use a custom config, replace SAMA5D2Xplained by SAMA5D2 and
		// uncomment the following lines, or see documentation for
		// custom board creation.
		//config {
		// qspiflash {
		// instance: 0
		// ioset: 3
		// freq: 66
		// }
		//}
	}

	function initNand() {
		/* Placeholder: Nothing to do */
	}

	function getEraseSize(size) {
		/* get smallest erase block size supported by applet */
		var eraseSize
		for (var i = 0; i <= 32; i++) {
			eraseSize = 1 << i
			if ((applet.eraseSupport & eraseSize) !== 0)
				break;
		}
		eraseSize *= applet.pageSize

		/* round up file size to erase block size */
		return (size + eraseSize - 1) & ~(eraseSize - 1)
	}

	function eraseWrite(offset, filename, bootfile) {
		/* get file size */
		var file = File.open(filename, false)
		var size = file.size()
		file.close()

		applet.erase(offset, getEraseSize(size))
		applet.write(offset, filename, bootfile)
	}

	onConnectionOpened: {
		var dtbFileName = "at91-sama5d2_xplained_pda4.dtb"
		var ubootEnvFileName = "u-boot-env.bin"

	
		//initializeApplet("serialflash")
		//applet.erase(0, 0x400000)
		
		
		print("-I- === Initialize serialflash access ===")
		initializeApplet("qspiflash")
		//applet.erase(0, applet.memorySize)
		applet.erase(0, 0x140000)

		// erase then write files
		print("-I- === Load AT91Bootstrap ===")
		applet.write(0x00000000, "boot.bin", true)

		//print("-I- === Load u-boot environment ===")
		//eraseWrite(0x00006000, ubootEnvFileName)

		print("-I- === Load u-boot ===")
		applet.write(0x00040000, "u-boot.bin") //SOM board uboot offset is 0x010000
		
		
		
		// initialize SD/MMC applet for on-board eMMC
		print("-I- === Initialize eMMC access ===")
		initializeApplet("sdmmc")

		print("-I- === Load rootfs on eMMC ===")
		//applet.write(0, "atmel-qt5-demo-image-sama5d2-xplained.wic", false)

		
		
		// initialize boot config applet
		initializeApplet("bootconfig")
		// Use BUREG0 as boot configuration word
		applet.writeBootCfg(BootCfg.BSCR, BSCR.fromText("VALID,BUREG0"))
		
		applet.writeBootCfg(BootCfg.BUREG0,
			BCW.fromText("EXT_MEM_BOOT,QSPI0_IOSET3,JTAG_IOSET1,SPI0_DISABLED,SPI1_DISABLED"))


		print("-I- === Done. ===")
		
	}
}
