import SAMBA 3.2
import SAMBA.Connection.Serial 3.2
import SAMBA.Device.SAMA5D2 3.2

SerialConnection {

	device: SAMA5D2Xplained {
	}

	function initNand() {
		/* Placeholder: Nothing to do */
	}

	onConnectionOpened: {

		// initialize SD/MMC applet for on-board eMMC
		print("-I- === Initialize eMMC access ===")
		initializeApplet("sdmmc")

		print("-I- === Load images on eMMC ===")
		applet.write(0, "sd_emmc_image.img", false)

		print("-I- === Done. ===")
	}
}
